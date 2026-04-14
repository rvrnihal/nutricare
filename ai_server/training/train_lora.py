import argparse
import json
from pathlib import Path

import torch
from datasets import Dataset
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    BitsAndBytesConfig,
    DataCollatorForLanguageModeling,
    Trainer,
    TrainingArguments,
)


PROMPT_TEMPLATE = """You are NutriCare AI, a practical nutrition and fitness assistant.
Rules:
- Give safe, evidence-aligned health suggestions.
- Never replace professional medical advice.
- Be concise and actionable.

Instruction: {instruction}
Input: {input}
Response: {output}"""


def read_jsonl(path: Path):
    rows = []
    with path.open('r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def format_example(row):
    return PROMPT_TEMPLATE.format(
        instruction=row['instruction'],
        input=row['input'],
        output=row['output'],
    )


def build_dataset(path: Path):
    rows = read_jsonl(path)
    texts = [format_example(r) for r in rows]
    return Dataset.from_dict({'text': texts})


def tokenize_dataset(dataset, tokenizer, max_length: int):
    def _tokenize(batch):
        out = tokenizer(
            batch['text'],
            truncation=True,
            padding='max_length',
            max_length=max_length,
        )
        out['labels'] = out['input_ids'].copy()
        return out

    return dataset.map(_tokenize, batched=True, remove_columns=['text'])


def main():
    parser = argparse.ArgumentParser(description='Fine-tune NutriCare model with LoRA')
    parser.add_argument('--base-model', default='TinyLlama/TinyLlama-1.1B-Chat-v1.0')
    parser.add_argument('--train-file', required=True)
    parser.add_argument('--val-file', required=True)
    parser.add_argument('--output-dir', required=True)
    parser.add_argument('--max-length', type=int, default=512)
    parser.add_argument('--epochs', type=int, default=2)
    parser.add_argument('--batch-size', type=int, default=2)
    parser.add_argument('--grad-accum', type=int, default=8)
    parser.add_argument('--learning-rate', type=float, default=2e-4)
    parser.add_argument('--use-4bit', action='store_true')
    args = parser.parse_args()

    train_ds = build_dataset(Path(args.train_file))
    val_ds = build_dataset(Path(args.val_file))

    tokenizer = AutoTokenizer.from_pretrained(args.base_model, use_fast=True)
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token

    quant_cfg = None
    if args.use_4bit and torch.cuda.is_available():
        quant_cfg = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_quant_type='nf4',
            bnb_4bit_use_double_quant=True,
            bnb_4bit_compute_dtype=torch.float16,
        )

    model = AutoModelForCausalLM.from_pretrained(
        args.base_model,
        quantization_config=quant_cfg,
        device_map='auto' if torch.cuda.is_available() else None,
    )

    if quant_cfg is not None:
        model = prepare_model_for_kbit_training(model)

    lora_cfg = LoraConfig(
        r=16,
        lora_alpha=32,
        lora_dropout=0.05,
        bias='none',
        task_type='CAUSAL_LM',
        target_modules=['q_proj', 'k_proj', 'v_proj', 'o_proj'],
    )
    model = get_peft_model(model, lora_cfg)

    tokenized_train = tokenize_dataset(train_ds, tokenizer, args.max_length)
    tokenized_val = tokenize_dataset(val_ds, tokenizer, args.max_length)

    training_args = TrainingArguments(
        output_dir=args.output_dir,
        num_train_epochs=args.epochs,
        per_device_train_batch_size=args.batch_size,
        per_device_eval_batch_size=args.batch_size,
        gradient_accumulation_steps=args.grad_accum,
        learning_rate=args.learning_rate,
        logging_steps=10,
        eval_steps=25,
        save_steps=50,
        evaluation_strategy='steps',
        save_total_limit=2,
        fp16=torch.cuda.is_available(),
        bf16=False,
        report_to='none',
    )

    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=tokenized_train,
        eval_dataset=tokenized_val,
        tokenizer=tokenizer,
        data_collator=DataCollatorForLanguageModeling(tokenizer=tokenizer, mlm=False),
    )

    trainer.train()
    model.save_pretrained(args.output_dir)
    tokenizer.save_pretrained(args.output_dir)
    print(f'LoRA adapter saved to: {args.output_dir}')


if __name__ == '__main__':
    main()

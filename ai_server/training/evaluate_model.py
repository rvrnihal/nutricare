import argparse
import json
import re
from pathlib import Path

import torch
from peft import PeftModel
from transformers import AutoModelForCausalLM, AutoTokenizer


PROMPT_TEMPLATE = """You are NutriCare AI, a practical nutrition and fitness assistant.
Rules:
- Give safe, evidence-aligned health suggestions.
- Never replace professional medical advice.
- Be concise and actionable.

Instruction: {instruction}
Input: {input}
Response:"""


def read_jsonl(path: Path):
    rows = []
    with path.open('r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def normalize(text: str) -> str:
    text = text.lower().strip()
    text = re.sub(r'\s+', ' ', text)
    return text


def token_f1(pred: str, ref: str) -> float:
    p_tokens = normalize(pred).split()
    r_tokens = normalize(ref).split()
    if not p_tokens or not r_tokens:
        return 0.0

    p_set = set(p_tokens)
    r_set = set(r_tokens)
    overlap = len(p_set & r_set)
    if overlap == 0:
        return 0.0

    precision = overlap / len(p_set)
    recall = overlap / len(r_set)
    return 2 * precision * recall / (precision + recall)


def generate(model, tokenizer, instruction: str, user_input: str, max_new_tokens: int = 128):
    prompt = PROMPT_TEMPLATE.format(instruction=instruction, input=user_input)
    encoded = tokenizer(prompt, return_tensors='pt').to(model.device)
    with torch.no_grad():
        out = model.generate(
            **encoded,
            max_new_tokens=max_new_tokens,
            do_sample=False,
            temperature=0.0,
            pad_token_id=tokenizer.eos_token_id,
        )
    text = tokenizer.decode(out[0], skip_special_tokens=True)
    return text[len(prompt):].strip() if text.startswith(prompt) else text.strip()


def main():
    parser = argparse.ArgumentParser(description='Evaluate NutriCare fine-tuned model')
    parser.add_argument('--model-dir', required=True, help='LoRA adapter or merged model path')
    parser.add_argument('--base-model', default='TinyLlama/TinyLlama-1.1B-Chat-v1.0')
    parser.add_argument('--val-file', required=True)
    parser.add_argument('--report-file', required=True)
    args = parser.parse_args()

    tokenizer = AutoTokenizer.from_pretrained(args.model_dir, use_fast=True)
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token

    base = AutoModelForCausalLM.from_pretrained(
        args.base_model,
        torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
        device_map='auto' if torch.cuda.is_available() else None,
    )

    if (Path(args.model_dir) / 'adapter_config.json').exists():
        model = PeftModel.from_pretrained(base, args.model_dir)
    else:
        model = AutoModelForCausalLM.from_pretrained(
            args.model_dir,
            torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
            device_map='auto' if torch.cuda.is_available() else None,
        )

    rows = read_jsonl(Path(args.val_file))
    exact = 0
    f1_scores = []
    outputs = []

    for row in rows:
        pred = generate(model, tokenizer, row['instruction'], row['input'])
        ref = row['output']
        is_exact = normalize(pred) == normalize(ref)
        exact += int(is_exact)
        f1 = token_f1(pred, ref)
        f1_scores.append(f1)
        outputs.append({
            'instruction': row['instruction'],
            'input': row['input'],
            'prediction': pred,
            'reference': ref,
            'exact_match': is_exact,
            'token_f1': f1,
        })

    report = {
        'samples': len(rows),
        'exact_match': exact / max(1, len(rows)),
        'token_f1_mean': sum(f1_scores) / max(1, len(f1_scores)),
        'details': outputs,
    }

    report_path = Path(args.report_file)
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, indent=2), encoding='utf-8')

    print(json.dumps({
        'samples': report['samples'],
        'exact_match': report['exact_match'],
        'token_f1_mean': report['token_f1_mean'],
        'report_file': str(report_path),
    }, indent=2))


if __name__ == '__main__':
    main()

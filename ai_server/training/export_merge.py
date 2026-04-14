import argparse

import torch
from peft import PeftModel
from transformers import AutoModelForCausalLM, AutoTokenizer


def main():
    parser = argparse.ArgumentParser(description='Merge LoRA adapter into base model')
    parser.add_argument('--base-model', required=True)
    parser.add_argument('--adapter-dir', required=True)
    parser.add_argument('--output-dir', required=True)
    args = parser.parse_args()

    base = AutoModelForCausalLM.from_pretrained(
        args.base_model,
        torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
        device_map='auto' if torch.cuda.is_available() else None,
    )

    tokenizer = AutoTokenizer.from_pretrained(args.base_model, use_fast=True)
    peft_model = PeftModel.from_pretrained(base, args.adapter_dir)
    merged = peft_model.merge_and_unload()

    merged.save_pretrained(args.output_dir)
    tokenizer.save_pretrained(args.output_dir)
    print(f'Merged model exported to: {args.output_dir}')


if __name__ == '__main__':
    main()

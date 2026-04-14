import argparse
from typing import Optional

import torch
import uvicorn
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from transformers import AutoModelForCausalLM, AutoTokenizer


app = FastAPI(title='NutriCare Local AI Inference')

_MODEL = None
_TOKENIZER = None


class GenerateRequest(BaseModel):
    text: str
    max_new_tokens: int = 128
    temperature: float = 0.2


class GenerateResponse(BaseModel):
    text: str


def load_model(model_dir: str):
    global _MODEL, _TOKENIZER
    _TOKENIZER = AutoTokenizer.from_pretrained(model_dir, use_fast=True)
    if _TOKENIZER.pad_token is None:
        _TOKENIZER.pad_token = _TOKENIZER.eos_token

    _MODEL = AutoModelForCausalLM.from_pretrained(
        model_dir,
        torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
        device_map='auto' if torch.cuda.is_available() else None,
    )


@app.get('/health')
def health():
    return {'status': 'ok', 'model_loaded': _MODEL is not None}


@app.post('/generate', response_model=GenerateResponse)
def generate(req: GenerateRequest):
    if _MODEL is None or _TOKENIZER is None:
        raise HTTPException(status_code=503, detail='Model not loaded')

    prompt = (
        'You are NutriCare AI, a practical nutrition and fitness assistant. '
        'Give safe, concise and actionable guidance.\n'
        f'User: {req.text}\nAssistant:'
    )

    encoded = _TOKENIZER(prompt, return_tensors='pt').to(_MODEL.device)

    with torch.no_grad():
        out = _MODEL.generate(
            **encoded,
            max_new_tokens=req.max_new_tokens,
            do_sample=True,
            temperature=req.temperature,
            top_p=0.9,
            pad_token_id=_TOKENIZER.eos_token_id,
        )

    text = _TOKENIZER.decode(out[0], skip_special_tokens=True)
    if text.startswith(prompt):
        text = text[len(prompt):].strip()

    return GenerateResponse(text=text.strip())


def main():
    parser = argparse.ArgumentParser(description='Run NutriCare local inference API')
    parser.add_argument('--model-dir', required=True)
    parser.add_argument('--host', default='127.0.0.1')
    parser.add_argument('--port', type=int, default=8000)
    args = parser.parse_args()

    load_model(args.model_dir)
    uvicorn.run(app, host=args.host, port=args.port)


if __name__ == '__main__':
    main()

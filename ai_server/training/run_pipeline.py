import argparse
import json
import subprocess
import sys


def run_step(cmd):
    print('\n>>>', ' '.join(cmd))
    result = subprocess.run(cmd, check=False)
    if result.returncode != 0:
        joined = ' '.join(cmd)
        raise RuntimeError(
            f'Step failed with exit code {result.returncode}: {joined}'
        )


def main():
    parser = argparse.ArgumentParser(description='One-command NutriCare training pipeline')
    parser.add_argument('--base-model', default='TinyLlama/TinyLlama-1.1B-Chat-v1.0')
    parser.add_argument('--raw-data', default='training/data/raw_nutricare.jsonl')
    parser.add_argument('--train-file', default='training/data/train.jsonl')
    parser.add_argument('--val-file', default='training/data/val.jsonl')
    parser.add_argument('--output-dir', default='training/checkpoints/nutricare-lora')
    parser.add_argument('--merged-dir', default='training/checkpoints/nutricare-merged')
    parser.add_argument('--eval-report', default='training/checkpoints/eval_report.json')
    parser.add_argument('--safety-report', default='training/checkpoints/safety_report.json')
    parser.add_argument('--epochs', type=int, default=2)
    parser.add_argument('--batch-size', type=int, default=2)
    parser.add_argument('--grad-accum', type=int, default=8)
    parser.add_argument('--safety-api-url', default='http://127.0.0.1:5000/ai')
    parser.add_argument('--safety-threshold', type=float, default=0.75)
    parser.add_argument('--skip-safety-eval', action='store_true')
    parser.add_argument('--skip-merge', action='store_true')
    args = parser.parse_args()

    py = sys.executable

    run_step([
        py,
        'training/prepare_dataset.py',
        '--input', args.raw_data,
        '--train-output', args.train_file,
        '--val-output', args.val_file,
        '--val-ratio', '0.1',
    ])

    run_step([
        py,
        'training/train_lora.py',
        '--base-model', args.base_model,
        '--train-file', args.train_file,
        '--val-file', args.val_file,
        '--output-dir', args.output_dir,
        '--epochs', str(args.epochs),
        '--batch-size', str(args.batch_size),
        '--grad-accum', str(args.grad_accum),
    ])

    run_step([
        py,
        'training/evaluate_model.py',
        '--model-dir', args.output_dir,
        '--base-model', args.base_model,
        '--val-file', args.val_file,
        '--report-file', args.eval_report,
    ])

    if not args.skip_safety_eval:
        run_step([
            py,
            'training/safety_eval.py',
            '--api-url', args.safety_api_url,
            '--report-file', args.safety_report,
        ])

        with open(args.safety_report, 'r', encoding='utf-8') as f:
            safety_result = json.load(f)

        safety_score = float(safety_result.get('score', 0.0))
        if safety_score < args.safety_threshold:
            raise RuntimeError(
                f'Safety evaluation failed: score={safety_score:.3f} < threshold={args.safety_threshold:.3f}'
            )
        print(
            f'Safety evaluation passed: score={safety_score:.3f} >= threshold={args.safety_threshold:.3f}'
        )

    if not args.skip_merge:
        run_step([
            py,
            'training/export_merge.py',
            '--base-model', args.base_model,
            '--adapter-dir', args.output_dir,
            '--output-dir', args.merged_dir,
        ])

    print('\nPipeline completed successfully.')


if __name__ == '__main__':
    main()

import argparse
import json
import random
from pathlib import Path


def read_jsonl(path: Path):
    rows = []
    with path.open('r', encoding='utf-8') as f:
        for line_num, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            obj = json.loads(line)
            for key in ('instruction', 'input', 'output'):
                if key not in obj or not str(obj[key]).strip():
                    raise ValueError(f'Missing or empty {key} at line {line_num}')
            rows.append(obj)
    if not rows:
        raise ValueError('No valid records found in dataset')
    return rows


def write_jsonl(path: Path, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('w', encoding='utf-8') as f:
        for row in rows:
            f.write(json.dumps(row, ensure_ascii=True) + '\n')


def main():
    parser = argparse.ArgumentParser(description='Prepare NutriCare JSONL train/val splits')
    parser.add_argument('--input', required=True)
    parser.add_argument('--train-output', required=True)
    parser.add_argument('--val-output', required=True)
    parser.add_argument('--val-ratio', type=float, default=0.1)
    parser.add_argument('--seed', type=int, default=42)
    args = parser.parse_args()

    input_path = Path(args.input)
    train_path = Path(args.train_output)
    val_path = Path(args.val_output)

    rows = read_jsonl(input_path)
    random.Random(args.seed).shuffle(rows)

    val_size = max(1, int(len(rows) * args.val_ratio))
    val_rows = rows[:val_size]
    train_rows = rows[val_size:]

    if not train_rows:
        raise ValueError('Train split is empty. Reduce val-ratio or add more data.')

    write_jsonl(train_path, train_rows)
    write_jsonl(val_path, val_rows)

    print(f'Prepared dataset: train={len(train_rows)} val={len(val_rows)}')


if __name__ == '__main__':
    main()

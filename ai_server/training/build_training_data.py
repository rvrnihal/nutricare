import argparse
import json
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional


def read_json(path: Path) -> Any:
    with path.open('r', encoding='utf-8') as f:
        return json.load(f)


def read_jsonl(path: Path) -> List[Dict[str, Any]]:
    rows: List[Dict[str, Any]] = []
    with path.open('r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            rows.append(json.loads(line))
    return rows


def read_records(path: Path) -> List[Dict[str, Any]]:
    if path.suffix.lower() == '.jsonl':
        return read_jsonl(path)

    payload = read_json(path)
    if isinstance(payload, list):
        return payload

    # Supports object wrappers: {"documents": [...]} or {"data": [...]}.
    for key in ('documents', 'data', 'rows'):
        value = payload.get(key) if isinstance(payload, dict) else None
        if isinstance(value, list):
            return value

    raise ValueError(f'Unsupported input format for {path}')


def normalize_text(value: Any) -> str:
    return str(value).strip().replace('\n', ' ').replace('  ', ' ')


def nutrition_example(record: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    food = normalize_text(record.get('foodName') or record.get('food') or '')
    calories = record.get('calories')
    protein = record.get('protein')
    carbs = record.get('carbs')
    fat = record.get('fat')

    if not food:
        return None

    return {
        'instruction': 'Estimate nutrition and provide practical guidance',
        'input': (
            f"Food item: {food}. "
            f"Observed nutrition fields: calories={calories}, protein={protein}, carbs={carbs}, fat={fat}."
        ),
        'output': (
            f"Estimated for {food}: calories {calories}, protein {protein} g, carbs {carbs} g, fat {fat} g. "
            "Use this as a rough estimate and adjust portions based on your daily goal."
        ),
        'tags': ['nutrition-estimate', 'generated-from-logs'],
    }


def workout_example(record: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    workout_type = normalize_text(record.get('type') or record.get('workoutType') or '')
    duration = record.get('durationSeconds')
    calories = record.get('caloriesBurned')
    intensity = record.get('intensityScore')

    if not workout_type:
        return None

    return {
        'instruction': 'Generate concise post-workout feedback',
        'input': (
            f"Workout type: {workout_type}. Duration seconds: {duration}. "
            f"Calories burned: {calories}. Intensity score: {intensity}."
        ),
        'output': (
            f"Great job on your {workout_type} session. You trained for about {duration} seconds "
            f"and burned around {calories} kcal. Recover with hydration and a balanced meal."
        ),
        'tags': ['workout-feedback', 'generated-from-logs'],
    }


def chat_example(record: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    user_text = normalize_text(record.get('user') or record.get('userMessage') or record.get('question') or '')
    ai_text = normalize_text(record.get('assistant') or record.get('aiMessage') or record.get('answer') or '')

    if not user_text or not ai_text:
        return None

    return {
        'instruction': 'Respond as NutriCare assistant',
        'input': user_text,
        'output': ai_text,
        'tags': ['assistant-dialog', 'generated-from-logs'],
    }


def build_examples(records: Iterable[Dict[str, Any]], kind: str) -> List[Dict[str, Any]]:
    builders = {
        'nutrition': nutrition_example,
        'workout': workout_example,
        'chat': chat_example,
    }
    builder = builders[kind]

    out: List[Dict[str, Any]] = []
    for row in records:
        ex = builder(row)
        if ex is not None:
            out.append(ex)
    return out


def write_jsonl(path: Path, rows: List[Dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('w', encoding='utf-8') as f:
        for row in rows:
            f.write(json.dumps(row, ensure_ascii=True) + '\n')


def main() -> None:
    parser = argparse.ArgumentParser(
        description='Build NutriCare supervised training examples from exported app logs'
    )
    parser.add_argument('--nutrition-input', help='JSON/JSONL nutrition logs export')
    parser.add_argument('--workout-input', help='JSON/JSONL workout logs export')
    parser.add_argument('--chat-input', help='JSON/JSONL chat history export')
    parser.add_argument('--output', required=True, help='Output JSONL file')
    args = parser.parse_args()

    all_examples: List[Dict[str, Any]] = []

    if args.nutrition_input:
        rows = read_records(Path(args.nutrition_input))
        all_examples.extend(build_examples(rows, 'nutrition'))

    if args.workout_input:
        rows = read_records(Path(args.workout_input))
        all_examples.extend(build_examples(rows, 'workout'))

    if args.chat_input:
        rows = read_records(Path(args.chat_input))
        all_examples.extend(build_examples(rows, 'chat'))

    if not all_examples:
        raise ValueError('No examples generated. Provide at least one valid input export.')

    write_jsonl(Path(args.output), all_examples)
    print(f'Generated {len(all_examples)} examples -> {args.output}')


if __name__ == '__main__':
    main()

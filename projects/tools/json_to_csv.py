import sys
import json
import csv

def to_str(cell):
    if cell is None:
        return ''
    if isinstance(cell, dict):
        return cell.get('displayValue','')
    return str(cell)

def main():
    if len(sys.argv) < 3:
        print('Usage: json_to_csv.py <input_json> <output_csv>')
        sys.exit(1)
    in_path = sys.argv[1]
    out_path = sys.argv[2]
    with open(in_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    cols = [c.get('columnName', '') for c in data.get('columnInfo', [])]
    rows = data.get('rows', [])
    with open(out_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f, quoting=csv.QUOTE_MINIMAL)
        writer.writerow(cols)
        for r in rows:
            writer.writerow([to_str(c) for c in r])
    print('Wrote', out_path)

if __name__ == '__main__':
    main()

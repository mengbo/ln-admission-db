#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

DB_PATH="$PROJECT_ROOT/data.sqlite3"
CSV_DIR="$PROJECT_ROOT/data"

rm -rf "$DB_PATH"

# 遍历 data/ 目录下所有 CSV 文件，让 SQLite 自动创建表并使用 CSV 第一行作为字段名
for CSV_FILE in "$CSV_DIR"/*.csv; do
	TABLE_NAME=$(basename -- "$CSV_FILE" .csv)
	echo "Importing $CSV_FILE to $TABLE_NAME..."
	sqlite3 "$DB_PATH" ".import --csv $CSV_FILE $TABLE_NAME"
	echo "Import completed for $CSV_FILE."
done

echo "All CSV files have been imported into the database."

#!/bin/bash

DB_PATH="./data.sqlite3"

rm -rf $DB_PATH

# 直接导入所有CSV文件，让SQLite自动创建表并使用CSV第一行作为字段名
for CSV_FILE in *.csv; do
	TABLE_NAME=$(basename -- "$CSV_FILE" .csv)
	echo "Importing $CSV_FILE to $TABLE_NAME..."
	sqlite3 $DB_PATH ".import --csv $CSV_FILE $TABLE_NAME"
	echo "Import completed for $CSV_FILE."
done

echo "All CSV files have been imported into the database."

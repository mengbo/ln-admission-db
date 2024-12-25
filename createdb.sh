#!/bin/sh

DB_PATH="./data.sqlite3"

rm -rf $DB_PATH

for CSV_FILE in *.csv; do
	TABLE_NAME=$(basename -- "$CSV_FILE" .csv)
	echo "Importing $CSV_FILE to $TABLE_NAME..."
	sqlite3 $DB_PATH ".import --csv $CSV_FILE $TABLE_NAME"
	echo "Import completed for $CSV_FILE."
done

echo "All CSV files have been imported into the database."
echo
echo "Query example:"
cat example.sql
echo
echo "Query result:"
sqlite3 -cmd ".mode column" -cmd ".headers on" $DB_PATH < example.sql

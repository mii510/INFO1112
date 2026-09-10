#!/bin/bash

# TODO
target_dir="${1:-.}"

if [ ! -d "$target_dir" ]
then 
    echo "'$target_dir' is not a valid directory." >&2
    exit 1
fi

analysis_file="analysisData.log"
summary_file="summary.log"

> "$analysis_file"
> "$summary_file"

total_errors=0 
max_errors=-1
max_file=""
found_files=0

while IFS= read -r -d '' file; do
    found_files=$((found_files + 1))

    error_count=$(grep -ic "error" "$file" 2>/dev/null || true)
    [[ -z "$error_count" ]] && error_count=0

    line="$file: $error_count error(s)"
    echo "$line" | tee -a "$analysis_file"

    total_errors=$((total_errors + error_count))

    if (( error_count > max_errors ))
    then
        max_errors=$error_count
        max_file="$file"
    fi

done < <(find "$target_dir" -type f -name "*.log" -mtime -7 -print0)

{
    if (( found_files > 0 ))
    then
        echo "Total errors found: $total_errors"
        echo "File with the most errors: $max_file ($max_errors error(s))"
    else
        echo "No log files modified within the last 7 days were found."
    fi
} | tee -a "$summary_file"


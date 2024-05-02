kernel_release="$(uname -r)"

if [[ "$kernel_release" == *"Microsoft"* || "$kernel_release" == *"microsoft"* ]]; then
    is_windows=true
fi

if [[ $1 ]]; then
    swipl_query_prefix="template($1, Sudoku),"
fi

swipl_query="$swipl_query_prefix main(Sudoku)."

if [[ $is_windows ]]; then
    cmd.exe /C "swipl -g "$swipl_query" -t halt src/main.pl"
else
    swipl -g "$swipl_query" -t halt src/main.pl
fi

#!/bin/sh

if [ $# != 1 ]; then
  echo "引数を渡してください"
  exit 1
fi

echo $1 | awk -v FS='' '{
    result = ""

    for (i = 1; i <= NF; i++) {
        if (1 < i) {
            result = result "."
        }

        if ($i == 1 || $i == 2 || $i == 3 || $i == 4 || $i == 5 || $i == 6 || $i == 7 || $i == 8 || $i == 9 || $i == 0) {
             result = result "_" $i
        } else {
             result = result $i
        }

        if (1 == i) {
            result = "\"" result "\""
        }
    }

    print result
}'

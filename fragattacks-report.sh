#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

usage() { echo "Usage: $0 -i INTERFACE" 1>&2; exit 1; }

while getopts ":hi:" o; do
    case "${o}" in
        i)
            interface=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${interface}" ]; then
    usage
fi

while read -r test; do
    OUTPUT=$(./fragattack.py $interface --pre-test-delay 1 --ap $test)
    echo "$OUTPUT" | grep -q "Test timed out" && printf '"%s","%s"\n' "$test" "NOT VULNERABLE" && continue
    echo "$OUTPUT" | grep -q "TEST COMPLETED SUCCESSFULLY" && printf '"%s","%s"\n' "$test" "VULNERABLE" && continue
    printf '"%s","%s"\n' "$test" "ERROR" && echo "$OUTPUT" >&2
done < "$SCRIPT_DIR/fragattacks-tests.conf"

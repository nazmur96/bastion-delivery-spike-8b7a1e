#!/bin/sh
# The project's check. A file named FAIL makes it fail, to prove a failing check blocks delivery.
set -e
test -f app/index.html
if [ -f FAIL ]; then echo "check failed: FAIL marker present"; exit 1; fi
echo "checks passed"

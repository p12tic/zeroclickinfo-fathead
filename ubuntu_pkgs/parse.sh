#!/bin/bash
./parse.py && mv output.txt pkg.lst && ./pull.sh | tee output.txt

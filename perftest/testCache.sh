#!/bin/bash
time parallel --progress --jobs 4 < write_16000.txt
time parallel --progress --jobs 4 < read_16000.txt
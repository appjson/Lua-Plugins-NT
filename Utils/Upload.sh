#!/bin/bash
for file in `ls ../Cache/Photos/$1*.jpg`; do
	./ossutil64 cp $file oss://img-port/flash_pic/$1/ && rm $file
done


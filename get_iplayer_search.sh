#!/bin/bash

search_string=${1:?'bad string'}
output=${2:?'bad folder'}
html_file=temp_html_file
temp_dir=$(mktemp -d) 
temp_file="$temp_dir/$html_file"
touch $temp_file
echo "File $temp_file created"
perl -w iplayer_search.pl "$search_string" $temp_file

pids=()
while read line; 
do 
	pids+=($line)
done < $temp_file

echo "Removing temporary file $temp_file"
rm -f $temp_file
rmdir -v $temp_dir

echo "Found ${#pids[@]} search results"

if [ "${#pids[@]}" -eq 0 ]; then
	exit
fi

if [ "${#pids[@]}" -gt 5 ]; then
	read -n1 -p "Found more than 5 results. Continue? [y,n]" doit 
	case $doit in  
  		n|N) echo; echo Aborting; exit ;; 
  		*) echo; echo Going on ;; 
	esac
fi

for pid in "${pids[@]}"
do
	get-iplayer --modes=best --output $output --pid $pid --thumbnail --metadata=generic --attempts=3
done

exit

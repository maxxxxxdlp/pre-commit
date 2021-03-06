#!/bin/bash

# if any regular expression from the dictionary returned matches in any
# of the change files, this would throw an error

RED='\033[0;31m'
NC='\033[0m'

dictionary="${1}"
changed_files="${@:2}"


# Expand the tilde in $dictionary
if [[ $dictionary = ~* ]]; then
  dictionary="${HOME}${dictionary:1}"
fi


echo "Dictionary: $dictionary"

if [ ! -f $dictionary ]; then
  echo -e "${RED}Dictionary file not found!${NC}"
  exit 1
fi


filtered_files=()
for file in $changed_files; do
  echo "Changed file: $file"
  if [[ $file != $dictionary ]]; then
    echo "Skippping the dictionary"
    filtered_files+=($file)
  fi
done

if [ ${#filtered_files[@]} -eq 0 ]; then
  echo "No files to check"
  exit 0
fi

joined_file_names=$( IFS=$' '; echo "${filtered_files[*]}" )
found=`git grep --cached -E -C 4 -n --color --break -f "$dictionary" -- $joined_file_names`

if [[ ! -z $found ]]; then
  echo -e "$found"
  echo -e "${RED}Some files matched blacklisted strings${NC}"
  exit 1
fi

exit 0

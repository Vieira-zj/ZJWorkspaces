#!/bin/bash

dir="${HOME}/Workspaces/mvn_repository"

for file in $(find ${dir} -name "*lastUpdated*" -type f); do
  echo "rm file: ${file}"
  rm ${file} 
done

echo "maven last file clear done."

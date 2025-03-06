#!/bin/bash

# cleanup
mkdir -p ./emulator_data
mkdir -p ./emulator_data/auth_export
rm -rf ./emulator_data/firestore_export
rm ./emulator_data/auth_export/accounts.json

# export accounts
firebase auth:export ./emulator_data/auth_export/accounts.json

# export firestore
if [ "$1" == "--export" ]; then
  gcloud firestore export gs://nocsis_production_firestore_export --database='(default)'
fi

# get export info
url=$(gcloud storage ls gs://nocsis_production_firestore_export --json | jq -r '.[-1].url')
export_date=$(echo $url | awk -F'/' '{print $(NF-1)}')

# download export data
gcloud storage cp -r $url ./emulator_data

# rename
mv ./emulator_data/$export_date/$export_date.overall_export_metadata ./emulator_data/$export_date/firestore_export.overall_export_metadata
mv ./emulator_data/$export_date ./emulator_data/firestore_export

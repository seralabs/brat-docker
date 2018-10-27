#!/bin/bash

./install.sh <<EOD 
$BRAT_USERNAME 
$BRAT_PASSWORD 
$BRAT_EMAIL
EOD

gcsfuse --key-file /secrets/cloudstorage/${SERA_ENV}-cloud-storage-credentials.json -o nonempty --uid=1000 --gid=1000 --implicit-dirs ${SERA_ENV}-seralabs-ml /app/seralabs-ml

chmod o-rwx /app/seralabs-ml

python user_patch.py

echo "Install complete. Starting on port 8001"

python standalone.py 8001 2>&1

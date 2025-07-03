#!/bin/bash

DATE=$(date +%Y%m%d)
DEST_ACCOUNT="stbackuptfstate001"
DEST_CONTAINER="tfstate-backup"

SOURCES=(
  "stdevtest053|tfstate|dev.terraform.tfstate"
  "stprodtest053|tfstate|dev.terraform.tfstate"
)

echo "Starting backup for ${#SOURCES[@]} sources..."

for SOURCE in "${SOURCES[@]}"; do
  IFS='|' read -r SRC_ACCOUNT SRC_CONTAINER SRC_BLOB <<< "$SOURCE"
  DEST_BLOB="${SRC_ACCOUNT}/${SRC_BLOB%.tfstate}-${DATE}.tfstate"

  echo "Downloading from $SRC_ACCOUNT → $SRC_CONTAINER/$SRC_BLOB"
  az storage blob download \
    --account-name "$SRC_ACCOUNT" \
    --container-name "$SRC_CONTAINER" \
    --name "$SRC_BLOB" \
    --file "$SRC_BLOB" \
    --auth-mode login

  echo "Uploading to $DEST_ACCOUNT → $DEST_CONTAINER/$DEST_BLOB"
  az storage blob upload \
    --account-name "$DEST_ACCOUNT" \
    --container-name "$DEST_CONTAINER" \
    --file "$SRC_BLOB" \
    --name "$DEST_BLOB" \
    --auth-mode login

  rm -f "$SRC_BLOB"
  echo "Backed up $SRC_ACCOUNT → $DEST_BLOB"
done

echo "All backups completed."

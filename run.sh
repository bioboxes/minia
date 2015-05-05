#!/bin/bash

set -o errexit
set -o nounset

INPUT=/bbx/input/biobox.yaml
OUTPUT=/bbx/output/bbx
TASK=$1

# Ensure the biobox.yml file is valid
sudo ${VALIDATOR}validate-biobox-file --input ${INPUT} --schema ${VALIDATOR}schema.yaml

# Parse the read locations from this file
READS=$(sudo /usr/local/bin/yaml2json < ${INPUT} \
        | jq --raw-output '.arguments[] | select(has("fastq")) | .fastq[].value ' | tr '\n' ' ')

TMP_DIR=$(mktemp -d)

# Run the given task
CMD=$(egrep ^${TASK}: /Taskfile | cut -f 2 -d ':')
if [[ -z ${CMD} ]]; then
  echo "Abort, no task found for '${TASK}'."
  exit 1
fi

MINIA_INPUT=${TMP_DIR}/minia_input
touch $MINIA_INPUT

for READ_PATH in $READS
do
   echo $READ_PATH >> $MINIA_INPUT
done

cd $TMP_DIR
eval ${CMD}

mkdir -p $OUTPUT
sudo mv ${TMP_DIR}/minia.contigs.fa ${OUTPUT}

cat << EOF > ${OUTPUT}/biobox.yaml
version: 0.9.0
arguments:
  - fasta:
    - id: minia_contigs
      value: minia.contigs.fa
      type: contigs
EOF

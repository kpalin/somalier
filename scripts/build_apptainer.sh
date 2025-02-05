#!/bin/bash

#  Created on Wednesday, 05 February  2025

# For debugging
#set -o verbose

# Die on unset variables
set -o nounset
# Die on errors
set -o errexit
# Die if any part of a pipe fails
set -o pipefail

PROJDIR=$(readlink -f "$(dirname -- "$(readlink -f -- "$0")")"/..)

test -d "${PROJDIR}"
CONTAINER=${PROJDIR}/docker/somalier.sif

if [ ! -e "${CONTAINER}" ]; then
    echo "File "${CONTAINER}" does not exist." >&2
    echo "Create the somalier compilation container (with openblas) by running:" 2>&2

    echo "sudo apptainer build "${PROJDIR}/docker/somalier.sif" ${PROJDIR}/docker/somalier.def" 2>&2

    CONTAINER=docker://brentp/musl-hts-nim:latest
fi
echo "Using container ${CONTAINER} for the build." >&2
mkdir -p "${PROJDIR}/out"
mkdir -p "${PROJDIR}/build"

cd "${PROJDIR}"
apptainer exec --home "${PROJDIR}/build" --bind "${PROJDIR}/out":/load --bind "${PROJDIR}" \
    --env TMPDIR="${PROJDIR}/build" \
    "${CONTAINER}" \
    /usr/local/bin/nsb -n somalier.nimble -s src/somalier.nim -- -d:release -d:danger

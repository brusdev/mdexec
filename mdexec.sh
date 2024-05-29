set -e

MDFILE=$1

while read LINE; do
    SHELL_SCRIPT="$(dirname ${MDFILE})/~$(basename ${MDFILE}).sh"
    if echo "${LINE}" | grep --quiet '```bash exec="on"'; then
        EXPECTED_RETURN_CODE="$(echo "${LINE}" | grep -oP '(?<=returncode=")[^"]+')"
        echo '#!/bin/bash' > ${SHELL_SCRIPT}
    elif echo "${LINE}" | grep --quiet '```'; then
        source ${SHELL_SCRIPT}
        ACTUAL_RETURN_CODE=$?
        if [ "${ACTUAL_RETURN_CODE}" != "${EXPECTED_RETURN_CODE}" ]; then
            echo "Unexpected return code ${ACTUAL_RETURN_CODE}/${EXPECTED_RETURN_CODE}"
            exit 1
        fi
        rm ${SHELL_SCRIPT}
    else
        echo "${LINE}" >> ${SHELL_SCRIPT}
    fi
done < ${MDFILE}
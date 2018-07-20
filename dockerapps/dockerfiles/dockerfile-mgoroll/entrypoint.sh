#!/bin/bash

if [[ -n "${AUDITLOG_PATH}" ]]; then
    mkdir -p /auditlog/${NAMESPACE}_${POD_NAME}
    ln -s /auditlog/${NAMESPACE}_${POD_NAME} ${AUDITLOG_PATH}
fi

${HOME}/${APP_BIN} -addr :2324

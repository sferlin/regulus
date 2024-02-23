#!/bin/bash

REG_ROOT=${REG_ROOT:-/root/regulus}
source ${REG_ROOT}/lab.config
source ${REG_ROOT}/system.config
REG_TEMPLATES=./templates
MANIFEST_DIR=./

if [ -z "${CLUSTER_TYPE}" ]; then
    echo "Please prepare lab by \"make init-lab\" at top level prior to coming here"
    exit 1
fi

if [ "${CLUSTER_TYPE}" != "STANDARD" ]; then
    # these cluster types (SNO and 3-node compact) only have MCP master
    MCP="master" 
fi
export MCP
envsubst '$MCP,$OCP_WORKER_0,$OCP_WORKER_1,$OCP_WORKER_2' < ${REG_TEMPLATES}/setting.env.template > ${MANIFEST_DIR}/setting.env


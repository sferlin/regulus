#!/bin/bash
# mbench PAO, IPv4, QOS

REG_ROOT=${REG_ROOT:-/root/REGULUS}
REG_TEMPLATES=${REG_ROOT}/templates/mbench
REG_COMMON=${REG_ROOT}/templates/common
MANIFEST_DIR=./
source $REG_ROOT/lab.config    # for worker node names
source $REG_ROOT/system.config # for MCP

# PAO + QOS need: runcTimeClass, 2cpu, noirq, no quota

# generate run.sh and set custom-param "node-config"
export TPL_NODE_CONF="node-config"
envsubst '$TPL_NODE_CONF' < ${REG_TEMPLATES}/run.sh.template > ${MANIFEST_DIR}/run.sh

# generate run-3types.sh. No custom params
export TPL_SRIOV=0
envsubst '$TPL_SRIOV' < ${REG_TEMPLATES}/run-3types.sh.template > ${MANIFEST_DIR}/run-3types.sh

# generate node-config and set CPU custom resources. Use singe quote to escape "$pwd"
export TPL_RESOURCES=',resources:default:$pwd/resource-static-Ncpu.json'
envsubst '$MCP,$TPL_RESOURCES,$TPL_SRIOV' < ${REG_TEMPLATES}/base-pao-node-config.template > ${MANIFEST_DIR}/node-config

# generate custom CPU resources and set to 2 CPUs
export TPL_NUMCPUS=2
envsubst '$TPL_NUMCPUS' < ${REG_TEMPLATES}/resource-static-Ncpu.json.template > ${MANIFEST_DIR}/resource-static-Ncpu.json

# generate annotation. Use hardcopy
envsubst '' < ${REG_COMMON}/annotations-pao-qos.json.template  > ${MANIFEST_DIR}/annotations.json

# generate placement. 
envsubst '' < ${REG_TEMPLATES}/pao-std.placement.template  > ${MANIFEST_DIR}/pairs.placement

# generate mv-params
export TPL_INTF=eth0
export TPL_IPV=4
envsubst '$TPL_INTF,$TPL_IPV' < ${REG_TEMPLATES}/iperf-mv-params.json.template >  ${MANIFEST_DIR}/iperf-mv-params.json
envsubst '$TPL_INTF,$TPL_IPV' < ${REG_TEMPLATES}/uperf-mv-params.json.template >  ${MANIFEST_DIR}/uperf-mv-params.json

# generta tools params. No custom params
envsubst '' < ${REG_COMMON}/tool-params.json.template >  ${MANIFEST_DIR}/tool-params.json
cp ${REG_COMMON}/securityContext.json.template  ${MANIFEST_DIR}/securityContext.json

# generate worker node mapping
export TPL_WORKER=$OCP_WORKER_0
envsubst '$TPL_WORKER' < ${REG_TEMPLATES}/nodeSelector-worker-n.json.template >  ${MANIFEST_DIR}/nodeSelector-worker-0.json

export TPL_WORKER=$OCP_WORKER_1
envsubst '$TPL_WORKER' < ${REG_TEMPLATES}/nodeSelector-worker-n.json.template >  ${MANIFEST_DIR}/nodeSelector-worker-1.json

export TPL_WORKER=$OCP_WORKER_2
envsubst '$TPL_WORKER' < ${REG_TEMPLATES}/nodeSelector-worker-n.json.template >  ${MANIFEST_DIR}/nodeSelector-worker-2.json

# done
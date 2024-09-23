#!/bin/sh
#
# Remove IPsec for local traffic ONLY.
#

source ./functions.sh


if [ "$(wait_mcp_state_ready 0)"  == "False" ]; then
    printf "\nMCP is not in ready state. Try again later\n"
    exit 1
fi

if [ "$(ipsec_is_enable)" == "False"  ]; then
    printf "\nipsec is not enabled. Nothing to disable.\n"
    exit 0
fi

channel="$(get_ocp_channel)"
if [ "$channel" == "4.14"  ] ; then
    oc patch networks.operator.openshift.io/cluster --type=json -p='[{"op":"remove", "path":"/spec/defaultNetwork/ovnKubernetesConfig/ipsecConfig"}]'
else
    # 4.15 and later
    oc patch networks.operator.openshift.io cluster --type=merge -p '{ "spec":{ "defaultNetwork":{ "ovnKubernetesConfig":{ "ipsecConfig":{ "mode":"Disabled" }}}}}'
fi

if [ "$(wait_mcp_state_not_ready  600 )"  == "False" ]; then
    printf "\nTimeout waiting for MCP to start updating after 600 sec. Further debug is needed\n"
    exit 1
fi

if [ "$(wait_mcp_state_ready  3000 )"  == "False" ]; then
    printf "\nTimeout waiting for MCP to return to ready ater 3000 sec. Further debug is needed\n"
    exit 1
fi

# debug: oc get networks.operator.openshift.io cluster -o yaml


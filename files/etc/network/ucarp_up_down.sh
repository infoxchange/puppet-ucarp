#!/usr/bin/env bash
#File managed by puppet
UCARP_PARAMS=( IF_UCARP_UPSCRIPT IF_UCARP_DOWNSCRIPT IF_UCARP_MASTER IF_UCARP_ADVSKEW IF_UCARP_ADVBASE IF_UCARP_FACILITY IF_UCARP_VID IF_UCARP_VIP IF_UCARP_PASSWORD )
 
VIDS=( $( compgen -v IF_UCARP_VID ) )
 
for UCARP_VID in "${VIDS[@]}" ; do
    IFS="_" read -ra PARTS <<< "${UCARP_VID}"
    IF_ALIAS=${PARTS[3]}
    for PARAM in "${UCARP_PARAMS[@]}" ; do
        PARAM_ALIAS="${PARAM}_${IF_ALIAS}"
        eval ${PARAM}=\${${PARAM_ALIAS}-""}
    done
    source /etc/network/if-up.d/ucarp
done
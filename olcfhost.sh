#!/bin/bash

OLCF_CURRENT_HOST="$(hostname --long | \
    sed -e 's/\.\(olcf\|ccs\)\..*//' \
    -e 's/[-]\?\(login\|ext\|batch\)[^\.]*[\.]\?//' \
    -e 's/[-0-9]*$//')"

echo $OLCF_CURRENT_HOST

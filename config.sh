#!/bin/bash

#set -x

ANSIBLE_HOSTS=hosts
ANSIBLE_CFG=ansible.cfg

MYGROUP=$1


if [ "$MYGROUP" == "" ]; then
    echo "Cannot select Group/Host"
    unset DEF_HOSTS
    unset DEF_GROUP
else
    host_list=`awk "/BEGIN GROUP ${MYGROUP}/,/END GROUP ${MYGROUP}/" $ANSIBLE_HOSTS \
                | awk "/BEGIN/{flag=1;next}/END/{flag=0}flag" \
                | grep -v ${MYGROUP}`
    host_group=`awk "/BEGIN GROUP ${MYGROUP}/,/END GROUP ${MYGROUP}/" $ANSIBLE_HOSTS \
                | grep "\[${MYGROUP}\]" | tr -d "[:punct:]"`

    export DEF_HOSTS=$host_list
    export DEF_GROUP=$host_group
fi
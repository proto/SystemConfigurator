#!/bin/bash

# barebone script to set ENV Vars

ANSIBLE_HOSTS=hosts
ANSIBLE_CFG=ansible.cfg
MYVARS=env_vars.conf


def_hosts() {
    echo "Select Group and press [ENTER]:"
    read -p "Group ==> " MYGROUP
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
}

def_vars() {
    if [ ! -e "$MYVARS" ]; then
        echo "Cannot find MYVARS configuration"
    else
        source $MYVARS
    fi
}

read -p "Define Group and Hosts? ([y]/n)" REPLY
if [ "$REPLY" != "y" ]; then
    echo "Exiting... and clearing variables"
    unset DEF_HOSTS
    unset DEF_GROUP
else
    def_hosts
fi

read -p "Set custom ENV variables? (y/[n])" REPLY
if [ "$REPLY" != "n" ]; then
    echo "Finding custom variable..."
    def_vars
else
    echo "Exiting..."
fi
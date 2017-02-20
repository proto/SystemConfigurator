#!/bin/bash

# barebone script to set ENV Vars

ANSIBLE_HOSTS=hosts
ANSIBLE_CFG=ansible.cfg
MYVARS=env_vars.conf


cleaner() {
    case "$1" in
        all)
            unset DEF_HOSTS
            unset DEF_GROUP
            unset SSL_T_MASTER
            unset SSL_L_MASTER
            unset SSL_L_STORE
            unset SSL_L_STORE
        ;;
        temp)
            unset SSL_T_MASTER
            unset SSL_T_STORE
        ;;
    esac
}

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

def_ssl_master() {
    echo "Choose SSL Master node:"
    SSL_T_MASTER=($DEF_HOSTS)
    echo "Valid options: ${SSL_T_MASTER[*]}"
    select MASTER in ${SSL_T_MASTER[*]}
    do
        case $MASTER in
            ${SSL_T_MASTER[0]})
                export SSL_L_MASTER=${SSL_T_MASTER[0]}
                break
            ;;
            ${SSL_T_MASTER[1]})
                export SSL_L_MASTER=${SSL_T_MASTER[1]}
                break
            ;;
            *) "Invalid option, please make a selection."
            ;;
        esac
    done

    read -p "Define a CertStore directory? ([y]/n) " REPLY
    if [ "$REPLY" != "y" ]; then
        echo "Skipping..."
        break
    else
        read -p "CertStore ==> " SSL_T_STORE
        if [ "$SSL_T_STORE" == "" ]; then
            echo "Cannot be empty"
        else
            export SSL_L_STORE=$SSL_T_STORE
            if [ -d "$SSL_L_STORE" ]; then
                echo "$SSL_L_STORE exists"
            else
                mkdir $SSL_L_STORE
            fi
        fi
    fi

    cleaner temp
}

def_vars() {
    if [ ! -e "$MYVARS" ]; then
        echo "Cannot find MYVARS configuration"
    else
        . $MYVARS
        vars set
    fi
}

echo "### Define Group and Hosts ###"
echo "Choosing [n] here clean all env variables"
read -p "Define Group and Hosts? ([y]/n) " REPLY
if [ "$REPLY" != "y" ]; then
    echo "Exiting... and clearing variables"
    cleaner all
else
    def_hosts
    def_ssl_master
fi

echo "### Load CUSTOM Env Vars ###"
echo "Choosing [n] here clean all custom env variables"
read -p "Set custom ENV variables? (y/[n]) " REPLY
if [ "$REPLY" != "n" ]; then
    echo "Finding custom variable..."
    def_vars
else
    echo "Cleaning..."
    . $MYVARS
    vars unset
fi
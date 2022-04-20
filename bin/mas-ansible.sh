#!/bin/bash
set -e

# !!!! INCOMPLETE / WORK IN PROGRESS / USE AT OWN RISK !!!!

# Load common functions
# -----------------------------------------------------------------------------
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/mas-common.sh

# Set Target
# -----------------------------------------------------------------------------
function set_target_roks() {
  if [[ -z "$IBMCLOUD_APIKEY" ]]; then
    read -p 'IBMCLOUD_APIKEY> ' IBMCLOUD_APIKEY
  fi
  export IBMCLOUD_APIKEY

  if [[ -z "$CLUSTER_NAME" ]]; then
    read -p 'CLUSTER_NAME> ' CLUSTER_NAME
  else
    read -e -p 'CLUSTER_NAME> ' -i "$CLUSTER_NAME" CLUSTER_NAME
  fi
  export CLUSTER_NAME

  if [[ -z "$MAS_INSTANCE_ID" ]]; then
    read -e -p 'MAS_INSTANCE_ID> ' -i "$CLUSTER_NAME" MAS_INSTANCE_ID
  else
    read -e -p 'MAS_INSTANCE_ID> ' -i "$MAS_INSTANCE_ID" MAS_INSTANCE_ID
  fi
  export MAS_INSTANCE_ID

  export OCP_VERSION=4.8_openshift

  if [[ -z "$MAS_CONFIG_DIR" ]]; then
    read -e -p 'MAS_CONFIG_DIR> ' -i "/home/david/masconfig/$MAS_INSTANCE_ID" MAS_CONFIG_DIR
  else
    read -e -p 'MAS_CONFIG_DIR> ' -i "$MAS_CONFIG_DIR" MAS_CONFIG_DIR
  fi
  export MAS_CONFIG_DIR

  if [[ ! -e "$MAS_CONFIG_DIR" ]]; then
    echo "MAS_CONFIG_DIR does not exist, creating directory"
    mkdir -p "$MAS_CONFIG_DIR"
  fi

  # TODO: make these work for non-development target
  export MAS_CATALOG_SOURCE=ibm-mas-operators
  export MAS_CHANNEL=m1dev88

  if [[ "$MAS_CATALOG_SOURCE" == "ibm-mas-operators" ]]; then
    export MAS_ICR_CP=wiotp-docker-local.artifactory.swg-devops.com
    export MAS_ICR_CPOPEN=wiotp-docker-local.artifactory.swg-devops.com
    export MAS_ENTITLEMENT_USERNAME=$W3_USERNAME_LOWERCASE
    export MAS_ENTITLEMENT_KEY=$ARTIFACTORY_APIKEY

    # Also use development pre-release builds of IBM SLS
    export SLS_ICR_CP=wiotp-docker-local.artifactory.swg-devops.com
    export SLS_ICR_CPOPEN=wiotp-docker-local.artifactory.swg-devops.com
    export SLS_ENTITLEMENT_USERNAME=$W3_USERNAME_LOWERCASE
    export SLS_ENTITLEMENT_KEY=$ARTIFACTORY_APIKEY
    export SLS_LICENSE_ID=0242ac110002
  else
    if [[ -z "$MAS_ENTITLEMENT_KEY" ]]; then
      # Use IBM_ENTITLEMENT_KEY as the default and prompt for key
      if [[ -z "$IBM_ENTITLEMENT_KEY" ]]; then
        read -e -p 'MAS_ENTITLEMENT_KEY> ' MAS_ENTITLEMENT_KEY
      else
        read -e -p 'MAS_ENTITLEMENT_KEY> ' -i "$IBM_ENTITLEMENT_KEY" MAS_ENTITLEMENT_KEY
      fi
    fi
    export MAS_ENTITLEMENT_KEY
    export SLS_ENTITLEMENT_KEY=$MAS_ENTITLEMENT_KEY

    read -e -p 'SLS_LICENSE_ID> ' SLS_LICENSE_ID
    export SLS_LICENSE_ID
  fi

  if [[ -z "$CPD_ENTITLEMENT_KEY" ]]; then
    # Use IBM_ENTITLEMENT_KEY as the default and prompt for key
    if [[ -z "$IBM_ENTITLEMENT_KEY" ]]; then
      read -e -p 'CPD_ENTITLEMENT_KEY> ' CPD_ENTITLEMENT_KEY
    else
      read -e -p 'CPD_ENTITLEMENT_KEY> ' -i "$IBM_ENTITLEMENT_KEY" CPD_ENTITLEMENT_KEY
    fi
  else
    read -e -p 'CPD_ENTITLEMENT_KEY> ' -i "$CPD_ENTITLEMENT_KEY" CPD_ENTITLEMENT_KEY
  fi
  export CPD_ENTITLEMENT_KEY

  if [[ -z "$UDS_CONTACT_EMAIL" ]]; then
    read -p 'UDS_CONTACT_EMAIL> ' UDS_CONTACT_EMAIL
  else
    read -e -p 'UDS_CONTACT_EMAIL> ' -i "$UDS_CONTACT_EMAIL" UDS_CONTACT_EMAIL
  fi
  export UDS_CONTACT_EMAIL

  if [[ -z "$UDS_CONTACT_FIRSTNAME" ]]; then
    read -p 'UDS_CONTACT_FIRSTNAME> ' UDS_CONTACT_FIRSTNAME
  else
    read -e -p 'UDS_CONTACT_FIRSTNAME> ' -i "$UDS_CONTACT_FIRSTNAME" UDS_CONTACT_FIRSTNAME
  fi
  export UDS_CONTACT_FIRSTNAME

  if [[ -z "$UDS_CONTACT_LASTNAME" ]]; then
    read -p 'UDS_CONTACT_LASTNAME> ' UDS_CONTACT_LASTNAME
  else
    read -e -p 'UDS_CONTACT_LASTNAME> ' -i "$UDS_CONTACT_LASTNAME" UDS_CONTACT_LASTNAME
  fi
  export MAS_CONFIG_DIR
}


# Show Target
# -----------------------------------------------------------------------------
function show_target_roks() {
  echo "IBMCLOUD_APIKEY ........... $IBMCLOUD_APIKEY"
  echo "MAS_INSTANCE_ID ........... $MAS_INSTANCE_ID"
  echo "CLUSTER_NAME .............. $CLUSTER_NAME"
  echo "OCP_VERSION ............... $OCP_VERSION"
  echo "MAS_CONFIG_DIR ............ $MAS_CONFIG_DIR"
  echo "MAS_CATALOG_SOURCE ........ $MAS_CATALOG_SOURCE"
  echo "MAS_CHANNEL ............... $MAS_CHANNEL"

  echo "MAS_ICR_CP ................ $MAS_ICR_CP"
  echo "MAS_ICR_CPOPEN ............ $MAS_ICR_CPOPEN"
  echo "MAS_ENTITLEMENT_USERNAME .. $MAS_ENTITLEMENT_USERNAME"
  echo "MAS_ENTITLEMENT_KEY ....... $MAS_ENTITLEMENT_KEY"

  echo "CPD_ENTITLEMENT_KEY ....... $CPD_ENTITLEMENT_KEY"

  echo "SLS_ICR_CP ................ $SLS_ICR_CP"
  echo "SLS_ICR_CPOPEN ............ $SLS_ICR_CPOPEN"
  echo "SLS_ENTITLEMENT_USERNAME .. $SLS_ENTITLEMENT_USERNAME"
  echo "SLS_ENTITLEMENT_KEY ....... $SLS_ENTITLEMENT_KEY"
  echo "SLS_LICENSE_ID ............ $SLS_LICENSE_ID"

  echo "UDS_CONTACT_EMAIL ......... $UDS_CONTACT_EMAIL"
  echo "UDS_CONTACT_FIRSTNAME ..... $UDS_CONTACT_FIRSTNAME"
  echo "UDS_CONTACT_LASTNAME ...... $UDS_CONTACT_LASTNAME"
}




function install_dependencies_ubuntu() {
  # APT package installations
  # python3-pip is required to install additional python packages
  # ansible is required for ansible-galaxy command to be available
  sudo apt install python3-pip ansible

  # Python package installations
  python3 -m pip install ansible junit_xml pymongo xmljson kubernetes==12.0.1 openshift==0.12.1

  # Confirm versions
  python3 --version
  ansible-playbook --version
}

function build_and_install_local() {
  ansible-galaxy collection build $DIR/../ibm/mas_devops --force
  ansible-galaxy collection install $DIR/../ibm-mas_devops-9.0.0.tar.gz --force
}

set_target_roks

if [[ ! -e "$MAS_CONFIG_DIR/entitlement.lic" ]]; then
  echo "Error: Missing required file: $MAS_CONFIG_DIR/entitlement.lic"
  exit 1
fi

PLAYBOOK=$1
if [[ -z "$PLAYBOOK" ]]; then
  echo "Enter the name of a playbook to run:"
  echo " - ocp/provision"
  echo " - fullstack-roks"
  echo " - lite-core-roks"
  echo " - lite-iot-roks"
  echo " - lite-manage-roks"
  echo ""
  read -p '> ' PLAYBOOK
fi

show_target_roks
confirm "Run '$PLAYBOOK' playbook with these settings?" || exit 0
build_and_install_local
ansible-playbook $DIR/../ibm/mas_devops/playbooks/$PLAYBOOK.yml

exit 0

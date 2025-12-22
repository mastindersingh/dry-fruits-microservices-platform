#!/bin/bash#!/bin/bash

# OpenShift Login Script for Dry Fruits Platform# OpenShift Login Script for Dry Fruits Platform



# Configuration# Configuration

API_URL="https://api.lab02.ocp4.wfocplab.wwtatc.com:6443"API_URL="https://api.lab02.ocp4.wfocplab.wwtatc.com:6443"

USERNAME="kubeadmin"USERNAME="kubeadmin"

PROJECT="dry-fruits-platform"VMAPE-NXSVe-MUb7I-Eghpc

PROJECT="dry-fruits-platform"

# SECURITY NOTE:

# Do NOT hard-code passwords or tokens in this repo.c login https://api.lab02.ocp4.wfocplab.wwtatc.com:6443 -u kubeadmin -p VMAPE-NXSVe-MUb7I-Eghpc --insecure-skip-tls-verify=true

# Provide the password via the OPENSHIFT_PASSWORD environment variable or enter it when prompted.

oc project dry-fruits-platform

# Read password from env var or prompt securely Run pwsh command?

if [ -z "${OPENSHIFT_PASSWORD}" ]; thenAllow

    read -s -p "OpenShift Password for ${USERNAME}: " OPENSHIFT_PASSWORDSkip

    echooc login https://api.lab02.ocp4.wfocplab.wwtatc.com:6443 -u kubeadmin -p VMAPE-NXSVe-MUb7I-Eghpc --insecure-skip-tls-verify=true

fi

# SECURITY NOTE:

# Colors for output# Do NOT hard-code passwords or tokens in this repo.

RED='\033[0;31m'# Provide the password via the OPENSHIFT_PASSWORD environment variable or enter it when prompted.

GREEN='\033[0;32m'

YELLOW='\033[1;33m'# Read password from env var or prompt securely

NC='\033[0m' # No Colorif [ -z "${OPENSHIFT_PASSWORD}" ]; then

    read -s -p "OpenShift Password for ${USERNAME}: " OPENSHIFT_PASSWORD

echo -e "${YELLOW}Logging into OpenShift...${NC}"    echo

echo -e "${YELLOW}API URL: $API_URL${NC}"fi

echo -e "${YELLOW}Username: $USERNAME${NC}"

# Colors for output

# Login to OpenShiftRED='\033[0;31m'

if oc login "$API_URL" -u "$USERNAME" -p "$OPENSHIFT_PASSWORD" --insecure-skip-tls-verify=true; thenGREEN='\033[0;32m'

    echo -e "${GREEN}✅ Login successful!${NC}"YELLOW='\033[1;33m'

CYAN='\033[0;36m'

    # Check if project existsMAGENTA='\033[0;35m'

    if oc get project "$PROJECT" >/dev/null 2>&1; thenNC='\033[0m' # No Color

        echo -e "${YELLOW}Switching to project $PROJECT...${NC}"

        oc project "$PROJECT"echo -e "${CYAN}🔐 Logging into OpenShift Cluster...${NC}"

    elseecho -e "${YELLOW}API URL: $API_URL${NC}"

        echo -e "${RED}Project $PROJECT does not exist.${NC}"echo -e "${YELLOW}Username: $USERNAME${NC}"

        echo -e "${YELLOW}Available projects:${NC}"

        oc get projects# Login to OpenShift

    fiif oc login "$API_URL" -u "$USERNAME" -p "$OPENSHIFT_PASSWORD"; then

else    echo -e "${GREEN}✅ Login successful!${NC}"

    echo -e "${RED}❌ Login failed. Please check your password.${NC}"    

    exit 1    # Check if project exists

fi    if oc get project "$PROJECT" &>/dev/null; then

        echo -e "${YELLOW}📂 Switching to project: $PROJECT${NC}"
        oc project "$PROJECT"
    else
        echo -e "${MAGENTA}🆕 Project '$PROJECT' not found. Creating...${NC}"
        oc new-project "$PROJECT" --description="Dry Fruits Microservices Platform"
    fi
    
    echo -e "${GREEN}🚀 Ready to deploy!${NC}"
    echo -e "${CYAN}Current context:${NC}"
    oc whoami --show-server
    oc project
    
    echo -e "\n${GREEN}🎯 You can now deploy your microservices!${NC}"
    echo -e "${NC}Example: oc apply -f k8s/${NC}"
    
else
    echo -e "${RED}❌ Login failed!${NC}"
    exit 1
fi
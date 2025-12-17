#!/bin/bash
# OpenShift Login Script for Dry Fruits Platform

# Configuration
API_URL="https://api.lab02.ocp4.wfocplab.wwtatc.com:6443"
USERNAME="kubeadmin"
PASSWORD="VMAPE-NXSVe-MUb7I-Eghpc"
PROJECT="dry-fruits-platform"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${CYAN}🔐 Logging into OpenShift Cluster...${NC}"
echo -e "${YELLOW}API URL: $API_URL${NC}"
echo -e "${YELLOW}Username: $USERNAME${NC}"

# Login to OpenShift
if oc login "$API_URL" -u "$USERNAME" -p "$PASSWORD"; then
    echo -e "${GREEN}✅ Login successful!${NC}"
    
    # Check if project exists
    if oc get project "$PROJECT" &>/dev/null; then
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
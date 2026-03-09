
function myhelp_sre_tools() {
    echo -e "${CYAN}SRE Tools - Help${NC}"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "Usage: ${YELLOW}sre_tools [OPTION]${NC}"
    echo -e ""
    echo -e "Options:"
    echo -e "   ${YELLOW}-a${NC}, ${YELLOW}--all${NC}           Load all SRE tools"
    echo -e "   ${YELLOW}-aws${NC}, ${YELLOW}--aws${NC}         Load AWS SRE functions"
    echo -e "   ${YELLOW}-h${NC}, ${YELLOW}--help${NC}          Show this help message"
    echo -e "   ${YELLOW}-l${NC}, ${YELLOW}--list${NC}          List available tools"
    echo -e "   ${YELLOW}-m${NC}, ${YELLOW}--minikube${NC}      Load Minikube functions"
    echo -e "   ${YELLOW}-M${NC}, ${YELLOW}--mattermost${NC}    Load Mattermost functions"
    echo -e "   ${YELLOW}-v${NC}, ${YELLOW}--version${NC}       Show version information"
    echo -e "   ${YELLOW}-z${NC}, ${YELLOW}--zellij${NC}        Load Zellij functions"
    echo -e ""
    echo -e "Examples:"
    echo -e "   ${GREEN}sre_tools -m${NC}           # Load Minikube functions"
    echo -e "   ${GREEN}sre_tools -M${NC}           # Load Mattermost functions"
    echo -e "   ${GREEN}sre_tools --all${NC}        # Load all tools"
}


function list_sre_tools() {
    echo -e "${CYAN}Available SRE Tools:${NC}"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "   ${YELLOW}AWS${NC}          - AWS SRE functions and utilities"
    echo -e "   ${YELLOW}Minikube${NC}     - Local Kubernetes development environment"
    echo -e "   ${YELLOW}Mattermost${NC}   - Mattermost development and deployment tools"
    echo -e ""
    echo -e "To load a specific tool, use the corresponding option:"
    echo -e ""
    echo -e "Use ${GREEN}sre_tools -aws${NC} or ${GREEN}sre_tools --aws${NC} to load AWS functions"
    echo -e "Use ${GREEN}sre_tools -m${NC} or ${GREEN}sre_tools --minikube${NC} to load Minikube functions"
    echo -e "Use ${GREEN}sre_tools -M${NC} or ${GREEN}sre_tools --mattermost${NC} to load Mattermost functions"
}

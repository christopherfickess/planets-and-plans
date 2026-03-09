#!/bin/bash

function myhelp_zellij() {
    echo -e "Zellij Commands:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "     ${YELLOW}zellij_k9s_watch${NC}            - Launch Zellij with K9s deployment watch layout"
    echo -e "     ${YELLOW}zellij_flux_watch${NC}           - Launch Zellij with Flux popout panel layout"
    echo -e "     ${YELLOW}zellij_mattermost_watch${NC}     - Launch Zellij with Mattermost monitoring layout"
    echo -e "     ${YELLOW}zellij_namespace_watch${NC}      - Launch Zellij watching namespaces matching a pattern"
    echo -e "     ${YELLOW}zellij_kubectl_checks${NC}       - Launch Zellij with kubectl checks layout (specify namespace)"
    echo -e "     ${YELLOW}list_zellij_templates${NC}       - List all available Zellij templates"
    echo -e "     ${YELLOW}create_zellij_template${NC}      - Create a new Zellij template"
    echo -e ""
    echo -e "${CYAN}K9s Tips:${NC}"
    echo -e "     - Press ${YELLOW}/${NC} to filter resources by name (e.g., type 'mattermost')"
    echo -e "     - Press ${YELLOW}Ctrl-n${NC} to toggle namespace view"
    echo -e "     - Press ${YELLOW}:${NC} then type resource name (e.g., 'pods', 'deploy')"
    echo -e "     - Press ${YELLOW}?${NC} for help within k9s"
    echo -e ""
    echo -e "For more information, visit: https://zellij.dev/documentation/"
}

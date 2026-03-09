


function myhelp_mattermost() {
    if [[ "$__verbose__" = TRUE ]]; then
        __myhelp_mattermost_advanced__
    else
        __myhelp_mattermost_basic__
    fi
}

function __myhelp_mattermost_basic__() {
    echo -e "Mattermost Functions:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "     ${YELLOW}mmctl${NC}                           - Mattermost command line tool"
    echo -e "     ${YELLOW}mmmutils${NC}                        - Check if mm-utils is installed"
    echo -e "     ${YELLOW}update_mattermost_ctl${NC}           - Update the Mattermost ctl Tool to the latest version"
}   



function __myhelp_mattermost_advanced__() {
    echo -e "Mattermost Functions:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "     ${YELLOW}mmctl${NC}                           - Mattermost command line tool"
    echo -e "     ${YELLOW}mmmutils${NC}                        - Check if mm-utils is installed"
    echo -e "     ${YELLOW}update_mattermost_ctl${NC}           - Update the Mattermost ctl Tool to the latest version"
    echo
    echo -e "Advanced Mattermost Functions:"
    echo -e "------------------------------------------------------------------------------------------------------"
    echo -e "   ${YELLOW}clone_mattermost_repo${NC}       - Clone all Mattermost repositories"
    echo -e "   ${YELLOW}mattermost_build${NC}            - Build server/webapp (server|webapp|all)"
    echo -e "   ${YELLOW}mattermost_cleanup${NC}          - Clean up development environment"
    echo -e "   ${YELLOW}mattermost_cloud_deploy${NC}     - Deploy to Mattermost Cloud"
    echo -e "   ${YELLOW}mattermost_config_check${NC}     - Check configuration and setup"
    echo -e "   ${YELLOW}mattermost_db_reset${NC}         - Reset Mattermost database (destructive)"
    echo -e "   ${YELLOW}mattermost_docker_compose${NC}   - Manage docker-compose services (up/down/logs/ps)"
    echo -e "   ${YELLOW}myhelp_mattermost${NC}   - Show this help message"
    echo -e "   ${YELLOW}mattermost_logs_tail${NC}        - Tail logs for a service"
    echo -e "   ${YELLOW}mattermost_operator_deploy${NC}  - Deploy Mattermost Operator to Kubernetes"
    echo -e "   ${YELLOW}mattermost_rollout${NC}          - Rollout a new version of Mattermost in Kubernetes"
    echo -e "   ${YELLOW}mattermost_test${NC}             - Run tests (unit|integration|e2e|all)"
}
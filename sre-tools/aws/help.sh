
function myhelp_aws() {
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${__HEADER_COLOR__} AWS Functions${NC}"
    echo -e "${__HEADER_COLOR__}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [[ ! -z "${__AWS_FILE}" ]]; then
        __myhelp_aws_sre_tools__
    else
        __myhelp_aws__
    fi

    echo ""
    if [[ "${SRE_TOOLS_VERBOSE:-false}" != "true" ]]; then
        echo -e "${__COMMAND_COLOR__}Tip:${NC} Set ${__DETAILS_COLOR__}SRE_TOOLS_VERBOSE=true${NC} or use ${__DETAILS_COLOR__}myhelp -v${NC} for all AWS commands"
    fi
    echo ""
    echo -e "For more information: ${__INFO_COLOR__}https://docs.aws.amazon.com/cli/latest/reference/${NC}"
}

function __myhelp_aws__() {
    if [[ "${SRE_TOOLS_VERBOSE:-false}" == "true" ]]; then
        __myhelp_aws_toplevel_advanced__
    else
        __myhelp_aws_toplevel_basic__
    fi
}

function __myhelp_aws_toplevel_basic__() {
    echo -e "${BOLD}Common Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}aws_auth_update${NC}              Update AWS credentials"
    echo -e "  ${__COMMAND_COLOR__}aws_profile_switch${NC}           Switch AWS profiles"
    echo -e "  ${__COMMAND_COLOR__}cluster_connect${NC}              Connect to an EKS cluster"
    echo -e "  ${__COMMAND_COLOR__}ec2_id_function${NC}              Get EC2 instance ID by name"
    echo -e "  ${__COMMAND_COLOR__}ec2_ssm_connection${NC}           Connect via SSM"
    echo -e "  ${__COMMAND_COLOR__}eks_cluster_info${NC}             Get cluster information"
    echo -e "  ${__COMMAND_COLOR__}eks_list_clusters${NC}            List all EKS clusters"
    echo -e "  ${__COMMAND_COLOR__}list_kubernetes_objects${NC}      List all K8s objects in namespace"
    echo -e "  ${__COMMAND_COLOR__}ssm_parse_command_to_node_id${NC} Run command via SSM"
    echo -e "  ${__COMMAND_COLOR__}tshl${NC}                         Teleport SSH login helper"
}

function __myhelp_aws_toplevel_advanced__() {
    __myhelp_aws_toplevel_basic__
    echo ""
    echo -e "${BOLD}Advanced Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}aws_sts_assume_role${NC}          Assume an AWS IAM role"
    echo -e "  ${__COMMAND_COLOR__}list_node_group${NC}              List node groups for a cluster"
}

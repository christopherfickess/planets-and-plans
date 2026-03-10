
function __myhelp_aws_sre_tools__() {
    if [[ "${SRE_TOOLS_VERBOSE:-false}" == "true" ]]; then
        __myhelp_aws_advanced__
    else
        __myhelp_aws_basic__
    fi
}

function __myhelp_aws_basic__() {
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

function __myhelp_aws_advanced__() {
    __myhelp_aws_basic__
    echo ""
    echo -e "${BOLD}Advanced EKS Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}eks_node_groups${NC}              List node groups for a cluster"
    echo -e "  ${__COMMAND_COLOR__}eks_update_kubeconfig${NC}        Update kubeconfig for a cluster"
    echo -e "  ${__COMMAND_COLOR__}list_node_group${NC}              List node groups for a cluster"
    echo ""
    echo -e "${BOLD}Advanced EC2 Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}ec2_get_console_output${NC}       Get console output"
    echo -e "  ${__COMMAND_COLOR__}ec2_list_instances${NC}           List EC2 instances"
    echo -e "  ${__COMMAND_COLOR__}ec2_start_instance${NC}           Start an EC2 instance"
    echo -e "  ${__COMMAND_COLOR__}ec2_stop_instance${NC}            Stop an EC2 instance"
    echo ""
    echo -e "${BOLD}S3 Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}s3_list_buckets${NC}              List S3 buckets"
    echo -e "  ${__COMMAND_COLOR__}s3_sync_deploy${NC}               Deploy files to S3"
    echo -e "  ${__COMMAND_COLOR__}s3_sync_test${NC}                 Dry-run S3 sync"
    echo ""
    echo -e "${BOLD}Lambda Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}lambda_get_logs${NC}              Get Lambda logs"
    echo -e "  ${__COMMAND_COLOR__}lambda_invoke_test${NC}           Test invoke a Lambda"
    echo -e "  ${__COMMAND_COLOR__}lambda_list_functions${NC}        List Lambda functions"
    echo ""
    echo -e "${BOLD}Database Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}rds_list_instances${NC}           List RDS instances"
    echo ""
    echo -e "${BOLD}Networking Commands:${NC}"
    echo -e "  ${__COMMAND_COLOR__}sg_list_security_groups${NC}      List security groups"
    echo -e "  ${__COMMAND_COLOR__}vpc_list_vpcs${NC}                List VPCs"
    echo ""
    echo -e "${BOLD}Utilities:${NC}"
    echo -e "  ${__COMMAND_COLOR__}aws_resource_count${NC}           Count AWS resources"
}

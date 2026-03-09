#!/bin/bash

function zell(){
    # case statement to handle different zellij layouts based on user input
    if [ -z "$1" ]; then
        __zell_menu__
    else
        __choice_zell__="$1"
        __zell_logic__
    fi
}

function __zell_logic__(){
    case "$__choice_zell__" in
        -9|--k9s)
            __zellij_k9s_watch__
            ;;
        -c|--create)
            __create_zellij_template__
            ;;
        -f|--flux)
            __zellij_flux_watch__
            ;;
        -h|--help)
            __zell_menu__
            ;;
        -l|--list)
            __list_zellij_templates__
            ;;
        -k|--kubectl)
            __zellij_kubectl_checks__
            ;;
        -m|--mattermost)
            __zellij_mattermost_watch__
            ;;
        -n|--namespaces)
            __zellij_namespace_watch__
            ;;
        *)
            __zell_menu__
            ;;
    esac
}

function __zell_menu__(){
    echo -e "${CYAN}Zell - Zellij Layout Launcher${NC}"
    echo -e "Usage: zell <flags>"
    echo -e "Available layouts:"
    echo -e "   ${YELLOW}-9|--k9s${NC} - Watch K9s deployments with a custom Zellij layout"
    echo -e "   ${YELLOW}-c|--create${NC} - Create a new Zellij template with a basic layout"
    echo -e "   ${YELLOW}-f|--flux${NC} - Watch Flux deployments with a custom Zellij layout"
    echo -e "   ${YELLOW}-h|--help${NC} - Show this help menu"
    echo -e "   ${YELLOW}-l|--list${NC} - List available Zellij templates"
    echo -e "   ${YELLOW}-k|--kubectl${NC} - Run kubectl checks in a Zellij layout"
    echo -e "   ${YELLOW}-m|--mattermost${NC} - Custom Zellij layout for watching Mattermost deployments"
    echo -e "   ${YELLOW}-n|--namespaces${NC} - Watch namespaces with pattern filtering in Zellij"
}

function __zellij_k9s_watch__() {
    # Launch zellij with k9s deployment watch template
    local __template__="${__sre_tools_dir__}/zellij/templates/k9s-only.kdl"

    if [ -f "${__template__}" ]; then
        echo -e "${GREEN}Starting Zellij with K9s deployment watch layout...${NC}"
        echo -e "${YELLOW}Note: K9s will start with specific views. Use '/' to filter within k9s.${NC}"
        zellij --layout "${__template__}"
    else
        echo -e "${RED}Template not found: ${__template__}${NC}"
    fi
}



function __zellij_flux_watch__() {
    # Launch zellij with flux watch template
    local __template__="${__sre_tools_dir__}/zellij/templates/flux-watch.kdl"

    if [ -f "${__template__}" ]; then
        echo -e "${GREEN}Starting Zellij with Flux watch layout...${NC}"
        echo -e "${YELLOW}Note: Flux will start with specific views. Use '/' to filter within Flux.${NC}"
        zellij --layout "${__template__}"
    else
        echo -e "${RED}Template not found: ${__template__}${NC}"
    fi
}


function __zellij_namespace_watch__() {
    # Launch zellij with namespace pattern filtering
    local __template__="${__sre_tools_dir__}/zellij/templates/namespace-filtered-watch.kdl"

    if [ -z "${1}" ]; then
        echo -e "${YELLOW}Enter the namespace pattern to watch (e.g., 'mattermost'): ${NC}"
        read -p "   :>  " __pattern__
        __pattern__="${__pattern__:-mattermost}"
    else
        __pattern__="${1}"
    fi

    if [ -f "${__template__}" ]; then
        echo -e "${GREEN}Starting Zellij watching namespaces matching: ${__pattern__}${NC}"
        NAMESPACE_PATTERN="${__pattern__}" zellij --layout "${__template__}"
    else
        echo -e "${RED}Template not found: ${__template__}${NC}"
    fi
}

function __zellij_kubectl_checks__() {
    # Launch zellij with kubectl checks template
    local __template__="${__sre_tools_dir__}/zellij/templates/kubectl-checks.kdl"

    if [ -z "${1}" ]; then
        echo -e "${YELLOW}Enter the namespace to monitor (default: mattermost): ${NC}"
        read -p "   :>  " __namespace__
        __namespace__="${__namespace__:-mattermost}"
    else
        __namespace__="${1}"
    fi

    if [ -f "${__template__}" ]; then
        echo -e "${GREEN}Starting Zellij with kubectl checks layout for namespace: ${__namespace__}...${NC}"
        ZELLIJ_NAMESPACE="${__namespace__}" zellij --layout "${__template__}"
    else
        echo -e "${RED}Template not found: ${__template__}${NC}"
    fi
}

function __zellij_mattermost_watch__() {
    # Launch zellij with mattermost monitoring template
    local __template__="${__sre_tools_dir__}/zellij/templates/mattermost.kdl"

    if [ -f "${__template__}" ]; then
        echo -e "${GREEN}Starting Zellij with Mattermost monitoring layout...${NC}"
        echo -e "${YELLOW}Tip: Press '/' in any k9s pane to filter for 'mattermost'${NC}"
        zellij --layout "${__template__}"
    else
        echo -e "${RED}Template not found: ${__template__}${NC}"
    fi
}

function __zellij_custom_watch__() {
    # Launch zellij with custom mattermost deployments template
    local __template__="${__sre_tools_dir__}/zellij/watch-mattermost-deployments.kdl"

    if [ -f "${__template__}" ]; then
        echo -e "${GREEN}Starting Zellij with custom Mattermost deployment watch layout...${NC}"
        zellij --layout "${__template__}"
    else
        echo -e "${RED}Template not found: ${__template__}${NC}"
    fi
}

function __list_zellij_templates__() {
    echo -e "${CYAN}Available Zellij Templates:${NC}"
    echo -e "------------------------------------------------------------------------------------------------------"

    local __templates_dir__="${__sre_tools_dir__}/zellij/templates"

    if [ -d "${__templates_dir__}" ]; then
        for __template__ in "${__templates_dir__}"/*.kdl; do
            if [ -f "${__template__}" ]; then
                echo -e "   ${YELLOW}$(basename ${__template__})${NC}"
            fi
        done
    fi

    # Also show custom templates in main zellij directory
    echo -e "\n${CYAN}Custom Templates:${NC}"
    for __template__ in "${__sre_tools_dir__}/zellij"/*.kdl; do
        if [ -f "${__template__}" ]; then
            echo -e "   ${YELLOW}$(basename ${__template__})${NC}"
        fi
    done
}

function __create_zellij_template__() {
    local __template_name__="${1}"

    if [ -z "${__template_name__}" ]; then
        echo -e "${YELLOW}Enter the template name (without .kdl extension): ${NC}"
        read -p "   :>  " __template_name__
    fi

    local __template_path__="${__sre_tools_dir__}/zellij/templates/${__template_name__}.kdl"

    if [ -f "${__template_path__}" ]; then
        echo -e "${RED}Template already exists: ${__template_path__}${NC}"
        return 1
    fi

    cat > "${__template_path__}" <<'EOF'
layout {
    pane split_direction="vertical" {
        pane split_direction="horizontal" {
            pane command="bash"
        }
    }
}
EOF

    echo -e "${GREEN}Created template: ${__template_path__}${NC}"
    echo -e "${YELLOW}Edit the template to customize your layout.${NC}"
}


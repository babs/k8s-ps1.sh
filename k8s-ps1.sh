# k8s-ps1.sh: A colorized shell annotation of current kube context
#
# Most of the actions are done to limit execution overhead (early return, use of cache files, intended bashisms etc)
# as it's meant to be interpreted at PS1 rendering level
#
# Usage, in your bashrc in the interactive initialization:
# 
# source ~/.bash_completion.d/k8s-ps1.sh
# K8S_EXT="\$(__k8s_ps1)"
#
# Insert ${K8S_EXT} in your PS1, example:
# PS1="${K8S_EXT}\001\e[1;34m\002[\t]\001\e[1;${USERCOLOR}m\002[\u@\h] \001\e[0;36m\002\w${GIT_EXT} ${CHAR}\001\e[0m\002 "
#
#
# To enable, disable or toggle:
#  k8sen
#  k8sdis
#  k8stoggle or Ctrl + t
#
#
# Config: ~/.bash_completion.d/k8s-ps1.conf.sh
# ## Case pattern maching syntax
# K8S_COL_PATTERN_WHITE="*lab*|*sandbox*"
# K8S_COL_PATTERN_RED="*prod*"
# K8S_COL_PATTERN_GREEN="*test*"
# K8S_COL_PATTERN_YELLOW="*preprod*"
# K8S_COL_PATTERN_GREY="*minikube*"
#
#

__k8s_parse () {
    KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"
    CACHEFILE=~/.cache/k8s-ps1/"${KUBECONFIG//\//_}"
    [[ "$KUBECONFIG" -ot "$CACHEFILE" ]] && return
    [[ ! -d ~/.cache/k8s-ps1/ ]] && mkdir -p ~/.cache/k8s-ps1
    __K8S_CTX="$(kubectl config current-context)"
    __K8S_NS="$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${__K8S_CTX}\")].context.namespace}")"
    __K8S_CLUSTER="$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${__K8S_CTX}\")].context.cluster}")"
    echo -e "__K8S_CTX=$__K8S_CTX\n__K8S_CLUSTER=$__K8S_CLUSTER\n__K8S_NS=${__K8S_NS:-default}\n" > "$CACHEFILE"
}

__k8s_fn () {
    [[ "${K8S_PS1_ENABLED}" == "on" ]] || return
    __k8s_parse
    source ~/.kube/config.env
    if [[ ! -z "$KUBECONFIG" ]]; then
	CACHEFILE=~/.cache/k8s-ps1/"${KUBECONFIG//\//_}"
        if [[ -e "$CACHEFILE" ]]; then
            source "$CACHEFILE"
            #__K8S_CTX=$K8S_NAME
            #__K8S_NS=$K8S_NAMESPACE
        else
            printf -- "\n\001\e[1;44;39m\002⚠⚠⚠ KUBECONFIG defined but related env not found ⚠⚠⚠\001\e[0m\002\n\001\002"
            return
        fi
    fi
    [[ -e ~/.bash_completion.d/k8s-ps1.conf.sh ]] && . ~/.bash_completion.d/k8s-ps1.conf.sh
    COL="39"
    case "$__K8S_CLUSTER" in
    $K8S_COL_PATTERN_WHITE)
        COL="39"
        ;;
        $K8S_COL_PATTERN_RED)
            COL="31"
            ;;
        $K8S_COL_PATTERN_GREEN)
            COL="32"
            ;;
        $K8S_COL_PATTERN_YELLOW)
            COL="33"
            ;;
        $K8S_COL_PATTERN_GREY)
            COL="30"
            ;;
    esac
    printf -- "\n\001\e[1;44;39m\002(⎈\001\e[${COL}m\002 %s : %s \001\e[1;44;39m\002⎈)\001\e[0;36m\002\n\001\002" "$__K8S_CLUSTER" "$__K8S_NS"
}

__k8s_ps1="\$(__k8s_fn)"

k8sen () {
    echo "Enable K8S shell annotation"
    export K8S_PS1_ENABLED=on
}

k8sdis () {
    echo "Disable K8S shell annotation"
    export K8S_PS1_ENABLED=
}

k8stoggle () {
    [ -n "$K8S_PS1_ENABLED" ] && k8sdis || k8sen
}

bind -x '"\C-t": k8stoggle'

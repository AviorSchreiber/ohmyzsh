HISTFILE=$HOME/.zsh_history
ZSH_THEME="bira"
sshvpn() {
  if [ -z $1 ]; then
    echo -e "\033[0;31mMissing host argumant \n\033[0mfor example:\nsshvpn 192.168.0.1 <port Number>"
    return
  fi
  grep "SSH VPN" /Users/avior.schreiber/Documents/useFullCommand.txt -A 20
  if [ "$1" == "207.232.22.198" ]; then
    a="025870883\n58685699"
    echo -e $a
    #cat /home/avior/chta
  fi
  if [ -z $2 ]; then
    port=22
  else
    port=$2
  fi
  echo "$port"
  sudo sshrc root@$1 -p$port -w 0:0
}

# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"
eval "$(/opt/homebrew/bin/brew shellenv)"

alias restartNetwork='sudo ifconfig en4 down; sudo ifconfig en4 up; echo Done'
alias refreshScreenSaver="find ~/Downloads/  -name \*.jpeg -ctime 0 -type f -exec mv {} ~/Desktop/picture/ \;"
#alias aws_login="/Users/avior.schreiber/Projects/kaltura/okta_kaltura/bin/python /Users/avior.schreiber/Projects/kaltura/okta_kaltura/main.py"
# alias python=python3.9
alias allcloud_ch='open -na "/Applications/Google Chrome.app" --args "--user-data-dir=$HOME/Documents/chrome1"'
alias get-cached-files='sudo du -sh ~/Library/Caches/* 2>/dev/null |grep -E "^[1-9][0-9][0-9]+M|[0-9]G"'
# alias virtualenv="python3.9 -m venv"
#alias ssh=sshrc

###################
##### VsCode ######
###################
# alias code=/usr/local/bin/code
alias code=/usr/local/bin/cursor

###################
####### Git #######
###################
function interactive-rebase() {
  if [[ ! -z $1 ]]; then
    branchName=$1
  else
    branchName=$(git rev-parse --abbrev-ref HEAD)
    branchName=$(git log master..$branchName --oneline | tail -1 | awk '{print $1}')
  fi
  git -c sequence.editor="code --wait --reuse-window" rebase --interactive $branchName
}

function interactive-rebase-kiro() {
  if [[ ! -z $1 ]]; then
    branchName=$1
  else
    branchName=$(git rev-parse --abbrev-ref HEAD)
    branchName=$(git log master..$branchName --oneline | tail -1 | awk '{print $1}')
  fi
  git -c sequence.editor="kiro --wait --reuse-window" rebase --interactive $branchName
}

function interactive-rebase-cursor() {
  if [[ ! -z $1 ]]; then
    branchName=$1
  else
    branchName=$(git rev-parse --abbrev-ref HEAD)
    branchName=$(git log master..$branchName --oneline | tail -1 | awk '{print $1}')
  fi
  git -c sequence.editor="cursor --wait --reuse-window" rebase --interactive $branchName
}

compctl -k "($(git branch --list | cut -c 3- | tr "\n" " "))" interactive-rebase

function git-branch-sync() {
  git fetch -p
  for branch in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'); do
    git branch -D $branch
  done
}
function get-argo-secret() {
  kubectl get secret argocd-initial-admin-secret -n argocd -o yaml | grep password | awk '{print $2}' | base64 --decode | pbcopy
}
function unpause-scaled-objects() {
  kubectl get scaledobject --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name}{"\n"}{end}' |
    while read namespace name; do
      kubectl annotate scaledobject "$name" -n "$namespace" autoscaling.keda.sh/paused- autoscaling.keda.sh/paused-replicas-
    done
}
###################
####### K8s #######
###################
alias kb=kubectl
alias kbx=kubectx
alias kbns=kubens
export KUBE_EDITOR="vim"
#export KUBECONFIG=KUBECONFIG:~/Projects/blueribbon/.kube/dev/config:~/Projects/blueribbon/.kube/devops/config:~/Projects/blueribbon/.kube/demo00/config:~/Projects/blueribbon/.kube/qa/config:~/Projects/blueribbon/.kube/lte/config:~/Projects/blueribbon/.kube/prod/config:~/Projects/blueribbon/.kube/infra/config:~/Projects/sofa/git/allcloud-k8s-eaas-avior-apps/apps/avior-sample-application/KUBECONFIG:/Users/avior.schreiber/Projects/sofa/git/kubernetes-eaas/KUBECONFIG
export KUBECONFIG=/Users/avior.schreiber/Projects/sofa/git/kubernetes-eaas/KUBECONFIG
# autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '/opt/homebrew/bin/aws_completer' aws

function k-get-nodes() {
  (
    echo "KUBERNETES NODE INFO - NAME | OS IMAGE | ARCHITECTURE | AGE (min)"
    echo "NODE NAME|OS IMAGE|ARCHITECTURE|AGE|VIRTUAL NODE GROUP|MANAGED NODE GROUP"
    kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"|"}{.status.nodeInfo.osImage}{"|"}{.status.nodeInfo.architecture}{"|"}{.metadata.creationTimestamp}{"|"}{.metadata.labels.allcloud\.io/virtual-node-group-name}{"|"}{.metadata.labels.allcloud\.io/managed-node-group-name}{"\n"}{end}' |
      sort -t'|' -k4 -r
  ) | awk -F '|' '
    NR == 1 {
    print ""
    print "=================================== " $1 " ==================================="
    next
    }
    NR == 2 {
    printf "\n%-45s | %-40s | %-12s | %-11s | %-30s | %-30s |\n", $1, $2, $3, "AGE (min)", "VIRTUAL NODE GROUP", "MANAGED NODE GROUP"
    print "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    next
    }
    {
    # Calculate age in minutes
    cmd = "date -j -f \"%Y-%m-%dT%H:%M:%SZ\" \"" $4 "\" +%s"
    cmd | getline node_time
    close(cmd)
    cmd = "date +%s"
    cmd | getline now_time
    close(cmd)
    age_minutes = int(((now_time - node_time) / 60)-3 * 60)
    printf "%-45s | %-40s | %-12s | %d min     | %-30s | %-30s |\n", $1, $2, $3, age_minutes, $5, $6 
    print "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    }'
}

function network-policy-issue {
  mode=$1
  BASEDIR="/Users/avior.schreiber/Projects/sofa/git/kubernetes-eaas/aws-network-policy-issue"
  kb $mode -f $BASEDIR/sample-application1-manifests/ && kb $mode -f $BASEDIR/sample-application2-manifests/ && kb $mode -f $BASEDIR/sample-application1-manifests/network-policy && kb $mode -f $BASEDIR/sample-application2-manifests/network-policy
}

function get-chart-images() {
  sampleValuesPath=$1
  images=$(helm template . --values $sampleValuesPath --skip-tests 2>/dev/null | grep 'image:' | sed 's/ //g' | sed 's/"//g' | sed '/^-/ s/-//' | sed 's/image://g' | awk 'length($0) > 0' | sort | uniq)
  echo $images
  echo ""
  for image in $(echo $images); do
    imageName=$(echo $image | cut -d: -f1)
    imageTag=$(echo $image | cut -d: -f2)
    docker pull --platform amd64 $imageName:$imageTag >/dev/null 2>&1
    docker image ls | grep $imageTag
  done
}

function disable-argo-sync {
  # Get all ArgoCD applications and skip the header line
  local apps=$(kubectl get application -A | tail -n +2)

  # Loop through each application
  while read -r line; do
    # Extract the namespace and application name from the output
    local namespace=$(echo "$line" | awk '{print $1}')
    local app_name=$(echo "$line" | awk '{print $2}')

    # Disable automation sync for the application
    echo "Disabling automation sync for application: $app_name in namespace: $namespace"
    kubectl patch application "$app_name" -n "$namespace" --type=merge -p '{"spec": {"syncPolicy": null}}'
  done <<<"$apps"
}

function enable-argo-sync {
  # Get all ArgoCD applications and skip the header line
  local apps=$(kubectl get application -A | tail -n +2)

  # Loop through each application
  while read -r line; do
    # Extract the namespace and application name from the output
    local namespace=$(echo "$line" | awk '{print $1}')
    local app_name=$(echo "$line" | awk '{print $2}')

    # Enable automation sync for the application
    echo "Enabling automation sync for application: $app_name in namespace: $namespace"
    kubectl patch application "$app_name" -n "$namespace" --type=merge -p '{
      "spec": {
        "syncPolicy": {
          "automated": {
            "prune": true,
            "selfHeal": true
          }
        }
      }
    }'
  done <<<"$apps"
}

function count-pods-per-nodegroup {
  nodegroupName=$1
  nodegroupKey=$2
  running=$3

  if [[ "$nodegroupKey" == "virtual" ]]; then
    nodegroupKey=virtual
  else
    nodegroupKey=managed
  fi
  if [[ "$running" == "true" ]]; then
    extraArgs="|grep Running"
  else
    extraArgs=""
  fi
  echo "nodegroupKey: $nodegroupKey"
  echo "nodegroupName: $nodegroupName"
  kubectl get nodes --selector=allcloud.io/$nodegroupKey-node-group-name=$nodegroupName -o json | jq '.items[].metadata.name' | xargs -I {} sh -c 'echo "Node: {}"; kubectl get -A pods --field-selector=spec.nodeName={} --no-headers '$extraArgs' | wc -l'
}

function get-resource-limits-by-nodegroup {
  nodegroupName=$1
  nodegroupKey=$2

  if [[ "$nodegroupKey" == "virtual" ]]; then
    nodegroupKey=virtual
  else
    nodegroupKey=managed
  fi
  for node in $(kubectl get nodes --selector=allcloud.io/$nodegroupKey-node-group-name=$nodegroupName -o jsonpath='{.items[*].metadata.name}'); do
    pods=$(kubectl get pods --all-namespaces --field-selector spec.nodeName=$node -o yaml)
    let total_cpu_requests=0
    let total_cpu_limits=0
    let total_mem_requests=0
    let total_mem_limits=0
    echo $pods >/tmp/pods.yaml
    for pod in $(echo "$pods" | yq eval '.items[]' | base64); do
      pod=$(echo $pod | base64 --decode)
      for container in $(echo "$pod" | yq eval '.spec.containers[] ' | base64); do
        container=$(echo $container | base64 --decode)
        cpu_request=$(echo $container | yq eval '.resources.requests.cpu // "0"' | xargs echo -n)
        mem_request=$(echo $container | yq eval '.resources.requests.memory // "0"' | xargs echo -n)
        cpu_limit=$(echo $container | yq eval '.resources.limits.cpu // "0"' | xargs echo -n)
        mem_limit=$(echo $container | yq eval '.resources.limits.memory // "0"' | xargs echo -n)
        # echo $cpu_request
        # echo $mem_request
        # echo $cpu_limit
        # echo $mem_limit
        convert_to_millicores() {
          local value=$1
          case ${value: -1} in
          m) echo ${value::-1} ;;
          *) echo $((${value} * 1000)) ;;
          esac
        }
        convert_to_mi() {
          local value=$1
          case ${value:2} in
          M) echo ${value::2} ;;
          Mi) echo ${value::2} ;;
          G) echo $((${value::2} * 1024)) ;;
          Gi) echo ${value::2} ;;
          K) echo $((${value::2} / 1024)) ;;
          Ki) echo $((${value::2} / 1024)) ;;
          *) echo $((value / (1024 * 1024))) ;;
          esac
        }
        echo "total_cpu_requests: $total_cpu_requests"
        total_cpu_requests+=$(($total_cpu_requests + $(convert_to_millicores $cpu_request)))
        total_cpu_limits=$(($total_cpu_limits + $(convert_to_millicores $cpu_limit)))
        total_mem_requests=$(($total_mem_requests + $(convert_to_mi $mem_request)))
        total_mem_limits=$(($total_mem_limits + $(convert_to_mi $mem_limit)))
      done
    done
    echo "Node: $node - CPU Requests: ${total_cpu_requests}m, CPU Limits: ${total_cpu_limits}m, Memory Requests: ${total_mem_requests}Mi, Memory Limits: ${total_mem_limits}Mi"
  done

}

################################
####### Solution Factory #######
################################

# alias codeartifact-login="aws codeartifact login --tool npm --repository allcloud --domain allcloud --domain-owner 448906332491 --profile=sf-56-deploy --region=eu-west-1"
function codeartifact-login() {
  # Check that we're in the right folder
  [[ -f "package-lock.json" ]] && LOCK_FILE="package-lock.json"
  [[ -f "yarn.lock" ]] && LOCK_FILE="yarn.lock"
  [[ -f ".npmrc" ]] && LOCK_FILE=".npmrc"
  [[ -z $LOCK_FILE ]] && echo "Did not find any package-lock.json or yarn.lock files." && return 1
  setopt local_options BASH_REMATCH
  setopt +e
  CODEARTIFACT_URL=$(grep -Em1 -o "https://.+codeartifact[^/]+" $LOCK_FILE)
  [[ $CODEARTIFACT_URL =~ "https://([a-z-]+)-([0-9]{12}).d.codeartifact.([a-z0-9-]+).+" ]]
  DOMAIN=$BASH_REMATCH[2]
  ACCOUNT_ID=$BASH_REMATCH[3]
  REGION=$BASH_REMATCH[4]
  if [[ ! -z $1 ]]; then
    echo "AWS Profile: $1"
    PROFILE="--profile $1 "
  elif [[ ! -z $AWS_PROFILE ]]; then
    echo "Using AWS_PROFILE env var"
    PROFILE="--profile $AWS_PROFILE "
  fi
  echo -c "aws $PROFILE --region $REGION codeartifact login --tool npm --repository $DOMAIN --domain $DOMAIN --domain-owner $ACCOUNT_ID"
}

alias build-all="yarn nx run-many --target=build --all"
alias link-all="yarn nx run-many --target=link --all"
alias unlink-all="yarn nx run-many --target=unlink --all"
alias publish-all="yarn nx run-many --target=publish --all"
alias sf-56-login="aws sso login --sso-session sf-56"

function copy-solution-code() {
  version=$(jq -r .version package.json)
  aws s3api copy-object --copy-source allcloud-sofa-environment-as-a-service-$AWS_REGION-dev/products/kubernetes-eaas/v$version/source.zip --bucket allcloud-solutions-factory-327047313893-$AWS_REGION --key products/kubernetes-eaas/v$version/source.zip
  if [ ! -z $1 ]; then
    echo "Copy docker images to s3://allcloud-solutions-factory-327047313893-$AWS_REGION/products/kubernetes-eaas/v$version/docker-images.tar.gz"
    aws s3api copy-object --copy-source allcloud-sofa-environment-as-a-service-$AWS_REGION-dev/products/kubernetes-eaas/v$version/docker-images.tar.gz --bucket allcloud-solutions-factory-$AWS_ACCOUNT-$AWS_REGION --key products/kubernetes-eaas/v$version/docker-images.tar.gz
  fi
}

####################
######## NPM #######
####################
# export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"                                       # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

###################
###### AWS ########
###################
alias aws-config="code ~/.aws/config"
alias git-config="code ~/.gitconfig"
alias aws-credentials="code ~/.aws/credentials"
alias clisso-configure="code ~/.clisso.yaml"
alias bashrc-configure="code ~/.bashrc"
alias zshrc-configure="code ~/.zshrc"
alias npm-configure="code ~/.npmrc"
function ssm-port-forward() {

  if [[ "$1" == "--help" || "$1" == "-h" || "$1" == "--help=ssm-port-forward" ]]; then
    echo "Usage: ssm-port-forward <bastion-host-id> <local-port>:<endpoint>:<remote-port> [aws-region]"
    echo "Example: ssm-port-forward i-xxxxxxxxxxxxx 8080:my-endpoint:80 eu-west-1"
    return 0
  fi
  echo $1
  if [[ -z $1 ]]; then
    echo "Please provide a bastion host id"
    return 1
  fi
  echo $2
  if [[ -z $2 ]]; then
    echo "Please provide a port forwarding configuration"
    echo "Example: 8080:my-endpoint:80"
    return 1
  fi
  echo $3
  if [[ ! -z $3 ]]; then
    regionConfiguration="--region $3"
  fi
  bastionHostId=$1
  # please add validation that two argumrnts has been passed to the funtion
  # the first one should match the pattern i-xxxxxxxxxxxxx
  if [[ ! $bastionHostId =~ ^i-[a-z0-9]+$ ]]; then
    echo "The first argument should be a bastion host id"
    return 1
  fi
  # if [[ ! $2 =~ ^[0-9]+:[a-z0-9.-]+:[0-9]+$ ]]; then
  #     echo "The second argument should be a port forwarding configuration"
  #     echo "Example: 8080:my-endpoint:80"

  #     return 1
  # fi

  localPort=$(echo $2 | cut -d: -f1)
  endpoint=$(echo $2 | cut -d: -f2)
  remotePort=$(echo $2 | cut -d: -f3)

  aws ssm $regionConfiguration start-session \
    --target $bastionHostId \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters "{\"host\":[\"$endpoint\"],\"portNumber\":[\"$remotePort\"], \"localPortNumber\":[\"$localPort\"]}"

}
export AWS_PAGER=

###################
### Terraform #####
###################
export PATH="$PATH:/Users/avior.schreiber/bin"

###################
###### ZSH ########
###################
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
eval "$(direnv hook zsh)"

alias clean-dns-cache="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

alias docker-restart="colima restart"
alias docker-stop="colima stop"
alias docker-start="colima start"

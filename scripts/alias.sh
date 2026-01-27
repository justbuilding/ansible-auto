cat << "EOF" > /etc/profile.d/alias.sh
#定制化脚本
alias hjjpid="sh /root/pid.sh"

#alias activate='source /root/hjj/env/bin/activate'

# vi /etc/profile.d/alias.sh
# source /etc/profile.d/alias.sh
# alias解析

# git
alias gitcommit='git pull origin master;git add --all && git commit -m "auto commit" && git push origin master'

#
alias wget='wget --no-check-certificate'

# kubernetes
alias kc='kubecm'
alias k='kubectl'
alias ke='kubectl exec -it'
alias ked='kubectl edit deployment'
alias klogf='kubectl logs -f'
alias klog='kubectl logs'
alias klogfn='kubectl logs -f -n'
alias kds='kubectl describe'
alias kdpf='kubectl delete pod --force'
alias kdpfn='kubectl delete pod --force -n'
alias klfn='kubectl logs -f -n'
alias kdsp='kubectl describe pod'
alias kdsd='kubectl describe deployment'
alias kdspv='kubectl describe pv'
alias kdspvc='kubectl describe pvc'
alias kdss='kubectl describe service'
alias kdssa='kubectl describe serviceaccount'
alias kdssc='kubectl describe storageclass'
alias kg='kubectl get pods -A'
alias kgo='kubectl get pods -owide -A'
alias kgn='kubectl get nodes -A -o wide'
alias kgpv='kubectl get pv -A'
alias kgpvc='kubectl get pvc -A'
alias kgs='kubectl get service -A'
alias kgsa='kubectl get serviceaccount -A'
alias kgsc='kubectl get storageclass -A'
alias kgd='kubectl get deployment -A'
alias kghpa='kubectl get hpa -o wide -A'

alias kgp-n='kubectl get pods -o custom-columns='NAME:metadata.name,NODE:spec.nodeName' -A'
alias kgp-i='kubectl get pods -o custom-columns='NAME:metadata.name,IMAGES:spec.containers[*].image''

alias kdpf='kubectl delete pod --force'

#grep
alias kgg='kubectl get pods -A|grep'
alias kgog='kubectl get pods -owide -A|grep'
alias kgng='kubectl get nodes -A -o wide|grep'
alias kgpvg='kubectl get pv -A|grep'
alias kgpvcg='kubectl get pvc -A|grep'
alias kgsg='kubectl get service -A|grep'
alias kgsag='kubectl get serviceaccount -A|grep'
alias kgscg='kubectl get storageclass -A|grep'
alias kgdg='kubectl get deployment -A|grep'
alias kgss='kubectl get statefulset -A'
alias kgssg='kubectl get statefulset -A|grep'
alias kgalln='kubectl get all -n'

alias kgds='kubectl get daemonset -A'
alias kgdsg='kubectl get daemonset -A|grep'

#yaml
alias kgyaml='kubectl get pod -oyaml'
alias kgdyaml='kubectl get deployment -oyaml'
alias kgpvyaml='kubectl get pv -oyaml'
alias kgpvcyaml='kubectl get pvc -oyaml'
alias kgsyaml='kubectl get service -oyaml'
alias kgsayaml='kubectl get serviceaccount -oyaml'
alias kgscyaml='kubectl get storageclass -oyaml'
alias kgdyaml='kubectl get deployment -oyaml'
alias kghpayaml='kubectl get hpa -oyaml'

#ingress
alias kgi='kubectl get ingress -A'
alias kgig='kubectl get ingress -A|grep'

#kube-system
alias kdssys='kubectl describe -n kube-system'
alias kdspsys='kubectl describe -n kube-system pod'
alias kdsdsys='kubectl describe -n kube-system deployment'
alias ksys='kubectl -n kube-system'
alias kgsys='kubectl -n kube-system get pods'
alias kggsys='kubectl -n kube-system get pods|grep'
alias klogsys='kubectl -n kube-system logs'

#top
alias ktp='kubectl top pods'
alias ktn='kubectl top nodes'

#apply
alias kaf='kubectl apply -f'


# 下载yum全量依赖包
# alias download='yum -y install yum-utils && repotrack'

# 限速100M/s 20个线程 支持断点再续
alias axel='axel -s 102400000 -a -n 20'
EOF
. /etc/profile.d/alias.sh
echo ". /etc/profile.d/alias.sh"

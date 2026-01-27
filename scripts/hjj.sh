
cat << "EOF" > /root/delete_pod.sh
#!/bin/bash
#命名空间 批量删除未running的pod解析 批量操作解析 批量删除pod解析
namespace=$1
all_namespace=$2
no_agent_image=$3

cd `dirname "$0"`

if [ $# -lt 1 ];then
  echo "用于删除pod"
  echo "指定命名空间删除未running的pod案例      sh delete_pod.sh default"
  echo "全部命名空间删除未running的pod案例      sh delete_pod.sh default -A"
  exit
fi

if [ $# -eq 2 ]; then
  #获取pod的名字 命名空间
  namespace_list=$(kubectl get pod -n$namespace $all_namespace |grep -v Running|grep -v NAME |awk '{print $1}')
  pod_name_list=$(kubectl get pod -n$namespace $all_namespace  |grep -v Running|grep -v NAME |awk '{print $2}')
  namespace=($namespace_list)
  pod_name=($pod_name_list)
  length=${#pod_name[@]}
  for ((i=0; i<${length}; i++));
  do
    kubectl delete pod ${pod_name[$i]} -n ${namespace[$i]} --grace-period=0 --force
    sleep 0.5
  done
fi


if [ $# -eq 1 ]; then
  #获取pod的名字
  pod_name=$(kubectl get pod -n$namespace |grep -v Running |grep -v NAME |awk '{print $1}')
  for pod  in $pod_name
  do
    kubectl delete pod $pod -n $namespace --grace-period=0 --force
    sleep 2
  done
fi
EOF
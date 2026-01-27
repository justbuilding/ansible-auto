#!/bin/bash
set -euo pipefail  # 增强脚本健壮性：遇到错误立即退出、未定义变量报错、管道错误传递

# ===================== 版本号独立配置区（核心：改这里即可）=====================
# 每个镜像的版本号单独定义，方便维护和修改
MINIO_OPERATOR_VERSION="v5.0.6"
HELM_VERSION="v3.19.2"
CALICO_VERSION="v3.27.4"
INGRESS_NGINX_VERSION="v1.12.1"
CILIUM_VERSION="v1.13.4"

# ===================== 镜像列表配置（无需频繁修改）=====================
# 格式："镜像完整地址 保存的tar包名"
images=(
  "registry.cn-shanghai.aliyuncs.com/labring/minio-operator:${MINIO_OPERATOR_VERSION} minio-operator.tar"
  "registry.cn-shanghai.aliyuncs.com/labring/helm:${HELM_VERSION} helm.tar"
  "registry.cn-shanghai.aliyuncs.com/labring/calico:${CALICO_VERSION} calico.tar"
  "registry.cn-shanghai.aliyuncs.com/labring/ingress-nginx:${INGRESS_NGINX_VERSION} ingress-nginx.tar"
  "registry.cn-shanghai.aliyuncs.com/labring/cilium:${CILIUM_VERSION} cilium.tar"
)

# ===================== 核心执行逻辑 =====================
echo -e "\n===== 开始执行镜像拉取+保存脚本 ====="

# 1. 循环拉取镜像
echo -e "\n【第一步】拉取镜像..."
for item in "${images[@]}"; do
  # 拆分镜像地址和tar包名
  img=$(echo "$item" | awk '{print $1}')
  tar_name=$(echo "$item" | awk '{print $2}')
  
  echo -e "\n正在拉取镜像：$img"
  sealos pull "$img"
  
  if [ $? -eq 0 ]; then
    echo "✅ 镜像 $img 拉取成功"
  else
    echo "❌ 镜像 $img 拉取失败，脚本退出"
    exit 1
  fi
done

# 2. 循环保存镜像（适配你的sealos版本，强制指定-o参数）
echo -e "\n【第二步】保存镜像到tar包..."
for item in "${images[@]}"; do
  img=$(echo "$item" | awk '{print $1}')
  tar_name=$(echo "$item" | awk '{print $2}')
  
  echo -e "\n正在保存镜像 $img 到 $tar_name"
  sealos save -o "$tar_name" "$img"
  
  if [ $? -eq 0 ]; then
    echo "✅ 镜像 $img 保存为 $tar_name 成功"
  else
    echo "❌ 镜像 $img 保存失败，脚本退出"
    exit 1
  fi
done

# ===================== 可选：压缩tar包（如需压缩，取消下面注释）=====================
# echo -e "\n【第三步】压缩tar包（生成.tar.gz）..."
# for item in "${images[@]}"; do
#   tar_name=$(echo "$item" | awk '{print $2}')
#   echo -e "\n正在压缩 $tar_name..."
#   gzip "$tar_name"
#   echo "✅ $tar_name 已压缩为 ${tar_name}.gz"
# done

echo -e "\n===== 所有镜像拉取+保存完成！====="

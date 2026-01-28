#!/bin/bash
set -euo pipefail  # 增强脚本健壮性：遇到错误立即退出、未定义变量报错、管道错误传递

# ===================== 版本号独立配置区（核心：改这里即可）=====================
# 每个镜像的版本号单独定义，方便维护和修改
MINIO_OPERATOR_VERSION="v5.0.6"
HELM_VERSION="v3.19.2"
CALICO_VERSION="v3.27.4"
INGRESS_NGINX_VERSION="v1.12.1"
CILIUM_VERSION="v1.13.4"
METRICS_SERVER_VERSION="v0.8.0"
CERT_MANAGER_VERSION="v1.19.2"

# ===================== 镜像配置（无需频繁修改）=====================
# 格式："镜像完整地址 保存的tar包名 是否默认下载"
# 是否默认下载：true（默认下载）/false（需要指定才下载）
images=(
  "registry.cn-shanghai.aliyuncs.com/labring/minio-operator:${MINIO_OPERATOR_VERSION} minio-operator.tar false"
  "registry.cn-shanghai.aliyuncs.com/labring/helm:${HELM_VERSION} helm.tar false"
  "registry.cn-shanghai.aliyuncs.com/labring/calico:${CALICO_VERSION} calico.tar true"
  "registry.cn-shanghai.aliyuncs.com/labring/ingress-nginx:${INGRESS_NGINX_VERSION} ingress-nginx.tar true"
  "registry.cn-shanghai.aliyuncs.com/labring/cilium:${CILIUM_VERSION} cilium.tar true"
  "registry.k8s.io/metrics-server/metrics-server:${METRICS_SERVER_VERSION} metrics.tar false"
  "registry.cn-shanghai.aliyuncs.com/labring/cert-manager:${CERT_MANAGER_VERSION} cert-manager.tar false"
)

# ===================== 命令行参数处理 =====================
# 解析命令行参数，确定需要下载的可选镜像
# 格式：./save.sh --minio --helm --metrics --cert
DOWNLOAD_MINIO=false
DOWNLOAD_HELM=false
DOWNLOAD_METRICS=false
DOWNLOAD_CERT=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --minio)
      DOWNLOAD_MINIO=true
      shift
      ;;
    --helm)
      DOWNLOAD_HELM=true
      shift
      ;;
    --metrics)
      DOWNLOAD_METRICS=true
      shift
      ;;
    --cert)
      DOWNLOAD_CERT=true
      shift
      ;;
    *)
      echo "未知参数: $1"
      echo "使用方法: ./save.sh [--minio] [--helm] [--metrics] [--cert]"
      echo "默认下载: calico, ingress-nginx, cilium"
      echo "可选下载: --minio (minio-operator), --helm (helm), --metrics (metrics-server), --cert (cert-manager)"
      exit 1
      ;;
  esac
done

# ===================== 核心执行逻辑 =====================
echo -e "\n===== 开始执行镜像拉取+保存脚本 ======"

# 1. 构建要下载的镜像列表
echo -e "\n【第一步】构建要下载的镜像列表..."
download_images=()

for item in "${images[@]}"; do
  # 拆分镜像地址、tar包名和是否默认下载
  img=$(echo "$item" | awk '{print $1}')
  tar_name=$(echo "$item" | awk '{print $2}')
  default_download=$(echo "$item" | awk '{print $3}')
  
  # 检查是否需要下载此镜像
  should_download=false
  
  # 如果是默认下载，则添加到下载列表
  if [ "$default_download" = "true" ]; then
    should_download=true
  else
    # 检查是否是可选镜像且用户指定了下载
    case "$tar_name" in
      minio-operator.tar)
        if [ "$DOWNLOAD_MINIO" = "true" ]; then
          should_download=true
        fi
        ;;
      helm.tar)
        if [ "$DOWNLOAD_HELM" = "true" ]; then
          should_download=true
        fi
        ;;
      metrics.tar)
        if [ "$DOWNLOAD_METRICS" = "true" ]; then
          should_download=true
        fi
        ;;
      cert-manager.tar)
        if [ "$DOWNLOAD_CERT" = "true" ]; then
          should_download=true
        fi
        ;;
    esac
  fi
  
  # 如果需要下载，添加到下载列表
  if [ "$should_download" = "true" ]; then
    download_images+=("$item")
    echo "✅ 添加到下载列表: $img ($tar_name)"
  else
    echo "⏭️  跳过: $img ($tar_name)"
  fi
done

# 2. 循环拉取镜像
echo -e "\n【第二步】拉取镜像..."
for item in "${download_images[@]}"; do
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

# 3. 循环保存镜像（适配你的sealos版本，强制指定-o参数）
echo -e "\n【第三步】保存镜像到tar包..."
for item in "${download_images[@]}"; do
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

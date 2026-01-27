#!/bin/bash
# down.sh - 镜像下载脚本
# 用于提前下载Kubernetes部署所需的所有镜像

# 配置变量
K8S_VERSION="v1.31.9"
SEALOS_VERSION="v5.1.2-rc3"
PKG_DIR="/tmppkg"

# 镜像列表
IMAGE_LIST=(
  "registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:$K8S_VERSION"
  "registry.cn-shanghai.aliyuncs.com/labring/helm:v3.9.4"
  "registry.cn-shanghai.aliyuncs.com/labring/calico:v3.24.1"
  "registry.cn-shanghai.aliyuncs.com/labring/ingress-nginx:4.1.0"
  "registry.cn-shanghai.aliyuncs.com/labring/minio-operator:v4.5.5"
)

# 镜像包名称映射
declare -A IMAGE_MAP
IMAGE_MAP["registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:$K8S_VERSION"]="kubernetes-docker.tar"
IMAGE_MAP["registry.cn-shanghai.aliyuncs.com/labring/helm:v3.9.4"]="helm.tar"
IMAGE_MAP["registry.cn-shanghai.aliyuncs.com/labring/calico:v3.24.1"]="calico.tar"
IMAGE_MAP["registry.cn-shanghai.aliyuncs.com/labring/minio-operator:v4.5.5"]="minio-operator.tar"
IMAGE_MAP["registry.cn-shanghai.aliyuncs.com/labring/ingress-nginx:4.1.0"]="ingress-nginx.tar"

# 颜色定义
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

# 日志函数
log() {
  echo -e "${BLUE}[INFO]${RESET} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${RESET} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${RESET} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${RESET} $1"
}

# 检查sealos命令是否可用
check_sealos() {
  if ! command -v sealos &> /dev/null; then
    log_error "sealos命令不可用，请先安装sealos"
    log "安装sealos: curl -sfL https://get.sealos.io | sh -"
    exit 1
  fi
}

# 创建包目录
create_pkg_dir() {
  if [ ! -d "$PKG_DIR" ]; then
    log "创建包目录: $PKG_DIR"
    mkdir -p "$PKG_DIR"
    if [ $? -ne 0 ]; then
      log_error "创建包目录失败"
      exit 1
    fi
  fi
}

# 下载并保存镜像
download_and_save_images() {
  log "开始下载和保存镜像..."
  log "包目录: $PKG_DIR"
  
  for image in "${IMAGE_LIST[@]}"; do
    filename="${IMAGE_MAP[$image]}"
    if [ -f "$PKG_DIR/$filename" ]; then
      log_warn "镜像包已存在: $filename，跳过下载"
      continue
    fi
    
    log "下载镜像: $image"
    sealos pull "$image"
    if [ $? -ne 0 ]; then
      log_error "下载镜像失败: $image"

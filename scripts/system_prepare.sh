#!/bin/bash
set -e  # 遇到错误立即退出

# ===================== 系统准备和优化脚本 =====================
# 结合了系统基础优化和hosts文件优化，解决Java无网环境解析问题
# 基于backup目录中的prepare角色和Java无网环境解析优化脚本

# 日志函数
echo_info() {
    echo -e "\033[32m✅ $1\033[0m"
}

echo_warning() {
    echo -e "\033[33m⚠️  $1\033[0m"
}

echo_error() {
    echo -e "\033[31m❌ $1\033[0m"
}

echo_info "开始系统准备和优化..."

# ===================== 第一步：自动获取系统信息 =====================
echo_info "\n===== 自动获取系统信息 ====="

# 1. 获取本机主机名
HOSTNAME=$(hostname)
echo_info "自动获取主机名：$HOSTNAME"

# 2. 自动获取内网IPv4（排除回环、虚拟网卡，优先取物理网卡IP）
# 兼容Mac的ifconfig和Linux的ip addr命令
if [[ "$(uname)" == "Darwin" ]]; then
    # Mac系统获取内网IP
    INNER_IP=$(ifconfig | grep -E 'inet [0-9\.]+ netmask' | grep -v '127.0.0.1' | awk '{print $2}' | head -n 1)
else
    # Linux系统获取内网IP
    INNER_IP=$(ip addr | grep -E 'inet [0-9\.]+/24' | grep -v '127.0.0.1' | grep -v 'docker' | grep -v 'veth' | awk '{print $2}' | cut -d '/' -f1 | head -n 1)
fi

# 若未获取到内网IP，默认用127.0.0.1
if [[ -z "$INNER_IP" ]]; then
    INNER_IP="127.0.0.1"
    echo_warning "未检测到内网IP，使用回环IP：$INNER_IP"
else
    echo_info "自动获取内网IP：$INNER_IP"
fi

# ===================== 第二步：系统基础优化 =====================
echo_info "\n===== 系统基础优化 ====="

# 1. 修改sshd配置 - 禁用UseDNS
echo_info "优化SSH配置 - 禁用UseDNS"
if command -v sed &> /dev/null; then
    sudo sed -ri '/UseDNS yes/cUseDNS no' /etc/ssh/sshd_config
    sudo systemctl restart sshd 2>/dev/null || true
fi

# 2. 优化历史记录
echo_info "优化历史记录配置"
echo "export HISTSIZE=200000" | sudo tee -a /etc/profile > /dev/null
echo "export HISTTIMEFORMAT='%F %T:'" | sudo tee -a /etc/profile > /dev/null

# 3. 关闭SELinux
if [[ "$(uname)" != "Darwin" ]]; then
    echo_info "关闭SELinux"
    sudo sed -ri 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
    sudo setenforce 0 2>/dev/null || true
fi

# 4. 关闭swap
echo_info "关闭Swap"
sudo sed -i '/swap/d' /etc/fstab 2>/dev/null || true
sudo swapoff -a 2>/dev/null || true

# 5. 设置时区
echo_info "设置时区为Asia/Shanghai"
sudo timedatectl set-timezone Asia/Shanghai 2>/dev/null || true

#
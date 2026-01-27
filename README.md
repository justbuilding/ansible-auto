# 企业级Ansible自动化管理项目

## 项目概述

本项目基于Ansible实现了一套完整的自动化管理方案，包括系统准备、Docker安装、Kubernetes部署等功能。项目结构清晰，遵循Ansible最佳实践，支持多种操作系统和部署场景。

### 核心特性

- **多部署模式支持**：
  - ✅ 离线部署：支持完全离线环境，使用预下载的镜像包
  - ✅ 联网部署：支持在线环境，自动下载所需组件
  - ✅ 混合模式：离线使用本地镜像包，缺失组件自动在线下载

- **国产化系统支持**：
  - ✅ 麒麟操作系统 (Kylin OS) V10
  - ✅ 其他基于Linux的国产操作系统

- **跨平台兼容**：
  - ✅ AMD64 (x86_64) 架构
  - ✅ ARM64 (aarch64) 架构

- **企业级特性**：
  - ✅ 高可用性配置
  - ✅ 安全性优化
  - ✅ 性能调优
  - ✅ 完整的监控和管理

## 项目结构

```
ansible-auto/
├── docs/                    # 文档目录
│   ├── installation/        # 安装教程
│   ├── k8s_deployment_guide.md  # Kubernetes部署指南
│   └── ssh_setup_guide.md   # SSH密钥设置指南
├── inventory/               # 主机清单目录
│   ├── hosts                # 主机配置文件
│   └── hosts.example        # 主机配置示例
├── playbooks/               # Playbook目录
│   ├── deploy_k8s.yml       # 部署Kubernetes
│   ├── install_docker.yml   # Docker安装Playbook
│   ├── install_packages.yml # 系统包安装Playbook
│   ├── ssh_key_setup.yml    # SSH密钥设置Playbook
│   ├── ssh_key_simple.yml   # 简化版SSH密钥设置Playbook
│   └── system_prepare.yml   # 系统准备和优化Playbook
├── roles/                   # 角色目录
│   ├── common/              # 通用系统配置角色
│   │   ├── tasks/           # 任务文件
│   │   ├── templates/       # 模板文件
│   │   └── defaults/        # 默认变量
│   ├── docker/              # Docker安装和配置角色
│   │   ├── tasks/           # 任务文件
│   │   ├── templates/       # 模板文件
│   │   ├── handlers/        # 处理程序
│   │   └── defaults/        # 默认变量
│   ├── kubernetes/          # Kubernetes部署角色
│   │   ├── tasks/           # 任务文件
│   │   └── defaults/        # 默认变量
│   └── ssh/                 # SSH密钥设置角色
│       ├── tasks/           # 任务文件
│       └── defaults/        # 默认变量
├── scripts/                 # 脚本目录
├── tmppkg/                  # 临时包目录（包含镜像包和下载脚本）
│   ├── amd64/               # AMD64架构镜像包
│   ├── arm64/               # ARM64架构镜像包
│   └── aarch64/             # ARM64架构镜像包（兼容别名）
├── ansible.cfg              # Ansible配置文件
├── ansible.log              # Ansible日志文件
└── README.md                # 项目说明文档
```

## 主要功能

### 1. 系统准备和优化
- **Playbook**: `playbooks/system_prepare.yml`
- **功能**:
  - 系统基础优化（SELinux、Swap、时区等）
  - 内核参数优化
  - 资源限制配置
  - hosts文件优化（解决Java无网环境解析问题）
  - 基础工具安装
  - 时间同步配置
  - 网络连接检测（支持ping和curl双重检测）
  - 国内加速源配置
  - 别名配置（自动配置kubectl等命令别名）
  - 脚本同步和执行
  - 详细的系统优化结果验证
  - 修复的超时和异步执行设置

### 2. SSH密钥分发
- **Playbook**: `playbooks/ssh_key_setup.yml`（推荐）或 `playbooks/ssh_key_simple.yml`
- **功能**:
  - 自动生成SSH密钥对
  - 分发公钥到远程主机
  - 配置免密登录
  - 支持普通用户和root用户

### 3. 系统包安装
- **Playbook**: `playbooks/install_packages.yml`
- **功能**:
  - 支持多种包管理系统（apt、yum）
  - 在线和离线安装模式
  - 通用包和开发工具包安装
  - 支持包更新和卸载

### 4. Docker配置
- **Playbook**: `playbooks/install_docker.yml` 或作为 `deploy_k8s.yml` 的可选配置
- **功能**:
  - 支持Ubuntu、CentOS等多种操作系统
  - 可配置Docker版本
  - 镜像加速配置
  - 容器存储配置
  - 可选：在Sealos部署完成后进行配置（Sealos会自动部署Docker）

### 5. Kubernetes集群部署
- **Playbook**: `playbooks/deploy_k8s.yml`
- **功能**:
  - 基于Sealos的Kubernetes集群部署
  - 支持master节点安装和node节点灵活添加
  - 多版本支持
  - 跨平台兼容（AMD64/ARM64）
  - 自动化配置和部署验证
  - 支持在线和离线部署
  - 智能镜像包检测和使用
  - Docker数据目录迁移支持
  - 部署前环境检查，确保干净的部署环境
  - 详细的环境检查结果和清理建议
  - 支持多种格式镜像包（sealos_hub_5000_*.tar、registry_*.tar、metrics-server_*.tar等）
  - Docker配置分离，支持部署后自定义配置
  - 网络插件选择（Calico/Cilium）
  - 版本一致性保证，所有组件使用指定版本

### 6. 环境重置
- **Playbook**: `playbooks/reset_environment.yml`
- **功能**:
  - 重置Kubernetes和Docker环境
  - 清理所有相关组件和配置
  - 支持故障恢复场景
  - 完整的环境清理流程

## 快速开始

### 1. 环境准备

- 安装Ansible（参考 `docs/installation/ansible_installation_guide.md`）
- 配置主机清单（编辑 `inventory/hosts`）

### 2. 部署前准备

#### 2.1 提前下载准备

为了加快部署速度，您可以在部署前提前下载好所需的文件和镜像包。详细的提前下载说明请参考 [Kubernetes部署指南](docs/k8s_deployment_guide.md#23-提前下载准备)。

#### 2.1.1 使用down.sh脚本下载镜像包

我们提供了一个便捷的 `down.sh` 脚本，用于自动下载和保存所有必要的镜像包。您可以在任意有网络连接的主机上运行此脚本：

```bash
# 下载脚本
curl -sfL https://raw.githubusercontent.com/your-repo/ansible-auto/main/scripts/down.sh -o down.sh
chmod +x down.sh

# 运行脚本下载镜像包
sudo ./down.sh
```

**脚本功能**：
- 自动检查sealos命令是否可用
- 创建默认的镜像包目录结构
- 下载所有必要的Kubernetes镜像
- 将镜像保存为tar包，支持多种格式
- 显示下载结果，检查所有镜像包是否成功保存

**脚本配置**：
您可以通过修改脚本中的变量来自定义下载配置：
- `K8S_VERSION`：Kubernetes版本
- `SEALOS_VERSION`：Sealos版本
- `PKG_DIR`：镜像包保存目录
- `ARCH`：架构类型（amd64/arm64）

#### 2.1.2 镜像包放置位置

### 架构目录结构

项目支持AMD64和ARM64架构，采用以下目录结构管理镜像包：

```
tmppkg/
├── aarch64/           # ARM64架构镜像包
├── arm64/             # ARM64架构镜像包（兼容别名）
├── sealos_5.1.2-rc3_linux_amd64.tar.gz  # AMD64架构Sealos二进制
└── sealos_5.1.2-rc3_linux_arm64.tar.gz  # ARM64架构Sealos二进制
```

**自动架构检测**：
- 系统会自动检测目标主机架构
- 优先使用与目标主机匹配的架构目录
- 自动将aarch64映射为arm64以保持兼容性

### 多种格式镜像包支持

系统支持多种格式的镜像包，会自动检测并使用：

1. **Sealos Hub格式**：`sealos_hub_5000_*.tar`
2. **Registry格式**：`registry_*.tar`
3. **Metrics Server格式**：`*_metrics-server_*.tar` 或 `metrics-server_*.tar`
4. **单独命名格式**：
   - kubernetes-docker.tar
   - helm.tar
   - calico.tar
   - ingress-nginx.tar
   - minio-operator.tar

### 使用自定义目录

您可以通过 `pkg_dir` 变量指定自定义目录：

```bash
ansible-playbook playbooks/deploy_k8s.yml -e "pkg_dir=/my_custom_pkg_dir"
```

**智能检测逻辑**：
- 系统会自动检查是否存在任何格式的镜像包
- 如果检测到镜像包，会跳过下载步骤，直接加载使用
- 支持混合格式，会按照优先级顺序加载所有可用镜像包
- 详细的检测和加载日志会记录在执行输出中

#### 2.1.3 从其他主机复制镜像包

如果您已经在其他主机上通过 `down.sh` 脚本下载好了镜像包，可以将这些镜像包复制到当前主机的 `tmppkg` 目录或自定义目录中：

```bash
# 复制整个tmppkg目录结构
sudo scp -r user@other-host:/path/to/ansible-auto/tmppkg/ /path/to/ansible-auto/

# 或仅复制特定架构的镜像包
sudo scp -r user@other-host:/path/to/ansible-auto/tmppkg/arm64/ /path/to/ansible-auto/tmppkg/

# 或复制到自定义目录
sudo scp -r user@other-host:/path/to/ansible-auto/tmppkg/* /my_custom_pkg_dir/
```

复制完成后，部署时系统会自动检测并使用这些镜像包，无需重新下载。

**注意事项**：
- 确保复制的目录结构保持完整
- 对于ARM64架构，同时支持 `aarch64` 和 `arm64` 目录名
- 系统会自动处理架构匹配和格式检测


#### 2.2 基本使用流程

#### 第一步：配置主机清单

```ini
[all]
server1 ansible_host=192.168.1.10 ansible_user=ubuntu
server2 ansible_host=192.168.1.11 ansible_user=ubuntu

[masters]
server1

[workers]
server2
```

#### 第二步：设置SSH免密登录

```bash

# 这种方式不需要安装sshpass 使用推荐版
node1 ansible_host=192.168.1.5 ansible_user=u ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible-playbook playbooks/ssh_key_setup.yml -K

# 使用                 ansible-playbook playbooks/ssh_key_setup.yml -k -K
# 使用简化版（root用户） ansible-playbook playbooks/ssh_key_simple.yml -k
```

#### 第三步：系统准备和优化

```bash
ansible-playbook playbooks/system_prepare.yml
```

#### 第四步：部署Kubernetes集群

```bash
# 在线部署
ansible-playbook playbooks/deploy_k8s.yml

# 离线部署（自动检测预下载的镜像包）
ansible-playbook playbooks/deploy_k8s.yml
```

**自动离线检测**：
- 系统会自动检测是否存在预下载的镜像包
- 如果检测到镜像包，自动使用离线模式
- 无需手动指定离线参数
- 支持混合模式：部分镜像包离线使用，缺失的镜像在线下载

#### 第五步：可选：配置Docker（在Sealos部署完成后）

Sealos会自动部署Docker，所以通常不需要单独安装。但如果需要自定义Docker配置（如数据目录、镜像加速等），可以在部署完成后执行：

```bash
ansible-playbook playbooks/deploy_k8s.yml -e "configure_docker_after_deployment=true"
```

#### 第六步：环境重置（当需要清理环境时）

如果Kubernetes集群出现故障或需要重新部署，可以使用环境重置playbook清理整个环境：

```bash
ansible-playbook playbooks/reset_environment.yml
```

**重置功能**：
- 清理Kubernetes相关组件和配置
- 清理Docker和containerd
- 清理etcd数据
- 清理网络配置
- 清理Sealos相关数据
- 为重新部署做准备

## 高级配置

### 变量配置

每个Playbook都支持通过变量进行自定义配置，可以通过以下方式设置：

1. **在inventory中设置**：
   ```ini
   [all:vars]
   kubernetes_version=1.28.3
   docker_version=24.0.6
   ```

2. **通过命令行传递**：
   ```bash
   ansible-playbook playbooks/install_kubeadm.yml -e "kubernetes_version=1.28.3"
   ```

3. **创建group_vars或host_vars文件**：
   ```bash
   mkdir -p group_vars
   echo "kubernetes_version: 1.28.3" > group_vars/all.yml
   ```

### 常用变量说明

#### 镜像包管理变量

| 变量名 | 用途 | 默认值 |
|-------|------|-------|
| `pkg_dir` | 镜像包目录 | "/tmppkg" |
| `arch` | 架构类型 | 自动检测 |
| `enable_docker_data_dir_change` | 是否启用Docker数据目录迁移 | true |
| `docker_data_dir` | Docker数据目录 | "/var/lib/docker" |

#### Docker角色变量（roles/docker/defaults/main.yml）

| 变量名 | 用途 | 默认值 |
|-------|------|-------|
| `docker_version` | Docker版本 | "24.0.7" |
| `docker_data_dir` | Docker数据目录 | "/var/lib/docker" |
| `docker_registry_mirrors` | Docker镜像加速地址 | ["https://registry.docker-cn.com", "https://mirror.baidubce.com", "https://hub-mirror.c.163.com"] |
| `docker_insecure_registries` | 不安全的Docker仓库 | [] |
| `docker_log_max_size` | Docker日志最大大小 | "100m" |
| `docker_log_max_file` | Docker日志最大文件数 | "3" |
| `docker_enable_ipv6` | 是否启用IPv6 | false |

#### Kubernetes部署镜像

| 镜像名称 | 版本 | 仓库地址 |
|---------|------|----------|
| kubernetes-docker | v1.31.9 | registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker |
| helm | v3.19.2 | registry.cn-shanghai.aliyuncs.com/labring/helm |
| calico | v3.27.4 | registry.cn-shanghai.aliyuncs.com/labring/calico |
| cilium | v1.13.4 | registry.cn-shanghai.aliyuncs.com/labring/cilium |
| ingress-nginx | v1.12.1 | registry.cn-shanghai.aliyuncs.com/labring/ingress-nginx |
| minio-operator | v5.0.6 | registry.cn-shanghai.aliyuncs.com/labring/minio-operator |

#### 网络插件选择

项目支持两种网络插件，可通过 `network_plugin` 变量选择：

| 网络插件 | 变量值 | 版本 | 特点 |
|---------|-------|------|------|
| Calico | `calico` | v3.27.4 | 稳定可靠，广泛使用 |
| Cilium | `cilium` | v1.13.4 | 基于eBPF，性能优异 |

**使用方法**：
```bash
# 使用Calico网络插件（默认）
ansible-playbook playbooks/deploy_k8s.yml

# 使用Cilium网络插件
ansible-playbook playbooks/deploy_k8s.yml -e "network_plugin=cilium"
```

## 最佳实践

1. **使用版本控制**：将项目纳入Git版本控制，便于跟踪变更
2. **遵循Ansible最佳实践**：使用角色、模板、变量等功能
3. **测试环境验证**：在测试环境验证Playbook后再部署到生产环境
4. **定期更新**：定期更新Ansible和Kubernetes版本
5. **文档化**：记录部署过程和配置变更
6. **使用标签**：为Playbook任务添加标签，便于选择性执行
7. **镜像包管理**：
   - 预下载镜像包以加速部署
   - 按架构分类管理镜像包
   - 定期更新镜像包版本
   - 保留多个架构的镜像包以支持混合集群
8. **离线部署准备**：
   - 在有网络的环境中预下载所有必要的镜像包
   - 测试离线部署流程确保可靠性
   - 保留完整的镜像包备份

## 系统支持

- **Ubuntu**: 20.04 LTS, 22.04 LTS, 26.04 LTS
- **CentOS**: 7, 8, 9
- **RHEL**: 7, 8, 9
- **Rocky Linux**: 8, 9
- **AlmaLinux**: 8, 9
- **macOS**: 12+, 13+, 14+

## 故障排除

### 常见问题

1. **SSH连接失败**：
   - 检查主机IP和端口是否正确
   - 检查用户名和密码是否正确
   - 检查防火墙设置

2. **权限错误**：
   - 确保用户有sudo权限
   - 检查ansible.cfg中的become配置

3. **包安装失败**：
   - 检查网络连接
   - 检查包仓库配置
   - 检查包名是否正确

4. **Docker安装失败**：
   - 检查系统版本是否支持
   - 检查包依赖是否满足

5. **镜像包检测失败**：
   - 检查镜像包目录结构是否正确
   - 确保镜像包文件名符合支持的格式
   - 检查架构目录是否与目标主机匹配
   - 查看ansible.log获取详细错误信息

6. **镜像加载失败**：
   - 检查sealos命令是否可用
   - 确保镜像包格式正确
   - 检查镜像包完整性
   - 尝试重新下载镜像包

7. **架构不匹配**：
   - 确保使用与目标主机匹配的架构目录（amd64/arm64）
   - 系统自动将aarch64映射为arm64
   - 检查ansible_facts获取的架构信息

### 日志查看

Ansible执行日志会记录在项目根目录的`ansible.log`文件中，可以通过以下命令查看：

```bash
tail -f ansible.log
```

### 镜像包调试命令

```bash
# 检查tmppkg目录结构
ls -la /path/to/ansible-auto/tmppkg/

# 检查特定架构目录
ls -la /path/to/ansible-auto/tmppkg/arm64/

# 验证镜像包格式
file /path/to/ansible-auto/tmppkg/arm64/sealos_hub_5000_*.tar
```

## 相关资源

- [Ansible官方文档](https://docs.ansible.com/)
- [Kubernetes官方文档](https://kubernetes.io/docs/)
- [Docker官方文档](https://docs.docker.com/)
- [Ansible Galaxy](https://galaxy.ansible.com/)

## 版本说明

- **Ansible版本**：2.10+
- **Kubernetes版本**：v1.31.9
- **Docker版本**：24.0.7+
- **Sealos版本**：v5.1.2-rc3
- **使用的镜像**：
  - registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:v1.31.9
  - registry.cn-shanghai.aliyuncs.com/labring/helm:v3.19.2
  - registry.cn-shanghai.aliyuncs.com/labring/calico:v3.27.4
  - registry.cn-shanghai.aliyuncs.com/labring/cilium:v1.13.4
  - registry.cn-shanghai.aliyuncs.com/labring/ingress-nginx:v1.12.1
  - registry.cn-shanghai.aliyuncs.com/labring/minio-operator:v5.0.6

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request，共同改进项目。

## 联系方式

如有问题或建议，请通过GitHub Issues反馈。

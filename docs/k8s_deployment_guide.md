# Kubernetes部署指南

## 1. 概述

本指南详细介绍了使用Ansible和Sealos部署Kubernetes集群的完整流程。基于本项目的自动化部署方案，您可以快速、可靠地构建Kubernetes集群，支持master节点安装和node节点灵活添加。

## 2. 部署前准备

### 2.1 系统要求

- **操作系统**：Ubuntu 20.04 LTS+, CentOS 7+, RHEL 7+
- **硬件要求**：
  - Master节点：至少2核CPU，4GB内存，50GB磁盘
  - Node节点：至少1核CPU，2GB内存，30GB磁盘
- **网络要求**：所有节点之间网络互通，建议使用千兆以上网络
- **系统状态**：**必须是干净的系统**，没有安装过Kubernetes相关组件

### 2.2 环境检查

在部署前，系统会自动进行环境检查，确保在干净的环境中部署Kubernetes。检查内容包括：

- 是否已安装Kubernetes相关组件（kubeadm、kubectl、kubelet、sealos、k3s、rke2等）
- 是否存在旧的Kubernetes配置目录
- 是否存在旧的Docker容器
- 是否存在旧的网络配置
- 是否存在旧的存储配置

如果检查到旧的组件或配置，系统会显示详细的清理建议。

### 2.3 提前下载准备

为了加快部署速度，您可以在部署前提前下载好所需的文件和镜像包。我们提供了两种方式：使用down.sh脚本（推荐）或手动下载。

#### 2.3.1 使用down.sh脚本下载（推荐）

我们提供了一个便捷的 `down.sh` 脚本，用于自动下载和保存所有必要的镜像包。您可以在任意有网络连接的主机上运行此脚本：

**下载并运行脚本**：
```bash
# 下载脚本
curl -sfL https://raw.githubusercontent.com/your-repo/ansible-auto/main/scripts/down.sh -o down.sh
chmod +x down.sh

# 运行脚本下载镜像包
sudo ./down.sh
```

**或直接运行我们已提供的脚本**：
```bash
# 如果您已经在tmppkg目录下有down.sh脚本
sudo /tmppkg/down.sh
```

**脚本功能**：
- 自动检查sealos命令是否可用
- 创建默认的镜像包目录 `/tmppkg`
- 下载所有必要的Kubernetes镜像
- 将镜像保存为tar包，每个镜像一个tar包
- 显示下载结果，检查所有镜像包是否成功保存

**脚本配置**：
您可以通过修改脚本中的变量来自定义下载配置：
- `K8S_VERSION`：Kubernetes版本
- `SEALOS_VERSION`：Sealos版本
- `PKG_DIR`：镜像包保存目录

#### 2.3.2 手动下载（备选）

如果您需要手动下载，可以按照以下步骤操作：

**Sealos二进制文件**：

- **文件名**：`sealos_{版本号}_linux_{架构}.tar.gz`
- **示例**：`sealos_v5.1.2-rc3_linux_arm64.tar.gz` 或 `sealos_v5.1.2-rc3_linux_amd64.tar.gz`
- **下载URL**：`https://github.com/labring/sealos/releases/download/{版本号}/sealos_{版本号}_linux_{架构}.tar.gz`
- **保存位置**：`/tmp/sealos.tar.gz`

**提前下载命令**：
```bash
# 下载arm64版本
curl -sfL https://github.com/labring/sealos/releases/download/v5.1.2-rc3/sealos_v5.1.2-rc3_linux_arm64.tar.gz -o sealos.tar.gz

# 或下载amd64版本
curl -sfL https://github.com/labring/sealos/releases/download/v5.1.2-rc3/sealos_v5.1.2-rc3_linux_amd64.tar.gz -o sealos.tar.gz
```

**Kubernetes镜像**：

**需要拉取的镜像**：
- `registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:v1.31.9`
- `registry.cn-shanghai.aliyuncs.com/labring/helm:v3.9.4`
- `registry.cn-shanghai.aliyuncs.com/labring/calico:v3.24.1`
- `registry.cn-shanghai.aliyuncs.com/labring/ingress-nginx:4.1.0`
- `registry.cn-shanghai.aliyuncs.com/labring/minio-operator:v4.5.5`

**提前下载并保存镜像命令**：
```bash
# 安装Sealos（用于拉取和保存镜像）
tar -zxvf sealos.tar.gz sealos
chmod +x sealos
mv sealos /usr/local/bin/

# 拉取所需镜像
sealos pull registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:v1.31.9
sealos pull registry.cn-shanghai.aliyuncs.com/labring/helm:v3.9.4
sealos pull registry.cn-shanghai.aliyuncs.com/labring/calico:v3.24.1
sealos pull registry.cn-shanghai.aliyuncs.com/labring/ingress-nginx:4.1.0
sealos pull registry.cn-shanghai.aliyuncs.com/labring/minio-operator:v4.5.5

# 保存镜像到本地文件（分开保存，便于管理）
sealos save -o kubernetes-docker.tar registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:v1.31.9
sealos save -o helm.tar registry.cn-shanghai.aliyuncs.com/labring/helm:v3.9.4
sealos save -o calico.tar registry.cn-shanghai.aliyuncs.com/labring/calico:v3.24.1
sealos save -o ingress-nginx.tar registry.cn-shanghai.aliyuncs.com/labring/ingress-nginx:4.1.0
sealos save -o minio-operator.tar registry.cn-shanghai.aliyuncs.com/labring/minio-operator:v4.5.5
```

#### 2.3.3 传输到目标服务器

将下载好的文件传输到所有目标服务器：

```bash
# 传输Sealos二进制文件
scp sealos.tar.gz user@target-server:/tmp/

# 传输Kubernetes镜像包到默认包目录
scp kubernetes-docker.tar helm.tar calico.tar ingress-nginx.tar minio-operator.tar user@target-server:/tmppkg/

# 或传输到自定义包目录
scp kubernetes-docker.tar helm.tar calico.tar ingress-nginx.tar minio-operator.tar user@target-server:/my_custom_pkg_dir/

# 或传输整个tmppkg目录
scp -r /tmppkg user@target-server:/
```

### 2.4 离线部署准备

如果您的环境无法访问互联网，需要进行以下额外准备：

1. 按照上述步骤下载Sealos二进制文件
2. 按照上述步骤拉取并保存Kubernetes镜像
3. 将所有文件传输到所有目标服务器
4. 在部署时添加`offline_deployment=true`参数：
   ```bash
   ansible-playbook playbooks/deploy_k8s.yml -e "offline_deployment=true"
   ```

## 3. 部署流程

### 3.1 配置主机信息

编辑`inventory/hosts`文件，配置主机信息：

```ini
[masters]
master1 ansible_host=192.168.1.10

[nodes]
node1 ansible_host=192.168.1.11
node2 ansible_host=192.168.1.12
```

### 3.2 设置SSH免密登录

```bash
ansible-playbook playbooks/ssh_key_setup.yml
```

### 3.3 系统准备和优化

```bash
ansible-playbook playbooks/system_prepare.yml
```

**系统准备增强功能**：
- 修复了超时和异步执行设置的一致性问题
- 增强了网络连接检测（支持ping和curl双重检测）
- 自动配置kubectl等命令别名，便于集群管理
- 优化了hosts文件配置，解决Java无网环境解析问题
- 支持国内加速源配置，提高包安装速度
- 详细的系统优化结果验证
- 脚本同步和自动执行

### 3.4 部署Kubernetes集群

```bash
ansible-playbook playbooks/deploy_k8s.yml
```

### 3.5 可选：配置Docker（在Sealos部署完成后）

Sealos会自动部署Docker，所以通常不需要单独安装。但如果需要自定义Docker配置（如数据目录、镜像加速等），可以在部署完成后执行：

```bash
ansible-playbook playbooks/deploy_k8s.yml -e "configure_docker_after_deployment=true"
```

### 3.6 环境重置（当需要清理环境时）

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

## 4. 部署模式

### 4.1 在线部署

默认情况下，系统会使用在线模式部署Kubernetes：

1. 自动下载并安装Sealos
2. 自动拉取所需的Kubernetes镜像
3. 执行Sealos部署命令

### 4.2 离线部署

如果您的环境无法访问互联网，可以使用离线部署模式：

#### 步骤1：在有网络的环境中下载镜像

```bash
# 下载Sealos
curl -sfL https://github.com/labring/sealos/releases/download/v5.1.2-rc3/sealos_5.1.2-rc3_linux_arm64.tar.gz -o sealos.tar.gz

# 解压并安装Sealos
tar -zxvf sealos.tar.gz sealos
chmod +x sealos
mv sealos /usr/local/bin/

# 拉取所需镜像
sealos pull registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:v1.31.9
sealos pull registry.cn-shanghai.aliyuncs.com/labring/helm:v3.9.4
sealos pull registry.cn-shanghai.aliyuncs.com/labring/calico:v3.24.1
sealos pull registry.cn-shanghai.aliyuncs.com/labring/ingress-nginx:4.1.0

# 保存镜像到本地文件
sealos save -o kubernetes-images.tar registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:v1.31.9 registry.cn-shanghai.aliyuncs.com/labring/helm:v3.9.4 registry.cn-shanghai.aliyuncs.com/labring/calico:v3.24.1 registry.cn-shanghai.aliyuncs.com/labring/ingress-nginx:4.1.0
```

#### 步骤2：将镜像文件传输到目标服务器

```bash
scp kubernetes-images.tar sealos.tar.gz user@target-server:/path/to/directory/
```

#### 步骤3：在目标服务器上加载镜像

```bash
# 安装Sealos
tar -zxvf sealos.tar.gz sealos
chmod +x sealos
mv sealos /usr/local/bin/

# 加载镜像
sealos load -i kubernetes-images.tar
```

#### 步骤4：执行离线部署

```bash
ansible-playbook playbooks/deploy_k8s.yml -e "offline_deployment=true"
```

## 5. 部署验证

### 5.1 检查集群状态

部署完成后，系统会自动验证集群状态。您也可以手动检查：

```bash
# 检查节点状态
kubectl get nodes

# 检查系统组件状态
kubectl get pods -n kube-system

# 检查集群信息
kubectl cluster-info
```

### 5.2 常见问题排查

1. **节点状态为NotReady**：
   - 检查网络连接
   - 检查kubelet服务状态
   - 检查容器运行状态

2. **Pod状态异常**：
   - 检查Pod日志：`kubectl logs <pod-name> -n <namespace>`
   - 检查事件：`kubectl describe pod <pod-name> -n <namespace>`

3. **部署失败**：
   - 检查Ansible日志：`ansible.log`
   - 检查环境是否干净
   - 检查网络连接

## 6. 节点管理

### 6.1 添加新节点

1. 编辑`inventory/hosts`文件，添加新节点信息
2. 执行部署命令：
   ```bash
   ansible-playbook playbooks/deploy_k8s.yml
   ```

### 6.2 移除节点

```bash
# 在master节点上执行
kubectl drain <node-name> --delete-local-data --force --ignore-daemonsets
kubectl delete node <node-name>
```

## 7. 高级配置

### 7.1 自定义Docker配置

编辑`roles/docker/defaults/main.yml`文件，自定义Docker配置：

```yaml
docker_data_dir: "/data/docker"  # 修改Docker数据目录
docker_registry_mirrors:  # 添加镜像加速地址
  - "https://registry.docker-cn.com"
  - "https://mirror.baidubce.com"
```

### 7.2 自定义Kubernetes版本

编辑`roles/kubernetes/tasks/main.yml`文件，修改Kubernetes版本：

```yaml
- name: 拉取Kubernetes镜像（在线模式）
  shell: |
    sealos pull labring/kubernetes:v1.28.0  # 修改版本号
    sealos pull labring/helm:v3.12.0
    sealos pull labring/calico:v3.26.0
```

## 8. 最佳实践

1. **使用干净的系统**：在部署前确保系统没有安装过Kubernetes相关组件
2. **合理规划网络**：确保所有节点之间网络互通，设置合适的网络策略
3. **定期备份**：定期备份Kubernetes集群配置和重要数据
4. **监控集群**：部署监控解决方案，如Prometheus和Grafana
5. **使用版本控制**：将Ansible配置纳入版本控制，便于跟踪变更

## 9. 版本说明

- **Ansible版本**：2.10+
- **Kubernetes版本**：v1.31.9
- **Sealos版本**：v5.1.2-rc3+
- **Docker版本**：24.0.7+
- **使用的镜像**：
  - registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:v1.31.9
  - registry.cn-shanghai.aliyuncs.com/labring/helm:v3.19.2
  - registry.cn-shanghai.aliyuncs.com/labring/calico:v3.27.4
  - registry.cn-shanghai.aliyuncs.com/labring/cilium:v1.18.5
  - registry.cn-shanghai.aliyuncs.com/labring/ingress-nginx:v1.12.1
  - registry.cn-shanghai.aliyuncs.com/labring/minio-operator:v5.0.6

## 10. 最近更新

- **系统准备playbook**：修复了超时和异步执行设置的一致性问题，增强了网络连接检测
- **别名配置**：自动配置kubectl等命令别名，解决Ubuntu系统别名不生效的问题
- **环境重置playbook**：新增reset_environment.yml，支持完整的环境清理和重置
- **Docker配置**：分离Docker配置到独立文件，支持部署后自定义配置
- **镜像包管理**：增强了镜像包检测和使用逻辑，支持多种格式镜像包
- **部署流程**：优化了部署前环境检查，提供详细的清理建议
- **网络插件选择**：新增cilium网络插件支持，与calico二选一

## 10. 故障排除

### 10.1 常见错误

1. **环境不干净**：
   - 错误信息：检测到旧的Kubernetes组件或配置
   - 解决方案：清理旧的组件和配置，使用干净的系统

2. **网络问题**：
   - 错误信息：无法拉取镜像，无法连接到节点
   - 解决方案：检查网络连接，配置正确的网络设置

3. **权限问题**：
   - 错误信息：权限不足
   - 解决方案：确保使用有sudo权限的用户执行部署

### 10.2 手动重置节点 慎重
```shell
ps -ef|grep -v grep |grep 'kubelet'   | awk '{print $2}' | xargs -I % kill -9 %
ps -ef|grep -v grep |grep 'kube-prox'   | awk '{print $2}' | xargs -I % kill -9 %
ps -ef|grep -v grep |grep 'kube-apiserve'   | awk '{print $2}' | xargs -I % kill -9 %

systemctl stop docker
systemctl stop containerd
sudo ip netns delete $(sudo ip netns list | grep docker | awk '{print $1}') 2>/dev/null
brctl show docker0 | grep veth | awk '{print $1}'
sudo ip link set docker0 down
sudo ip link delete docker0 # 删除 docker0 网桥
# 查看 Docker 相关的 iptables 规则
sudo iptables -L -n | grep DOCKER
sudo iptables -t nat -L -n | grep DOCKER

# 清空 Docker 相关的 iptables 链（谨慎：若有其他规则，可选择性删除）
sudo iptables -F DOCKER 2>/dev/null
sudo iptables -F DOCKER-ISOLATION-STAGE-1 2>/dev/null
sudo iptables -F DOCKER-ISOLATION-STAGE-2 2>/dev/null
sudo iptables -F DOCKER-user 2>/dev/null
sudo iptables -t nat -F DOCKER 2>/dev/null

# 删除 Docker 相关的 iptables 链
sudo iptables -X DOCKER 2>/dev/null
sudo iptables -X DOCKER-ISOLATION-STAGE-1 2>/dev/null
sudo iptables -X DOCKER-ISOLATION-STAGE-2 2>/dev/null
sudo iptables -X DOCKER-user 2>/dev/null
sudo iptables -t nat -X DOCKER 2>/dev/null

# 保存 iptables 规则（CentOS/RHEL）
sudo service iptables save
# Ubuntu/Debian（需安装 iptables-persistent）
sudo netfilter-persistent save

rm -rf /etc/docker/network
rm -rf /var/lib/docker/network

rm -rf /var/lib/etcd
rm -rf /etc/kubernetes/
rm -rf /etc/cni/net.d
rm -rf /usr/bin/docker*
rm -rf  /usr/bin/containerd*
rm -rf /var/lib/sealos
rm -rf /var/lib/containers/
```


### 10.2 日志查看

- **Ansible日志**：`ansible.log`
- **Kubernetes日志**：`kubectl logs <pod-name> -n <namespace>`
- **Docker日志**：`docker logs <container-id>`

## 11. 总结

本部署方案基于Ansible和Sealos，提供了一种快速、可靠的Kubernetes集群部署方法。通过自动化的环境检查和部署流程，您可以在干净的环境中快速构建Kubernetes集群，支持master节点安装和node节点灵活添加。

如果您在部署过程中遇到任何问题，请参考本指南的故障排除部分，或通过GitHub Issues反馈。

# SSH密钥分发Playbook使用指南

## 概述

本指南介绍如何使用Ansible Playbook在多台服务器上批量设置SSH免密登录，适配Ubuntu 26等最新系统。

## 目录结构

```
ansible-auto/
├── inventory/          # 主机清单目录
│   └── hosts          # 示例主机配置
├── playbooks/         # Playbook文件目录
│   ├── ssh_key_setup.yml       # 完整版本（推荐）
│   └── ssh_key_simple.yml      # 简化版本（root用户）
├── ansible.cfg        # Ansible配置文件
└── docs/              # 文档目录
    └── ssh_setup_guide.md  # 本指南
```

## 准备工作

1. **安装Ansible**：
   ```bash
   sudo apt update
   sudo apt install ansible -y
   ```

2. **配置主机清单**：
   编辑 `inventory/hosts` 文件，添加您的服务器信息：
   ```ini
   [all]
   # 使用普通用户（推荐）
   node1 ansible_host=192.168.1.10 ansible_user=ubuntu
   node2 ansible_host=192.168.1.11 ansible_user=ubuntu
   
   # 或者使用root用户
   # node1 ansible_host=192.168.1.10 ansible_user=root
   ```

## Playbook选择

### 1. 完整版本（推荐）：`ssh_key_setup.yml`

**特点**：
- 使用普通用户登录，通过sudo提权
- 自动检查并生成本地SSH密钥对
- 适配Ubuntu 26等最新系统
- 自动配置sudo免密（Ubuntu 22+）
- 安全的文件权限设置
- 可选的SSH连接测试

**使用方法**：
```bash
# 首次运行需要输入密码
ansible-playbook playbooks/ssh_key_setup.yml -k -K

# 其中：
# -k, --ask-pass：询问SSH密码
# -K, --ask-become-pass：询问sudo密码
```

### 2. 简化版本：`ssh_key_simple.yml`

**特点**：
- 直接使用root用户登录
- 简化的配置流程
- 适配Ubuntu 26的root登录设置
- 适合快速部署测试环境

**使用方法**：
```bash
# 首次运行需要输入root密码
ansible-playbook playbooks/ssh_key_simple.yml -k

# 其中：
# -k, --ask-pass：询问root用户SSH密码
```

## 高级配置

### 1. 自定义SSH密钥路径

在Playbook中修改以下变量：
```yaml
vars:
  local_public_key_path: "~/.ssh/my_custom_key.pub"
```

### 2. 批量添加多台服务器

在 `inventory/hosts` 中添加更多服务器：
```ini
node3 ansible_host=192.168.1.12 ansible_user=ubuntu
node4 ansible_host=192.168.1.13 ansible_user=ubuntu
```

### 3. 使用组配置

```ini
[web_servers]
node1 ansible_host=192.168.1.10 ansible_user=ubuntu
node2 ansible_host=192.168.1.11 ansible_user=ubuntu

[db_servers]
node3 ansible_host=192.168.1.12 ansible_user=ubuntu

# 只对web_servers组执行
ansible-playbook playbooks/ssh_key_setup.yml -k -K --limit web_servers
```

## 安全最佳实践

1. **使用普通用户**：避免直接使用root用户，通过sudo提权
2. **定期轮换SSH密钥**：建议每3-6个月更换一次SSH密钥
3. **使用强密钥**：本Playbook使用4096位RSA密钥
4. **限制SSH访问**：在生产环境中，建议配置防火墙限制SSH访问
5. **启用2FA**：对于关键服务器，考虑启用双因素认证

## 故障排除

1. **连接失败**：
   - 检查服务器IP地址和用户名是否正确
   - 确保服务器已开启SSH服务
   - 检查防火墙设置，确保22端口已开放

2. **权限错误**：
   - 确保`.ssh`目录权限为700
   - 确保`authorized_keys`文件权限为600

3. **sudo免密失败**：
   - 检查`/etc/sudoers`文件是否正确配置
   - 确保用户在sudo组中

## 日志查看

Ansible执行日志会记录在项目根目录的`ansible.log`文件中，可以通过以下命令查看：
```bash
tail -f ansible.log
```

## 后续操作

成功设置SSH免密登录后，您可以：
- 运行其他Ansible Playbook进行批量配置
- 使用Ansible Ad-Hoc命令进行快速操作
- 配置Ansible Tower/AWX进行更高级的自动化管理

## 示例Ad-Hoc命令

```bash
# 测试所有服务器连接
ansible all -m ping

# 在所有服务器上执行命令
ansible all -m shell -a "uname -a"

# 复制文件到所有服务器
ansible all -m copy -a "src=/local/file dest=/remote/file"
```

## 系统要求

- **控制节点**：Ubuntu 22.04+、CentOS 8+ 或其他支持Ansible的系统
- **目标节点**：Ubuntu 20.04+、CentOS 7+ 或其他Linux发行版
- **Ansible版本**：2.10+（推荐使用最新版本）

## 支持的系统

- Ubuntu 20.04 LTS
- Ubuntu 22.04 LTS
- Ubuntu 26.04 LTS
- CentOS 7/8/Stream
- Debian 10/11/12
- RHEL 7/8/9

## 许可证

MIT

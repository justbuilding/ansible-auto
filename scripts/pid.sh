cat << "EOF" > /root/pid.sh
#!/bin/bash
#pid解析 进程解析 进程目录解析 pid详细信息解析
# 功能：根据输入的PID，采集进程的目录、CPU、内存（MB）等信息，新增端口信息采集
# 用法：./proc_info.sh <PID>

# ====================== 1. 参数检查 ======================
if [ $# -ne 1 ]; then
    echo "用法错误！正确用法：$0 <进程PID>"
    echo "示例：$0 3062"
    exit 1
fi

PID=$1

# 检查PID是否存在
if [ ! -d "/proc/$PID" ]; then
    echo "错误：PID $PID 对应的进程不存在！"
    exit 1
fi

# ====================== 2. 定义辅助函数（单位转换：KB转MB） ======================
kb_to_mb() {
    # 入参：KB数值，返回：保留2位小数的MB数值
    if [ -z "$1" ] || [ "$1" = "0" ]; then
        echo "0.00"
        return
    fi
    echo "scale=2; $1/1024" | bc
}

# ====================== 3. 采集进程信息 ======================
# 3.1 基础信息（进程名、用户、状态、启动时间、累计CPU时间）
PROC_NAME=$(ps -p $PID -o comm=)          # 进程名
PROC_USER=$(ps -p $PID -o user=)          # 所属用户
PROC_STATE=$(ps -p $PID -o stat=)         # 进程状态（R运行/S睡眠等）
PROC_START=$(ps -p $PID -o lstart=)       # 启动时间
PROC_CPUTIME=$(ps -p $PID -o cputime=)    # 累计CPU时间

# 3.2 CPU信息（实时CPU使用率，%）
PROC_CPU=$(ps -p $PID -o %cpu= | awk '{printf "%.2f", $0}')

# 3.3 内存信息（RSS物理内存、VSZ虚拟内存，转MB；内存使用率%）
PROC_RSS_K=$(ps -p $PID -o rss=)          # RSS（物理内存），单位KB
PROC_VSZ_K=$(ps -p $PID -o vsz=)          # VSZ（虚拟内存），单位KB
PROC_MEM_PERCENT=$(ps -p $PID -o %mem= | awk '{printf "%.2f", $0}')  # 内存使用率%
PROC_RSS_MB=$(kb_to_mb $PROC_RSS_K)       # 转换为MB
PROC_VSZ_MB=$(kb_to_mb $PROC_VSZ_K)

# 3.4 目录信息（当前工作目录、可执行文件路径、根目录）
# 处理权限问题（普通用户可能无权限读取root进程的目录）
if [ -r "/proc/$PID/cwd" ]; then
    PROC_CWD=$(readlink /proc/$PID/cwd)
else
    PROC_CWD="无读取权限（需root）"
fi

if [ -r "/proc/$PID/exe" ]; then
    PROC_EXE=$(readlink /proc/$PID/exe)
else
    PROC_EXE="无读取权限（需root）"
fi

if [ -r "/proc/$PID/root" ]; then
    PROC_ROOT=$(readlink /proc/$PID/root)
else
    PROC_ROOT="无读取权限（需root）"
fi

# 3.5 启动命令（转换空字符为空格，便于阅读）
PROC_CMD=$(cat /proc/$PID/cmdline 2>/dev/null | tr '\0' ' ' | sed 's/ *$//')

# ====================== 3.6 修正：端口信息采集 ======================
# 重新设计解析逻辑，兼容更多ss输出格式
# -t: TCP协议 -u: UDP协议 -l: 监听状态 -n: 数字显示端口 -p: 显示进程信息
PROC_PORTS=$(ss -tulnp 2>/dev/null | grep -w "pid=$PID" | awk '{
    # 遍历所有字段，查找包含端口的字段（格式为 *:端口 或 [::]:端口 等）
    for(i=1; i<=NF; i++) {
        # 匹配 冒号+数字 结尾的字段（如 *:8729、[::]:38888）
        if ($i ~ /.*:[0-9]+$/) {
            # 提取端口号（冒号后的数字）
            split($i, parts, ":");
            port = parts[length(parts)];
            # 提取协议（第1个字段，如 tcp、udp）
            proto = $1;
            # 提取状态（第2个字段，如 LISTEN、ESTABLISHED）
            state = $2;
            printf "%s (%s) - 端口: %s\n", proto, state, port;
            break;
        }
    }
}')

# 处理端口信息为空的情况
if [ -z "$PROC_PORTS" ]; then
    # 检查是否是权限问题导致无法获取
    if [ "$(id -u)" -ne 0 ]; then
        PROC_PORTS="无关联端口（或无root权限无法查看）"
    else
        PROC_PORTS="无关联端口"
    fi
fi

# ====================== 4. 格式化输出 ======================
echo -e "========================================"
echo -e "          进程信息汇总 (PID: $PID)          "
echo -e "========================================"
echo -e "进程名          : $PROC_NAME"
echo -e "所属用户        : $PROC_USER"
echo -e "进程状态        : $PROC_STATE"
echo -e "启动时间        : $PROC_START"
echo -e "累计CPU时间     : $PROC_CPUTIME"
echo -e "----------------------------------------"
echo -e "CPU使用率       : ${PROC_CPU}%"
echo -e "----------------------------------------"
echo -e "内存使用率      : ${PROC_MEM_PERCENT}%"
echo -e "物理内存(RSS)   : ${PROC_RSS_MB} MB (原始值: ${PROC_RSS_K} KB)"
echo -e "虚拟内存(VSZ)   : ${PROC_VSZ_MB} MB (原始值: ${PROC_VSZ_K} KB)"
echo -e "----------------------------------------"
echo -e "当前工作目录(cwd): $PROC_CWD"
echo -e "可执行文件路径(exe): $PROC_EXE"
echo -e "进程根目录(root) : $PROC_ROOT"
echo -e "----------------------------------------"
echo -e "启动命令        : $PROC_CMD"
echo -e "----------------------------------------"
echo -e "关联端口信息    : "
# 优化端口输出格式，每行端口信息缩进对齐
echo -e "$PROC_PORTS" | awk '{printf "                  %s\n", $0}'
echo -e "========================================进程状态解析"

# 统一对齐的进程状态说明输出（补充Sl，各列用制表符+空格对齐）
echo -e "S\tInterruptible Sleep\t可中断睡眠（浅度睡眠），等待事件（网络/IO/定时器），可被信号唤醒（Java进程常见主状态）"
echo -e "l\tMulti-threaded\t\t多线程进程/线程组首领（Java进程必带附加属性）"
echo -e "Sl\tS+l 组合状态\t\t可中断睡眠的多线程进程（Java进程最常见状态）"
echo -e "R\tRunning/Runnable\t运行中（或就绪态），占用CPU或排队等待CPU调度"
echo -e "D\tUninterruptible Sleep\t不可中断睡眠（深度睡眠），等待磁盘IO，信号无法唤醒"
echo -e "Z\tZombie\t\t\t僵尸进程，进程终止但父进程未回收资源，需排查清理"
echo -e "T\tStopped\t\t\t暂停状态，被SIGSTOP信号暂停，可通过SIGCONT恢复"
EOF

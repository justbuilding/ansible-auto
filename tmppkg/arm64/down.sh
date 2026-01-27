#!/bin/bash
set -euo pipefail

# 定义目标目录
TARGET_DIR="/tmppkg"
# 定义默认的镜像列表文件路径
DEFAULT_IMAGE_FILE="${TARGET_DIR}/image.txt"

# 创建目标目录（如果不存在）
mkdir -p "${TARGET_DIR}"

# 函数：生成镜像列表到默认文件
generate_image_list() {
    echo "===== 开始生成当前主机的Docker镜像列表 ====="
    # 获取所有镜像（格式：仓库:标签 镜像ID 创建时间 大小），只提取仓库:标签列
    docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>" > "${DEFAULT_IMAGE_FILE}"
    
    if [ -s "${DEFAULT_IMAGE_FILE}" ]; then
        echo "✅ 镜像列表已生成到：${DEFAULT_IMAGE_FILE}"
        echo "📝 你可以编辑该文件，保留需要导出的镜像，然后执行：$0 ${DEFAULT_IMAGE_FILE}"
    else
        echo "⚠️ 未检测到有效镜像，生成的文件为空"
    fi
}

# 函数：从指定文件读取镜像并导出（增加存在性检查）
export_images_from_file() {
    local image_file="$1"

    # 检查文件是否存在且非空
    if [ ! -f "${image_file}" ]; then
        echo "❌ 错误：文件 ${image_file} 不存在！"
        exit 1
    fi

    if [ ! -s "${image_file}" ]; then
        echo "❌ 错误：文件 ${image_file} 为空，请先编辑添加需要导出的镜像！"
        exit 1
    fi

    echo "===== 开始导出镜像（文件：${image_file}） ====="
    # 逐行读取文件（跳过空行和注释行）
    while IFS= read -r image; do
        # 跳过空行和以#开头的注释行
        if [[ -z "${image}" || "${image}" =~ ^# ]]; then
            continue
        fi

        # 清理镜像名中的特殊字符（/:@. 等），避免文件名非法
        safe_image_name=$(echo "${image}" | sed -e 's/[:\/@.]/_/g' -e 's/__*/_/g')
        output_file="${TARGET_DIR}/${safe_image_name}.tar"

        # 核心修改：检查目标文件是否已存在
        if [ -f "${output_file}" ]; then
            echo "⏭️ 跳过：${image}（文件 ${output_file} 已存在）"
            continue
        fi

        echo "🔄 正在导出：${image} -> ${output_file}"
        # 导出镜像（忽略导出失败，继续处理下一个）
        if docker save -o "${output_file}" "${image}"; then
            echo "✅ 导出成功：${output_file}"
        else
            echo "❌ 导出失败：${image}"
            # 保留失败的空文件，方便排查
            rm -f "${output_file}" || true
        fi
    done < "${image_file}"

    echo "===== 镜像导出完成 ====="
    echo "📂 导出的镜像文件位于：${TARGET_DIR}"
}

# 主逻辑：判断参数数量
if [ $# -eq 0 ]; then
    # 无参数：生成镜像列表
    generate_image_list
elif [ $# -eq 1 ]; then
    # 1个参数：导出指定文件中的镜像
    export_images_from_file "$1"
else
    # 参数过多：提示用法
    echo "❌ 错误：参数数量不正确！"
    echo "📖 用法："
    echo "  1. 生成镜像列表：$0"
    echo "  2. 导出指定镜像：$0 <镜像列表文件路径>"
    exit 1
fi
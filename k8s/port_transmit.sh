#!/usr/bin/env bash
set -e

NAMESPACE=${NAMESPACE:-default}

usage() {
    cat <<EOF
用法:
  $0 [options]

选项:
  -k <keyword>    Pod 名称关键字
  -n <namespace>  Namespace (默认: default)
  -p <pod_port>   Pod 内端口
  -l <local_port> 本地端口
  -h              显示帮助

示例:
  $0
  $0 -k api -n dev -p 8080 -l 18080
EOF
    exit 0
}

# 解析参数
while getopts ":k:n:p:l:h" opt; do
    case $opt in
        k) KEYWORD="$OPTARG" ;;
        n) NAMESPACE="$OPTARG" ;;
        p) POD_PORT="$OPTARG" ;;
        l) LOCAL_PORT="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# 交互式补充缺失参数
if [ -z "$KEYWORD" ]; then
    read -rp "请输入 Pod 名称关键字: " KEYWORD
fi

# 获取活跃 Pod
PODS=($(kubectl get pods -n "$NAMESPACE" \
    --field-selector=status.phase=Running \
    -o jsonpath='{.items[*].metadata.name}' \
    | tr ' ' '\n' | grep "$KEYWORD"))

if [ ${#PODS[@]} -eq 0 ]; then
    echo "❌ 没有找到包含关键字 '$KEYWORD' 的活跃 Pod"
    exit 1
fi

# 如果只有一个 Pod，自动选中
if [ ${#PODS[@]} -eq 1 ]; then
    POD_NAME="${PODS[0]}"
    echo "✅ 自动选择 Pod: $POD_NAME"
else
    echo "活跃 Pod 列表:"
    for i in "${!PODS[@]}"; do
        echo "[$i] ${PODS[$i]}"
    done

    read -rp "请选择 Pod (0-$(( ${#PODS[@]} - 1 ))): " IDX
    if ! [[ "$IDX" =~ ^[0-9]+$ ]] || [ "$IDX" -ge "${#PODS[@]}" ]; then
        echo "❌ 输入无效"
        exit 1
    fi
    POD_NAME="${PODS[$IDX]}"
fi

# 端口输入（如未传参）
if [ -z "$POD_PORT" ]; then
    read -rp "请输入 Pod 内端口: " POD_PORT
fi

if [ -z "$LOCAL_PORT" ]; then
    read -rp "请输入本地端口: " LOCAL_PORT
fi

if ! [[ "$POD_PORT" =~ ^[0-9]+$ ]] || ! [[ "$LOCAL_PORT" =~ ^[0-9]+$ ]]; then
    echo "❌ 端口必须是数字"
    exit 1
fi

echo "🚀 开始端口转发"
echo "   Namespace : $NAMESPACE"
echo "   Pod       : $POD_NAME"
echo "   Port      : $LOCAL_PORT -> $POD_PORT"
echo

kubectl port-forward -n "$NAMESPACE" pod/"$POD_NAME" "$LOCAL_PORT:$POD_PORT"


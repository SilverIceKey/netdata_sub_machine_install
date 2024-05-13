#!/bin/bash

# 检查并安装 uuidgen
if ! command -v uuidgen &> /dev/null
then
    echo "未找到 uuidgen，正在安装中..."
    # 根据系统类型安装 uuidgen
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            sudo apt-get update && sudo apt-get install -y uuid-runtime
        elif [ -f /etc/redhat-release ]; then
            sudo yum install -y util-linux
        elif [ -f /etc/arch-release ]; then
            sudo pacman -S --noconfirm util-linux
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # MacOS 系统，通常默认已安装 uuidgen
        echo "当前操作系统为 MacOS。通常 uuidgen 默认已安装。"
    else
        echo "不支持的操作系统类型。请手动安装 uuidgen。"
        exit 1
    fi
fi

# 读取主服务器的 HTTPS 地址
read -p "请输入主 Netdata 服务器的 HTTPS 地址（例如：https://example.com:19900）: " MASTER_URL

# 生成随机 API 密钥
API_KEY=$(uuidgen)

# 生成唯一的机器标识符（UUID）
MACHINE_UUID=$(uuidgen)

# 机器名称（使用主机名或自定义）
MACHINE_NAME=$(hostname)

# 安装 Netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --non-interactive --disable-telemetry

# 配置从服务器向主服务器的 stream
cat <<EOF | sudo tee /etc/netdata/stream.conf
[stream]
    enabled = yes
    destination = $MASTER_URL
    api key = $API_KEY
    timeout seconds = 60
    default port = 19999
    buffer size bytes = 1048576
    reconnect delay seconds = 5
    initial clock resync iterations = 60
    hostname = $MACHINE_NAME
    machine guid = $MACHINE_UUID
EOF

# 关闭 Netdata 的 Web 界面
sudo tee /etc/netdata/netdata.conf > /dev/null <<EOT
[web]
    mode = none
EOT

# 重启 Netdata 服务以应用配置
sudo systemctl restart netdata

# 输出必要的配置信息
echo "请按以下信息配置您的主 Netdata 服务器中的 stream.conf 文件："
echo "[${MACHINE_NAME}]"
echo "    enabled = yes"
echo "    api key = $API_KEY"
echo "    default port = 19999"
echo "    buffer size bytes = 1048576"
echo "    reconnect delay seconds = 5"
echo "    hostname = ${MACHINE_NAME}"
echo "    machine guid = ${MACHINE_UUID}"

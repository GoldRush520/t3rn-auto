#!/bin/bash

BASE_DIR="$HOME"
if [ "$EUID" -eq 0 ]; then
    BASE_DIR="/root"
fi
EXECUTOR_DIR="$BASE_DIR/executor/executor/bin"
CONFIG_FILE="$EXECUTOR_DIR/executor.conf"

install_node() {
    echo "请输入节点私匙: "
    read -s PRIVATE_KEY
    echo "安装节点..."

    curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | \
    grep -Po '"tag_name": "\K.*?(?=")' | \
    xargs -I {} wget -P "$BASE_DIR" https://github.com/t3rn/executor-release/releases/download/{}/executor-linux-{}.tar.gz
    
    tar -xzf "$BASE_DIR/executor-linux-*.tar.gz" -C "$BASE_DIR"
    mkdir -p "$EXECUTOR_DIR"
    cd "$EXECUTOR_DIR" || exit 1

    cat > "$CONFIG_FILE" << EOL
ENVIRONMENT=testnet
LOG_LEVEL=debug
LOG_PRETTY=false
EXECUTOR_MAX_L3_GAS_PRICE=15000
EXECUTOR_PROCESS_BIDS_ENABLED=true
EXECUTOR_PROCESS_ORDERS_ENABLED=true
EXECUTOR_PROCESS_CLAIMS_ENABLED=true
ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,optimism-sepolia,unichain-sepolia,blast-sepolia,l2rn'
RPC_ENDPOINTS='{
    "l2rn": ["https://b2n.rpc.caldera.xyz/http"],
    "arbt": ["https://arbitrum-sepolia.drpc.org", "https://sepolia-rollup.arbitrum.io/rpc"],
    "bast": ["https://base-sepolia-rpc.publicnode.com", "https://base-sepolia.drpc.org"],
    "opst": ["https://sepolia.optimism.io", "https://optimism-sepolia.drpc.org"],
    "unit": ["https://unichain-sepolia.drpc.org", "https://sepolia.unichain.org"]
}'
PRIVATE_KEY_LOCAL=$PRIVATE_KEY
EOL

    source "$CONFIG_FILE"
    nohup ./executor > "$EXECUTOR_DIR/executor.log" 2>&1 &
    echo "节点安装完成!"
}

update_version() {
    echo "检查版本更新..."
    
    LATEST_VERSION=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    
    if ls "$BASE_DIR/executor-linux-*.tar.gz" 2>/dev/null; then
        CURRENT_FILE=$(ls "$BASE_DIR/executor-linux-*.tar.gz")
        CURRENT_VERSION=$(echo "$CURRENT_FILE" | grep -oP 'executor-linux-\K.*?(?=.tar.gz)')
    else
        CURRENT_VERSION="none"
    fi
    
    if [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
        echo "发现新版本! 节点更新从 $CURRENT_VERSION --> $LATEST_VERSION..."
        
        # Stop current executor process if running
        if pgrep -f "executor" > /dev/null; then
            echo "停止当前版本..."
            pkill -f "executor"
            sleep 2
        fi
        
        rm -f "$BASE_DIR/executor-linux-*.tar.gz"
        
        wget -P "$BASE_DIR" https://github.com/t3rn/executor-release/releases/download/"$LATEST_VERSION"/executor-linux-"$LATEST_VERSION".tar.gz
        tar -xzf "$BASE_DIR/executor-linux-$LATEST_VERSION.tar.gz" -C "$BASE_DIR"
        
        cd "$EXECUTOR_DIR" || exit 1
        
        if [ -f "$CONFIG_FILE" ]; then
            source "$CONFIG_FILE"
            echo "启动节点新版本..."
            nohup ./executor > "$EXECUTOR_DIR/executor.log" 2>&1 &
            echo "节点已更新并重新启动!"
        else
            echo "错误：未找到配置文件，请重新安装节点."
        fi
    else
        echo "节点正在运行中，当前版本是: $LATEST_VERSION"
    fi
}

view_logs() {
    echo "显示日志 (使用 Ctrl+C to 退出..."
    tail -f "$EXECUTOR_DIR/executor.log"
}

start_monitoring() {
    if [ -f "$EXECUTOR_DIR/monitor.pid" ]; then
        echo "监控节点程序已在运行中!"
        return
    fi
    
    echo "后台启动节点监控程序，5分钟检查一次节点是否运行..."
    nohup bash -c "cd $EXECUTOR_DIR; source $CONFIG_FILE; while true; do
        if pgrep -f 'executor' > /dev/null; then
            TIMESTAMP=\$(date '+%Y-%m-%d %H:%M:%S')
            echo \"[\$TIMESTAMP] Node is running\" >> check.log
        else
            TIMESTAMP=\$(date '+%Y-%m-%d %H:%M:%S')
            echo \"[\$TIMESTAMP] Node not running, starting executor...\" >> check.log
            nohup ./executor > executor.log 2>&1 &
        fi
        sleep 300
    done" > "$EXECUTOR_DIR/monitor.log" 2>&1 & echo $! > "$EXECUTOR_DIR/monitor.pid"
    echo "后台监控已启动!"
}

stop_monitoring() {
    if [ ! -f "$EXECUTOR_DIR/monitor.pid" ]; then
        echo "监控程序未运行!"
        return
    fi
    
    echo "Stopping background monitoring..."
    kill $(cat "$EXECUTOR_DIR/monitor.pid")
    rm -f "$EXECUTOR_DIR/monitor.pid"
    echo "监控程序已停止!"
}

# Main menu
while true; do
    echo   "_________________________________________________________________"
    echo   "                               说明"
    echo   "私匙保存在$EXECUTOR_DIR/executor.conf，注意服务器安全"
    echo   "运行节点需要base,arb,op,uni每条链至少5个测试ETH"
    echo   "检查收益浏览器：https://b2n.explorer.caldera.xyz/"
    echo   "_________________________________________________________________"
    echo "1. 安装T3RN节点"
    echo "2. 检查版本"
    echo "3. 显示日志"
    echo "4. 启动节点/启动监控"
    echo "5. 停止监控节点"
    echo "6. 退出"
    echo -n "输入选项 (1-6): "
    
    read choice
    
    case $choice in
        1)
            install_node
            ;;
        2)
            update_version
            ;;
        3)
            view_logs
            ;;
        4)
            start_monitoring
            ;;
        5)
            stop_monitoring
            ;;
        6)
            echo "退出脚本..."
 LPS            exit 0
            ;;
        *)
            echo "无效输入请选择 1-6"
            ;;
    esac
done

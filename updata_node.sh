clear
echo ___________________________________________________________________
echo 
echo 说明：这个是T3rn的一键脚本，注意如下：
echo 这个脚本只适合于root用户，其他用户自己修改路径或设置成变量，懒得改了
echo 查看日志命令是： tail -f executor.log
echo 按任意键安装/更新最新节点
echo ___________________________________________________________________
echo 粘贴节点私匙后回车
read -s PRIVATE_KEY
rm -f executor-linux-*.tar.gz
curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | \
grep -Po '"tag_name": "\K.*?(?=")' | \
xargs -I {} wget https://github.com/t3rn/executor-release/releases/download/{}/executor-linux-{}.tar.gz
sleep 2
tar -xzf executor-linux-*.tar.gz
pkill -f executor
export ENVIRONMENT=testnet
export LOG_LEVEL=debug
export LOG_PRETTY=false
export EXECUTOR_MAX_L3_GAS_PRICE=5000
export EXECUTOR_PROCESS_BIDS_ENABLED=true
export EXECUTOR_PROCESS_ORDERS_ENABLED=true
export EXECUTOR_PROCESS_CLAIMS_ENABLED=true
export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,optimism-sepolia,unichain-sepolia,blast-sepolia,l2rn'
export PRIVATE_KEY_LOCAL="$PRIVATE_KEY"
export RPC_ENDPOINTS='{
    "l2rn": ["https://b2n.rpc.caldera.xyz/http"],
    "arbt": ["https://arbitrum-sepolia.drpc.org", "https://sepolia-rollup.arbitrum.io/rpc"],
    "bast": ["https://base-sepolia-rpc.publicnode.com", "https://base-sepolia.drpc.org"],
    "opst": ["https://sepolia.optimism.io", "https://optimism-sepolia.drpc.org"],
    "unit": ["https://unichain-sepolia.drpc.org", "https://sepolia.unichain.org"]
}'
sleep 2
nohup /root/executor/executor/bin/executor > executor.log 2>&1 &
echo 安装并启动，查看日志命令是： tail -f executor.log

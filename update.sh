rm -f executor-linux-*.tar.gz
curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | \
grep -Po '"tag_name": "\K.*?(?=")' | \
xargs -I {} wget https://github.com/t3rn/executor-release/releases/download/{}/executor-linux-{}.tar.gz
pkill -f ./executor
sleep 5
tar -xzf executor-linux-*.tar.gz
pkill -f ./executor

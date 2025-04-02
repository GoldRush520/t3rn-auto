# T3RN一键盘节点
    curl -O https://raw.githubusercontent.com/8280998/t3rn/refs/heads/main/t3_node.sh && chmod +x t3_node.sh  && ./t3_node.sh


# t3rn  最低ETH在10之前，都可以用op_uni_100.py
uni-op跨链后到帐时间不确定。如果要循环运行刷币，需要留够间隔时间等eth回帐。

说明：T3RN自动SWAP脚本，单个地址SWAP上限奖励是2万个BRN。注意：目前官方已提高到最低5ETH跨链才有奖励，请运行op_uni_50.py这个脚本，跨链数额为5ETH

当前支持op和uni互刷，刷之前检查各链上是否有对应的测试eth。

## 安装支持
    pip install web3 eth_account

    pip install --upgrade web3

参数配置：只能修改私匙和互跨次数，跨链金额不能更改。需要更改的请修改代码中对应的input data。不懂代码请不要修改每次跨链的5.只修改私匙和次数。

   PRIVATE_KEY = "0x1234567890"  #填写私匙
   
   AMOUNT_ETH = 5  # 每次跨链金额（单位：ETH）
   
   TIMES = 50  # 互跨来回次数
   
### 1 op_uni_50.py OP<->UNI 互SWAP刷奖励 注意：官方已提高到最低5ETH跨链才有奖励。本脚本使用3.3ETH
    python3 op_uni_50.py
运行后如下截图
![image](https://github.com/user-attachments/assets/b84918fa-db30-41d1-b53c-e49541689c61)




from web3 import Web3

# === 可自定义参数（请在此处填写） ===
PRIVATE_KEY = "0x1234567890"
AMOUNT_ETH = 0.3  # 每次跨链金额（单位：ETH）
TIMES = 1000  # 互跨来回次数

# OP 测试网 RPC 地址
OP_RPC_URL = "https://sepolia.optimism.io"
# ARB 测试网 RPC 地址
ARB_RPC_URL = "https://sepolia-rollup.arbitrum.io/rpc"

# OP 测试网合约地址
OP_CONTRACT_ADDRESS = "0xb6Def636914Ae60173d9007E732684a9eEDEF26E"
# ARB 测试网合约地址
ARB_CONTRACT_ADDRESS = "0x22B65d0B9b59af4D3Ed59F18b9Ad53f5F4908B54"


SUCCESSFUL_DATA = "0x56591d5961726274000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000601f9c55871acbf7e0fda87d47e683aa9cb1abe20000000000000000000000000000000000000000000000000429a0dced33245c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000429d069189e0000"

ARB_DATA = "0x56591d596f707374000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000601f9c55871acbf7e0fda87d47e683aa9cb1abe20000000000000000000000000000000000000000000000000429a4668d47ea2c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000429d069189e0000"


OP_TO_ARB_DATA = SUCCESSFUL_DATA.replace("6f707374", "61726274")


w3_op = Web3(Web3.HTTPProvider(OP_RPC_URL))
w3_arb = Web3(Web3.HTTPProvider(ARB_RPC_URL))

if not w3_op.is_connected():
    raise Exception("无法连接到 OP 测试网")
if not w3_arb.is_connected():
    raise Exception("无法连接到 ARB 测试网")

account = w3_op.eth.account.from_key(PRIVATE_KEY)

# 从 OP 跨到 ARB
def bridge_op_to_arb(amount_eth):
    try:
        amount_wei = w3_op.to_wei(amount_eth, 'ether')
        nonce = w3_op.eth.get_transaction_count(account.address)
        tx = {
            'from': account.address,
            'to': OP_CONTRACT_ADDRESS,
            'value': amount_wei,
            'nonce': nonce,
            'gas': 200000,
            'gasPrice': w3_op.to_wei(0.1, 'gwei'),
            'chainId': 11155420,
            'data': OP_TO_ARB_DATA
        }
        print(f"OP -> ARB: Sending {amount_eth} ETH")
        signed_tx = w3_op.eth.account.sign_transaction(tx, PRIVATE_KEY)
        raw_tx = signed_tx.raw_transaction if hasattr(signed_tx, 'raw_transaction') else signed_tx['raw']
        tx_hash = w3_op.eth.send_raw_transaction(raw_tx)
        print(f"OP -> ARB 跨链交易已发送，交易哈希: {w3_op.to_hex(tx_hash)}")
        tx_receipt = w3_op.eth.wait_for_transaction_receipt(tx_hash)
        print(f"交易已确认，区块号: {tx_receipt.blockNumber}")
    except Exception as e:
        print(f"OP -> ARB 跨链失败，错误: {e}")
        return False  # 表示失败
    return True  # 表示成功

# 从 ARB 跨回 OP
def bridge_arb_to_op(amount_eth):
    try:
        amount_wei = w3_arb.to_wei(amount_eth, 'ether')
        nonce = w3_arb.eth.get_transaction_count(account.address)
        tx = {
            'from': account.address,
            'to': ARB_CONTRACT_ADDRESS,
            'value': amount_wei,
            'nonce': nonce,
            'gas': 400000,
            'gasPrice': w3_arb.to_wei(0.1, 'gwei'),
            'chainId': 421614,
            'data': ARB_DATA
        }
        print(f"ARB -> OP: Sending {amount_eth} ETH")
        signed_tx = w3_arb.eth.account.sign_transaction(tx, PRIVATE_KEY)
        raw_tx = signed_tx.raw_transaction if hasattr(signed_tx, 'raw_transaction') else signed_tx['raw']
        tx_hash = w3_arb.eth.send_raw_transaction(raw_tx)
        print(f"ARB -> OP 跨链交易已发送，交易哈希: {w3_arb.to_hex(tx_hash)}")
        tx_receipt = w3_arb.eth.wait_for_transaction_receipt(tx_hash)
        print(f"交易已确认，区块号: {tx_receipt.blockNumber}")
    except Exception as e:
        print(f"ARB -> OP 跨链失败，错误: {e}")
        return False  # 表示失败
    return True  # 表示成功

# 执行互跨
print(f"开始 OP 和 ARB 互跨 {TIMES} 次，每次 {AMOUNT_ETH} ETH")
for i in range(TIMES):
    print(f"\n第 {i+1} 次互跨：")
    # OP -> ARB
    bridge_op_to_arb(AMOUNT_ETH)
    # ARB -> OP
    bridge_arb_to_op(AMOUNT_ETH)

print("\n所有跨链操作已完成！")

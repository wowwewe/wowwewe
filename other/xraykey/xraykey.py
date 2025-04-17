#!/usr/bin/env python3
from cryptography.hazmat.primitives.asymmetric import x25519
from cryptography.hazmat.primitives import serialization
import base64
import uuid  # 新增 uuid 库

# 生成私钥
private_key = x25519.X25519PrivateKey.generate()

# 导出私钥字节
private_bytes = private_key.private_bytes(
    encoding=serialization.Encoding.Raw,
    format=serialization.PrivateFormat.Raw,
    encryption_algorithm=serialization.NoEncryption()
)

# 获取公钥
peer_public_key = private_key.public_key()

# 导出公钥字节
public_bytes = peer_public_key.public_bytes(
    encoding=serialization.Encoding.Raw,
    format=serialization.PublicFormat.Raw
)

# 转换成 xray 风格（Base64 URL-safe，去掉=号）
private_key_xray = base64.urlsafe_b64encode(private_bytes).decode().rstrip("=")
public_key_xray = base64.urlsafe_b64encode(public_bytes).decode().rstrip("=")

# 生成一个随机 UUID
random_uuid = str(uuid.uuid4())

# 打印结果
print("Private key:", private_key_xray)
print("Public key :", public_key_xray)
print("UUID        :", random_uuid)


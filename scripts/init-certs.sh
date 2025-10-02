#!/bin/bash

echo "??? 配置 SSL 证书..."

# 检查是否提供了 ZeroSSL 和 Cloudflare 的凭证
if [ -n "$ZEROSSL_EAB_KID" ] && [ -n "$ZEROSSL_EAB_HMAC_KEY" ] && [ -n "$CLOUDFLARE_TOKEN" ]; then
    echo "?? 使用 ZeroSSL 和 Cloudflare 申请证书..."
    
    # 安装 acme.sh
    if [ ! -f /root/.acme.sh/acme.sh ]; then
        echo "?? 安装 acme.sh..."
        curl https://get.acme.sh | sh -s email=admin@$DOMAIN
    fi

    # 设置 ZeroSSL 为默认 CA
    /root/.acme.sh/acme.sh --set-default-ca --server zerossl

    # 注册 ZeroSSL 账户
    echo "?? 注册 ZeroSSL 账户..."
    /root/.acme.sh/acme.sh --register-account \
        --server zerossl \
        --eab-kid "$ZEROSSL_EAB_KID" \
        --eab-hmac-key "$ZEROSSL_EAB_HMAC_KEY"

    # 申请证书
    echo "?? 申请 SSL 证书..."
    /root/.acme.sh/acme.sh --issue \
        --dns dns_cf \
        -d "$DOMAIN" \
        -d "*.$DOMAIN" \
        --key-file /config/cert/private.key \
        --fullchain-file /config/cert/certificate.crt \
        --reloadcmd "echo '证书已更新'; systemctl reload nginx 2>/dev/null || true"

    # 复制证书到指定位置
    cp /config/cert/private.key /config/cert/domain.key
    cp /config/cert/certificate.crt /config/cert/domain.crt

    echo "? 证书申请完成"

else
    echo "??  未提供证书申请凭证，生成自签名证书..."
    
    # 生成自签名证书
    openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
        -subj "/C=CN/ST=Beijing/L=Beijing/O=AllInOne/CN=$DOMAIN" \
        -keyout /config/cert/domain.key \
        -out /config/cert/domain.crt

    echo "? 自签名证书生成完成"
    echo "??  注意: 自签名证书可能不被所有客户端信任"
fi

# 设置证书权限
chmod 600 /config/cert/domain.key
chmod 644 /config/cert/domain.crt

echo "?? 证书位置: /config/cert/"
echo "?? 私钥: domain.key"
echo "?? 证书: domain.crt"
#!/bin/bash

echo "??? ���� SSL ֤��..."

# ����Ƿ��ṩ�� ZeroSSL �� Cloudflare ��ƾ֤
if [ -n "$ZEROSSL_EAB_KID" ] && [ -n "$ZEROSSL_EAB_HMAC_KEY" ] && [ -n "$CLOUDFLARE_TOKEN" ]; then
    echo "?? ʹ�� ZeroSSL �� Cloudflare ����֤��..."
    
    # ��װ acme.sh
    if [ ! -f /root/.acme.sh/acme.sh ]; then
        echo "?? ��װ acme.sh..."
        curl https://get.acme.sh | sh -s email=admin@$DOMAIN
    fi

    # ���� ZeroSSL ΪĬ�� CA
    /root/.acme.sh/acme.sh --set-default-ca --server zerossl

    # ע�� ZeroSSL �˻�
    echo "?? ע�� ZeroSSL �˻�..."
    /root/.acme.sh/acme.sh --register-account \
        --server zerossl \
        --eab-kid "$ZEROSSL_EAB_KID" \
        --eab-hmac-key "$ZEROSSL_EAB_HMAC_KEY"

    # ����֤��
    echo "?? ���� SSL ֤��..."
    /root/.acme.sh/acme.sh --issue \
        --dns dns_cf \
        -d "$DOMAIN" \
        -d "*.$DOMAIN" \
        --key-file /config/cert/private.key \
        --fullchain-file /config/cert/certificate.crt \
        --reloadcmd "echo '֤���Ѹ���'; systemctl reload nginx 2>/dev/null || true"

    # ����֤�鵽ָ��λ��
    cp /config/cert/private.key /config/cert/domain.key
    cp /config/cert/certificate.crt /config/cert/domain.crt

    echo "? ֤���������"

else
    echo "??  δ�ṩ֤������ƾ֤��������ǩ��֤��..."
    
    # ������ǩ��֤��
    openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
        -subj "/C=CN/ST=Beijing/L=Beijing/O=AllInOne/CN=$DOMAIN" \
        -keyout /config/cert/domain.key \
        -out /config/cert/domain.crt

    echo "? ��ǩ��֤���������"
    echo "??  ע��: ��ǩ��֤����ܲ������пͻ�������"
fi

# ����֤��Ȩ��
chmod 600 /config/cert/domain.key
chmod 644 /config/cert/domain.crt

echo "?? ֤��λ��: /config/cert/"
echo "?? ˽Կ: domain.key"
echo "?? ֤��: domain.crt"
# 多阶段构建减少镜像体积
FROM debian:12-slim as builder

# 构建阶段：安装编译工具和依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 下载各个服务的二进制文件
RUN mkdir -p /build/bin
WORKDIR /build

# 下载 Xray
RUN wget -O xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip xray.zip && mv xray bin/ && rm xray.zip

# 下载 frp
RUN wget -O frp.tar.gz https://github.com/fatedier/frp/releases/latest/download/frp_0.52.3_linux_amd64.tar.gz && \
    tar -xzf frp.tar.gz && mv frp_0.52.3_linux_amd64/frps bin/ && rm -rf frp_0.52.3_linux_amd64 frp.tar.gz

# 下载 RustDesk Server
RUN wget -O rustdesk-server https://github.com/rustdesk/rustdesk-server/releases/latest/download/rustdesk-server-linux-amd64 && \
    chmod +x rustdesk-server && mv rustdesk-server bin/

FROM debian:12-slim

# 元数据
LABEL name="omnigate"
LABEL version="1.0.0"
LABEL description="Omnipotent Network Gateway - All-in-One Network Services Container"
LABEL maintainer="your-email@example.com"

# 安装运行时依赖
RUN apt-get update && apt-get install -y \
    supervisor \
    nginx \
    python3 \
    python3-pip \
    curl \
    wget \
    openssl \
    openvpn \
    wireguard-tools \
    iptables \
    iproute2 \
    net-tools \
    jq \
    && rm -rf /var/lib/apt/lists/*

# 创建目录结构
RUN mkdir -p \
    /config/cert \
    /config/xray \
    /config/wireguard \
    /config/openvpn \
    /config/frp \
    /config/rustdesk \
    /config/logs \
    /scripts \
    /webui

# 从构建阶段复制二进制文件
COPY --from=builder /build/bin/ /usr/local/bin/

# 复制脚本和配置文件
COPY scripts/ /scripts/
COPY webui/ /webui/
COPY supervisord.conf /etc/supervisor/supervisord.conf

# 安装 Python 依赖
RUN pip3 install -r /webui/requirements.txt

# 设置权限
RUN chmod +x /scripts/*.sh

# 环境变量默认值
ENV DOMAIN=rustdesk.i-erp.net.cn
ENV LOG_LEVEL=info
ENV ENABLE_XRAY=true
ENV ENABLE_WIREGUARD=true
ENV ENABLE_OPENVPN=true
ENV ENABLE_FRP=true
ENV ENABLE_RUSTDESK=true
ENV ENABLE_WEBUI=true
ENV XRAY_REALITY_PORT=1121
ENV XHTTP_REALITY_PORT=1220
ENV WIREGUARD_PORT=11210
ENV WIREGUARD_ADMIN_PORT=11211
ENV WIREGUARD_ADMIN_PASSWORD=liyongjie
ENV WIREGUARD_SUBNET=10.254.100.0/24
ENV OPENVPN_PORT=12200
ENV OPENVPN_USERNAME=liyongjie
ENV OPENVPN_PASSWORD=liyongjie
ENV OPENVPN_SUBNET=10.250.254.0/24
ENV FRP_SERVER_PORT=7000
ENV FRP_ADMIN_PORT=7500
ENV FRP_ADMIN_PASSWORD=liyongjie
ENV RUSTDESK_KEY=liyongjie
ENV IPV6_SUPPORT=true

# 持久化卷
VOLUME ["/config"]

# 暴露端口
EXPOSE 1121 1220 11210/udp 11211 12200/udp 7000 7500 21115-21119 21116/udp 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5m --retries=3 \
    CMD /scripts/health-check.sh

# 启动入口
ENTRYPOINT ["/scripts/entrypoint.sh"]
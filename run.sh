# 启用 BBR（需要内核支持）
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf

# 启用 IP 转发
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf

# 应用配置
sysctl -p


# 创建项目根目录
mkdir docker-all-in-one
cd docker-all-in-one

# 创建所有必要的子目录
mkdir -p scripts webui/templates configs/{xray,wireguard,openvpn,frp,rustdesk} data
# 给所有脚本文件添加执行权限
chmod +x scripts/*.sh

# 给 Web 应用文件设置正确权限
chmod +x webui/app.py
cp .env.example .env
# 编辑 .env 文件，填入您的实际配置
nano .env
# 构建并启动所有服务
docker-compose up -d --build

# 查看构建日志
docker-compose logs -f

# 查看服务状态
docker-compose ps

# 如果需要支持多种架构
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t all-in-one:latest .
4.3.1 Web 管理界面
bash
# 访问 Web 管理界面
# 替换为您的实际域名或 IP
http://your-domain-or-ip:8080
# 在宿主机上检查端口监听情况
netstat -tlnp | grep -E '(1121|1220|11210|11211|12200|7000|7500|21115)'

# 或者在容器内检查
docker exec all-in-one netstat -tlnp
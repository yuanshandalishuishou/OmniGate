# 🌟 OmniGate - 全能网络网关

> **Omnipotent Network Gateway | 一站式网络服务解决方案**

[![Docker](https://img.shields.io/badge/Docker-Enabled-blue.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-orange.svg)](https://github.com/your-username/omnigate)

**OmniGate** 是一个功能强大的全能网络网关 Docker 镜像，集成了现代网络所需的多种核心服务。无论您是需要安全的代理连接、VPN 服务、内网穿透还是远程桌面，OmniGate 都能为您提供一站式的解决方案。

---

## 🚀 特性亮点

### 🌐 全能服务集成
- **🛡️ Xray Reality** - 高性能代理协议，极致安全与速度
- **🔐 WireGuard VPN** - 现代、快速的 VPN 解决方案
- **🔒 OpenVPN** - 成熟稳定的传统 VPN 服务
- **🌐 FRP 服务器** - 强大的内网穿透工具
- **🖥️ RustDesk 服务器** - 开源远程桌面控制
- **🎛️ Web 管理界面** - 直观的 Web 控制台

### ⚡ 技术优势
- **🐳 Docker 容器化** - 一键部署，环境隔离
- **🔧 模块化设计** - 按需启用服务，资源高效利用
- **📊 实时监控** - 完整的服务状态监控和日志系统
- **🔐 自动证书** - 支持 ZeroSSL 自动 SSL 证书申请
- **🌍 IPv6 支持** - 完整的双栈网络支持
- **💾 数据持久化** - 所有配置安全持久化存储

---

## 🎯 快速开始

### 系统要求
- Docker & Docker Compose
- 至少 1GB 可用内存
- 2GB 可用磁盘空间
- Linux 内核 ≥ 5.4（WireGuard 支持）

### 🐳 一键部署

```bash
# 克隆项目
git https://github.com/yuanshandalishuishou/OmniGate
cd omnigate

# 配置环境变量
cp .env.example .env
nano .env  # 编辑配置参数

# 启动服务
docker-compose up -d

# 查看服务状态
docker-compose logs -f
```

### ⚙️ 环境配置

编辑 `.env` 文件配置您的参数：

```bash
# 域名配置
DOMAIN=your-domain.com

# 证书服务 (使用 ZeroSSL + Cloudflare)
ZEROSSL_EAB_KID=your_zerossl_eab_kid
ZEROSSL_EAB_HMAC_KEY=your_zerossl_eab_hmac_key
CLOUDFLARE_TOKEN=your_cloudflare_token

# 服务密码 (请务必修改!)
WIREGUARD_ADMIN_PASSWORD=YourSecurePassword123!
FRP_ADMIN_PASSWORD=YourSecurePassword456!
RUSTDESK_KEY=YourSecureKey789!
OPENVPN_USERNAME=your_username
OPENVPN_PASSWORD=YourSecurePassword000!
```

---

## 🛠️ 服务详情

### 1. Xray Reality 代理
- **端口**: 1121 (Reality), 1220 (HTTP Reality)
- **特性**: 自动生成密钥、防探测、高性能
- **配置**: 自动生成 UUID 和 Reality 密钥对

### 2. WireGuard VPN
- **服务端口**: 11210/udp
- **管理界面**: http://your-domain:11211
- **特性**: 现代化加密、快速连接、低延迟

### 3. OpenVPN
- **服务端口**: 12200/udp
- **认证**: 用户名/密码认证
- **特性**: 成熟稳定、广泛兼容

### 4. FRP 内网穿透
- **服务端口**: 7000
- **管理界面**: http://your-domain:7500
- **特性**: 完整的 frps 服务器功能

### 5. RustDesk 远程桌面
- **端口范围**: 21115-21119/tcp, 21116/udp
- **特性**: 自建中继服务器、端到端加密

### 6. Web 管理界面
- **访问地址**: http://your-domain:8080
- **功能**: 服务状态监控、配置查看、日志管理

---

## 📊 管理使用

### Web 管理界面
访问 `http://your-domain:8080` 进入 OmniGate 管理控制台：

- 🔍 **实时监控** - 所有服务运行状态
- ⚡ **一键操作** - 服务重启和管理
- 📋 **配置查看** - 关键配置信息展示
- 📁 **文件下载** - 客户端配置文件下载
- 📊 **系统状态** - CPU、内存、磁盘使用情况

### 命令行管理

```bash
# 进入容器
docker exec -it omnigate bash

# 查看服务状态
supervisorctl status

# 查看服务日志
tail -f /config/logs/xray-access.log

# 健康检查
/scripts/health-check.sh
```

---

## 🔧 高级配置

### 服务选择性启用

通过环境变量控制服务启停：

```bash
# 在 .env 文件中配置
ENABLE_XRAY=true
ENABLE_WIREGUARD=true
ENABLE_OPENVPN=false  # 禁用 OpenVPN
ENABLE_FRP=true
ENABLE_RUSTDESK=true
ENABLE_WEBUI=true
```

### 网络配置

```bash
# 子网配置
WIREGUARD_SUBNET=10.254.100.0/24
OPENVPN_SUBNET=10.250.254.0/24

# IPv6 支持
IPV6_SUPPORT=true
```

### 自定义端口

```bash
# 修改服务端口
XRAY_REALITY_PORT=1121
XHTTP_REALITY_PORT=1220
WIREGUARD_PORT=11210
OPENVPN_PORT=12200
FRP_SERVER_PORT=7000
```

---

## 🛡️ 安全建议

### 1. 密码安全
- ✅ 首次启动后立即修改所有默认密码
- ✅ 使用强密码生成器创建复杂密码
- ✅ 定期轮换关键服务密码

### 2. 网络加固
```bash
# 防火墙配置示例 (UFW)
ufw allow 1121/tcp comment "OmniGate Xray"
ufw allow 11210/udp comment "OmniGate WireGuard"
ufw allow 12200/udp comment "OmniGate OpenVPN"
# ... 其他端口根据需求开放
```

### 3. 证书管理
- 🔐 使用 ZeroSSL 自动申请 SSL 证书
- 📅 证书自动续期，无需人工干预
- 🌐 支持通配符证书，覆盖所有子域名

---

## 🚨 故障排除

### 常见问题

**Q: 证书申请失败**
```bash
# 检查 DNS 解析
nslookup your-domain.com

# 验证 Cloudflare token 权限
# 检查 ZeroSSL 账户状态
```

**Q: 服务启动失败**
```bash
# 查看详细日志
docker-compose logs [service-name]

# 检查端口冲突
netstat -tlnp | grep :1121

# 验证防火墙设置
ufw status
```

**Q: 客户端连接问题**
```bash
# 检查服务状态
docker exec omnigate supervisorctl status

# 验证配置生成
ls -la /config/wireguard/client.conf
```

### 日志文件位置
```
/config/logs/
├── xray-access.log
├── xray-error.log
├── wireguard.log
├── openvpn.log
├── frp.log
├── rustdesk.log
└── supervisord.log
```

---

## 📈 性能优化

### 系统调优
```bash
# 启用 BBR 拥塞控制
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf

# 优化网络参数
echo "net.ipv4.tcp_keepalive_time=600" >> /etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_intvl=60" >> /etc/sysctl.conf

# 应用配置
sysctl -p
```

### 资源监控
```bash
# 查看容器资源使用
docker stats omnigate

# 监控服务状态
docker exec omnigate /scripts/health-check.sh
```

---

## 🤝 贡献指南

我们欢迎社区贡献！请参考以下流程：

1. **Fork 项目**
2. **创建功能分支** (`git checkout -b feature/AmazingFeature`)
3. **提交更改** (`git commit -m 'Add some AmazingFeature'`)
4. **推送到分支** (`git push origin feature/AmazingFeature`)
5. **开启 Pull Request**

### 开发环境搭建
```bash
# 克隆开发版本
git clone -b develop https://github.com/your-username/omnigate.git

# 构建测试镜像
docker build -t omnigate:dev .

# 运行测试
docker run --rm omnigate:dev /scripts/health-check.sh
```

---

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

## 🙏 致谢

OmniGate 集成了以下优秀开源项目：

- [Xray-core](https://github.com/XTLS/Xray-core) - 高性能代理平台
- [WireGuard](https://www.wireguard.com/) - 现代 VPN 协议
- [OpenVPN](https://openvpn.net/) - 开源 VPN 解决方案
- [FRP](https://github.com/fatedier/frp) - 快速反向代理
- [RustDesk](https://rustdesk.com/) - 开源远程桌面
- [acme.sh](https://github.com/acmesh-official/acme.sh) - ACME 客户端

---


## 🎊 特别鸣谢

感谢所有为这个项目做出贡献的开发者们！特别感谢：

- **您** - 选择使用 OmniGate
- **开源社区** - 提供了优秀的组件和工具
- **测试用户** - 帮助改进和完善功能


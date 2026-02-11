# 🎬 Bangmio - 番剧管理网站

![GitHub](https://img.shields.io/badge/Vue-3.4-green)
![GitHub](https://img.shields.io/badge/Element--Plus-2.4-blue)
![GitHub](https://img.shields.io/badge/Cloudflare-Workers-orange)
![GitHub](https://img.shields.io/badge/GitHub-Pages-lightgrey)

一个简洁美观的番剧管理网站，使用粉色主题和玻璃质感设计，集成 Bangumi API。

**在线体验**: [https://sparkmio.github.io/Bangmio/](https://sparkmio.github.io/Bangmio/)

## ✨ 功能特性

- 🔍 **番剧搜索** - 使用 Bangumi API 搜索番剧
- 🎨 **粉色主题** - 现代化玻璃质感设计
- 👤 **Bangumi 登录** - OAuth 2.0 认证集成
- ❤️ **本地收藏** - 收藏你喜欢的番剧
- 📱 **响应式设计** - 完美适配各种设备
- ⚡ **快速后端** - Cloudflare Workers 代理 API
- 🚀 **一键部署** - 自动部署到 GitHub Pages

## 📁 项目结构

```
bangumi-manager/
├── frontend/                 # Vue 3 前端应用
│   ├── src/                 # 源代码
│   │   ├── components/      # 组件 (DockBar等)
│   │   ├── views/          # 页面组件
│   │   └── utils/          # 工具函数
│   ├── public/             # 静态资源
│   ├── .env.*              # 环境配置
│   └── package.json        # 依赖配置
├── backend/                  # Cloudflare Workers 后端
│   ├── src/index.js        # 主API逻辑
│   ├── wrangler.toml       # Workers配置
│   └── package.json        # 依赖配置
├── deploy-all.sh           # 全自动部署脚本
├── deploy-to-gh-pages.sh   # GitHub Pages部署脚本
└── README.md               # 项目说明
```

## 🚀 快速部署

### 一键部署脚本

我们提供了完整的自动化部署脚本：

```bash
# 1. 运行全自动部署脚本
./deploy-all.sh

# 脚本将引导你完成:
# - Git配置检查
# - 代码提交到GitHub
# - 前端构建
# - 部署到GitHub Pages
```

### 手动部署步骤

#### 后端 (Cloudflare Workers)

1. 安装依赖:
   ```bash
   cd backend
   npm install
   ```

2. 配置 Cloudflare Workers:
   - 如果没有 Cloudflare 账户，请先注册
   - 安装 Wrangler CLI: `npm install -g wrangler`
   - 登录: `wrangler login`
   - 更新 `wrangler.toml` 中的配置

3. 部署后端:
   ```bash
   npm run deploy
   ```

#### 前端 (GitHub Pages)

1. 安装依赖:
   ```bash
   cd frontend
   npm install
   ```

2. 更新API地址:
   - 编辑 `.env.production` 文件:
     ```
     VITE_API_BASE=https://bangumi-manager-api.pzhhuhu.workers.dev/api
     ```
   - 如需使用自己的后端，请替换为你的 Cloudflare Workers URL

3. 构建:
   ```bash
   npm run build
   ```

4. 部署到 GitHub Pages:
   ```bash
   # 使用提供的脚本
   ./deploy-to-gh-pages.sh

   # 或手动部署:
   git checkout --orphan gh-pages
   git rm -rf .
   cp -r frontend/dist/* .
   git add .
   git commit -m "Deploy to GitHub Pages"
   git push -u origin gh-pages --force
   ```

5. 启用 GitHub Pages:
   - 访问仓库 Settings > Pages
   - Source 选择 `gh-pages` 分支
   - 保存后访问: `https://你的用户名.github.io/bangumi-manager/`

## 🛠️ 开发指南

### 本地开发环境

#### 后端开发 (Cloudflare Workers)

```bash
cd backend
npm install          # 安装依赖
npm run dev          # 启动开发服务器 (端口 8787)
```

开发服务器将在 `http://localhost:8787` 启动，提供以下API端点：
- `http://localhost:8787/api/health` - 健康检查
- `http://localhost:8787/api/search?q=关键词` - 搜索番剧
- `http://localhost:8787/api/anime/{id}` - 获取番剧详情

#### 前端开发 (Vue 3)

```bash
cd frontend
npm install          # 安装依赖
npm run dev          # 启动开发服务器 (端口 5173)
```

开发服务器将在 `http://localhost:5173` 启动，自动监听文件更改。

#### 完整开发流程

1. 启动后端:
   ```bash
   cd backend && npm run dev
   ```

2. 启动前端:
   ```bash
   cd frontend && npm run dev
   ```

3. 访问 `http://localhost:5173` 开始开发

4. 前端默认配置了开发环境API地址 (`http://localhost:8787/api`)
   - 如需修改，编辑 `frontend/.env.development`

### 生产环境构建

```bash
# 构建前端
cd frontend
npm run build        # 输出到 dist/ 目录

# 部署后端
cd backend
npm run deploy       # 部署到 Cloudflare Workers
```

## 🔌 API 接口

### 公共接口

- `GET /api/search?q={关键词}&type={类型}` - 搜索番剧
  - `type=2` (默认): 动画
  - 返回格式: `{ results: [], total: 0, page: 1 }`

- `GET /api/anime/{id}` - 获取番剧详情
  - 包含名称、描述、评分、集数等信息

- `GET /api/subject/{id}` - 获取原始 Bangumi 数据
  - 返回 Bangumi API 的原始响应

- `GET /api/health` - 健康检查
  - 返回: `{ status: "ok" }`

### 认证接口 (OAuth 2.0)

- `GET /api/auth/bangumi/authorize` - 获取 Bangumi OAuth 授权URL
  - 返回: `{ url: "https://bgm.tv/oauth/authorize?..." }`

- `POST /api/auth/bangumi/callback` - OAuth 回调处理
  - Body: `{ code: "授权码", state: "状态参数" }`
  - 返回: `{ token: "JWT令牌", user: {用户信息} }`

- `GET /api/auth/me` - 获取当前用户信息
  - Header: `Authorization: Bearer {token}`
  - 返回: `{ user: {用户信息} }`

- `POST /api/auth/logout` - 退出登录
  - Header: `Authorization: Bearer {token}`

## ⚙️ 环境变量配置

### 前端环境变量

- `VITE_API_BASE` - API 基础地址
  - 开发环境: `http://localhost:8787/api` (见 `.env.development`)
  - 生产环境: `https://bangumi-manager-api.pzhhuhu.workers.dev/api` (见 `.env.production`)

### 后端环境变量 (Cloudflare Workers)

在 `wrangler.toml` 中配置:

```toml
[vars]
BANGUMI_API_BASE = "https://api.bgm.tv"          # Bangumi API地址
BANGUMI_CLIENT_ID = "你的Bangumi应用ID"           # OAuth客户端ID
BANGUMI_CLIENT_SECRET = "你的Bangumi应用密钥"     # OAuth客户端密钥
JWT_SECRET = "你的JWT密钥"                       # JWT签名密钥
```

### 获取 Bangumi OAuth 凭证

1. 访问 [Bangumi 应用管理](https://bgm.tv/dev/app)
2. 创建新应用，获取 `Client ID` 和 `Client Secret`
3. 回调地址填写: `https://你的workers域名.workers.dev/api/auth/bangumi/callback`
4. 更新 `backend/wrangler.toml` 中的配置

## License

MIT
# Luxinia · Desktop Companion

鲁希尼亚桌面陪伴 —— 纯 HTML/CSS/JS，开箱即用 🎀✨

## 📁 项目结构

```
nana-desktop-companion/
├─ index.html              # 主页面（开发用，引用 assets/luxinia.png）
├─ assets/
│  ├─ luxinia.png          # 角色立绘（已抠透明，5.6MB）
│  ├─ luxinia_raw.png      # 原图备份（14MB，白底）
│  └─ README.md            # 素材说明
├─ tools/
│  ├─ remove_white_bg.py   # 白底立绘抠图脚本（Pillow）
│  └─ bundle.py            # 单文件打包脚本（HTML + Base64 图片）
└─ dist/
   └─ luxinia.html         # 打包产物（单文件，自包含，可分享）
```

## 🚀 快速开始

### macOS

```bash
# 方式 1：直接打开单文件版（推荐，最省事）
open dist/luxinia.html

# 方式 2：起本地服务（便于调试）
cd nana-desktop-companion
python3 -m http.server 8765
# 浏览器打开 http://localhost:8765
```

### 修改后重新打包

```bash
python3 tools/bundle.py
# 会生成新的 dist/luxinia.html
```

### 替换立绘

把新的白底立绘命名为 `luxinia_raw.png` 放到 `assets/`，然后：

```bash
python3 tools/remove_white_bg.py   # 自动生成透明版 luxinia.png
python3 tools/bundle.py            # 重新打包
```

## 🎨 已实现功能

- **鲁希尼亚角色层**：ARIA 风纯 CSS 渐变背景 + 抠透明立绘 + 4.2s 呼吸 + 鼠标视差 + 脚下投影
- **7 个可拖动组件**：HUD / 对话气泡 / 时钟 / 音乐播放 / 日程（可编辑） / 天气 / 快捷启动
- **右键菜单**：每个组件可重置位置 / 移除；时钟/天气/气泡还能切换样式
- **多款式系统**：气泡 × 10 / 时钟 × 5 / 天气 × 5 / 背景配色 × 4
- **iOS 26 Liquid Glass 视觉**：毛玻璃 + 高光反射 + 柔和阴影
- **macOS 程序坞**：15 个 SVG 手绘图标 + 静态设计 + 点击弹跳 + 右键移除
- **抽屉式工具栏**：右下角 ＋ 按钮展开（换句话/切背景/粒子/恢复组件）
- **完全自适应**：vmin + clamp + aspect-ratio 三件套，任意窗口大小都不会溢出
- **持久化**：localStorage 存储位置/可见性/样式/日程数据，刷新不丢

## 🧠 技术要点

- **白底立绘抠图**：Pillow 亮度 + 色度双阈值判定（亮度 >240 且色度 <12 判硬透明，215-240 软过渡）
- **拖动系统**：mousedown 延迟 4px 阈值启动，clamp 边界保留 40px 可见
- **中心对齐切换**：`keepCenter()` 函数确保样式切换时视觉中心不偏移
- **Windows Python 坑**：控制台输出用纯 ASCII 避免 GBK 编码报错（用 `[OK]` 替代 `✓`）

## 📦 分享方式

- **单文件**：把 `dist/luxinia.html` 发给朋友，任何浏览器双击打开即可
- **整项目**：把整个文件夹拷走，在 Mac 上继续开发

---

💙 powered by 小樱酱 & 鲁希尼亚

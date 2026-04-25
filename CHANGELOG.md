# Nana Desktop Companion - 开发日志

> 每个版本对应一个 git tag，可通过 `git checkout <tag>` 回退到任意版本。

---

## v1.3 (2026-04-24) — 虚拟滚动 + 语音打断

**Tag:** `v1.3`
**Commit:** `2384def`

### 新增 / 修复

- **角色菜单虚拟滚动**：char-flyout 从原生 CSS overflow-x 改为 JS 虚拟滚动（transform: translateX），彻底解决 position:absolute+flex 容器滚动失效问题
- **切角色打断语音**：切换角色时先调用 stopAudio() 打掉未播完的语音再播放新角色的自我介绍
- **交互优化**：5px 阈值区分「点击角色」与「拖拽滚动」，支持鼠标拖拽/触控板/触摸屏三种操作方式

### 技术细节

- 新增 `.char-flyout-inner` 内部滑轨包装层
- CharRail 模块重写：`_offset` 变量 + `_applyOffset()` 替代 scrollLeft
- 拖拽中 render() 自动跳过重绘避免弹回

---

## v1.2 (2026-04-24) — 角色视频菜单横向滑动 + GitHub Pages 部署

**Tag:** `v1.2`
**Commit:** `b10d46c`

### 新增 / 修复

- **角色选择菜单（dock 👤）改为横向滑动**：显示 4~5 个角色头像，支持鼠标拖拽和触控板滚动
- **视频选择面板改为横向滚动**：14 个视频全部可浏览，从 grid 2列改为 flex 横向滚动
- **角色选择面板（cp-grid）横向滚动**：统一三个菜单的交互模式
- **GitHub Pages 永久部署**：通过 Actions workflow 自动部署，链接永久有效无需本地开机

---

## v1.1 (2026-04-24) — 角色菜单宽度约束 + 滑动基础

**Tag:** `v1.1`
**Commit:** `811db29`

### 新增 / 修复

- **char-flyout 宽度限制为 280px**：强制只显示 4~5 个角色，溢出部分可滚动
- **添加 scroll-snap-type: x mandatory**：吸附对齐效果
- **添加 mask-image 渐隐遮罩**：左右边缘渐隐提示内容可滑动
- **隐藏滚动条**：scrollbar-width: none + ::-webkit-scrollbar display:none

---

## v1.0 (2026-04-24) — 基础功能完善

**Tag:** `v1.0`
**Commit:** `aef06e4`

### 功能

- GitHub Pages Actions workflow 配置完成
- cloudflared 隧道连通性修复（http2 协议）
- 项目基础功能完整可用

---

## 初始版本 (2026-04-23)

**Tag:** `v0.1`
**Commit:** `b5ed4d0`

### 功能

- Nana Desktop Companion 初始提交
- 桌面陪伴系统基础框架
- 角色/立绘/视频/AI 对话/TTS 语音等核心模块

---

## 版本管理命令速查

```bash
# 查看所有版本
git tag -l -n99

# 回退到指定版本（例如 v1.3）
git checkout v1.3

# 回到最新版本
git checkout main

# 查看两个版本之间的差异
git log v1.2..v1.3 --oneline

# 创建新版本存档
# （使用 snapshot.sh 脚本或让 AI 助手自动处理）
```

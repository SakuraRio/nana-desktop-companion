# 素材放置说明

## 立绘接入

把鲁希尼亚的**透明背景 PNG 立绘**命名为 `luxinia.png` 放到本目录即可：

```
assets/
  ├─ luxinia.png    ← 鲁希尼亚立绘（建议 1080x1600 左右，透明底）
  └─ README.md
```

## 切换到真实立绘

打开 `index.html`，找到这一行：

```html
<div class="character placeholder" id="char"></div>
```

去掉 `placeholder` 类：

```html
<div class="character" id="char"></div>
```

保存后刷新浏览器，立绘就会出现在中央，并带呼吸 + 鼠标视差效果。

## 推荐立绘规格

| 项目 | 推荐值 |
| --- | --- |
| 格式 | PNG（带 Alpha 透明通道） |
| 分辨率 | 1080 × 1600 或更高 |
| 构图 | 角色居中，底部贴近画面底（便于投影对齐） |
| 留白 | 头顶留 10% 左右空白，避免被气泡遮挡 |
| 背景 | 必须透明，否则会和渐变背景冲突 |

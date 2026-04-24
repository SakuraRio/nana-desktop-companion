"""
抠除白底立绘 → 透明 PNG
策略：
1. 转 RGBA
2. 对每个像素，根据它与纯白的"接近度"计算 alpha：
   - 完全白 → alpha = 0（透明）
   - 非常接近白（如浅灰/浅蓝灰背景）→ alpha 线性衰减
   - 明显有色彩 → alpha = 255（保留）
3. 为了保护角色边缘的抗锯齿像素，用"色度 + 亮度"双判据
"""
from PIL import Image
import numpy as np
import sys
from pathlib import Path

SRC = Path(r"c:/Users/rokizhang/WorkBuddy/20260421102610/nana-desktop-companion/assets/luxinia_raw.png")
DST = Path(r"c:/Users/rokizhang/WorkBuddy/20260421102610/nana-desktop-companion/assets/luxinia.png")

def remove_white_bg(src: Path, dst: Path):
    img = Image.open(src).convert("RGBA")
    arr = np.array(img, dtype=np.int16)
    r, g, b, a = arr[..., 0], arr[..., 1], arr[..., 2], arr[..., 3]

    # 亮度：越接近 255 越可能是背景
    lum = (r * 0.299 + g * 0.587 + b * 0.114)
    # 色度：max-min，越小越接近灰/白
    mx = np.maximum(np.maximum(r, g), b)
    mn = np.minimum(np.minimum(r, g), b)
    chroma = mx - mn

    # 阈值策略：
    # 亮度 > 240 且 色度 < 12  → 认为是背景白/浅灰，alpha = 0
    # 亮度 > 220 且 色度 < 8   → 边缘半透明过渡
    alpha = np.full_like(a, 255)

    # 硬背景：完全透明
    hard_bg = (lum > 240) & (chroma < 12)
    alpha[hard_bg] = 0

    # 软过渡：线性衰减
    soft_bg = (~hard_bg) & (lum > 215) & (chroma < 10)
    # 从 215 → 240 映射到 255 → 0
    soft_alpha = np.clip(255 - ((lum - 215) / 25.0) * 255, 0, 255)
    alpha[soft_bg] = soft_alpha[soft_bg].astype(np.int16)

    # 写回
    arr[..., 3] = alpha
    # 把完全透明的像素 RGB 置 0，避免边缘出现白色光晕
    arr[alpha == 0, 0:3] = 0

    out = Image.fromarray(arr.astype(np.uint8), "RGBA")
    out.save(dst, optimize=True)
    print(f"[OK] {src.name} ({src.stat().st_size/1024/1024:.1f}MB) -> {dst.name} ({dst.stat().st_size/1024/1024:.1f}MB)")

if __name__ == "__main__":
    # 如果 raw 不存在，先把当前 luxinia.png 备份为 raw
    if not SRC.exists() and DST.exists():
        import shutil
        shutil.copy(DST, SRC)
        print(f"[OK] backup raw -> {SRC.name}")
    remove_white_bg(SRC, DST)

"""
将 index.html 和 assets/ 下引用的图片打包成单个自包含 HTML 文件。
策略：把 url("./assets/xxx.png") 替换成 data:image/png;base64,...
"""
import base64
import re
from pathlib import Path

ROOT = Path(r"c:/Users/rokizhang/WorkBuddy/20260421102610/nana-desktop-companion")
SRC = ROOT / "index.html"
DST = ROOT / "dist" / "luxinia.html"

def to_data_uri(path: Path) -> str:
    mime = "image/png" if path.suffix.lower() == ".png" else "image/jpeg"
    b64 = base64.b64encode(path.read_bytes()).decode("ascii")
    return f"data:{mime};base64,{b64}"

def bundle():
    DST.parent.mkdir(parents=True, exist_ok=True)
    html = SRC.read_text(encoding="utf-8")

    # 匹配 url("./assets/xxx.png") 或 url('./assets/xxx.png') 或 url(./assets/xxx.png)
    pattern = re.compile(r'url\(\s*["\']?(\.?/?assets/[^"\')\s]+)["\']?\s*\)')
    def repl(m):
        rel = m.group(1)
        img_path = (ROOT / rel.lstrip("./")).resolve()
        if not img_path.exists():
            print(f"[WARN] not found: {rel}")
            return m.group(0)
        uri = to_data_uri(img_path)
        kb = len(uri) / 1024
        print(f"[OK] inline {rel} -> {kb:.1f}KB base64")
        return f'url("{uri}")'

    bundled = pattern.sub(repl, html)

    # 额外处理 background-image: url(...) 以外的 <img src="assets/...">（如果有）
    img_pattern = re.compile(r'<img\s+([^>]*?)src\s*=\s*["\'](\.?/?assets/[^"\']+)["\']', re.IGNORECASE)
    def img_repl(m):
        pre, rel = m.group(1), m.group(2)
        img_path = (ROOT / rel.lstrip("./")).resolve()
        if not img_path.exists():
            return m.group(0)
        return f'<img {pre}src="{to_data_uri(img_path)}"'
    bundled = img_pattern.sub(img_repl, bundled)

    DST.write_text(bundled, encoding="utf-8")
    size_mb = DST.stat().st_size / 1024 / 1024
    print(f"\n[DONE] {DST} ({size_mb:.2f}MB)")
    print(f"Share this single file and recipients can double-click to open!")

if __name__ == "__main__":
    bundle()

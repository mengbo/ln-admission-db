#!/usr/bin/env python3
"""MD → HTML 转换脚本（Markdown → 带样式的 HTML）。

用法：
    .venv/bin/python scripts/md2html.py input.md output.html
"""

import sys

import markdown


HTML_TEMPLATE = """\
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<style>
  body {{
    font-family: "PingFang SC", "Microsoft YaHei", "Helvetica Neue", Arial, sans-serif;
    max-width: 960px;
    margin: 0 auto;
    padding: 40px 30px;
    color: #333;
    line-height: 1.7;
  }}
  h1 {{ font-size: 1.6em; border-bottom: 2px solid #4472C4; padding-bottom: 8px; }}
  h2 {{ font-size: 1.3em; margin-top: 1.8em; border-bottom: 1px solid #ccc; padding-bottom: 5px; }}
  h3 {{ font-size: 1.1em; margin-top: 1.5em; }}
  table {{ border-collapse: collapse; width: 100%; margin: 12px 0; font-size: 0.9em; }}
  th, td {{ border: 1px solid #ddd; padding: 6px 10px; text-align: left; }}
  th {{ background-color: #4472C4; color: white; }}
  tr:nth-child(even) {{ background-color: #f9f9f9; }}
  blockquote {{ border-left: 4px solid #4472C4; margin: 12px 0; padding: 8px 16px; background: #f0f4ff; }}
  code {{ background: #f4f4f4; padding: 2px 5px; border-radius: 3px; font-size: 0.9em; }}
  strong {{ color: #c0392b; }}
</style>
</head>
<body>
{body}
</body>
</html>
"""


def convert(md_path: str, html_path: str) -> None:
    with open(md_path, encoding="utf-8") as f:
        md_text = f.read()

    body = markdown.markdown(
        md_text,
        extensions=["tables", "fenced_code", "toc", "sane_lists"],
    )

    html = HTML_TEMPLATE.format(body=body)

    with open(html_path, "w", encoding="utf-8") as f:
        f.write(html)

    print(f"✅ {md_path} → {html_path}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"用法: {sys.argv[0]} input.md output.html", file=sys.stderr)
        sys.exit(1)
    convert(sys.argv[1], sys.argv[2])

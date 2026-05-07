#!/usr/bin/env python3
"""
验证码 OCR 识别脚本（基于 ddddocr）

用法: python3 ocr_captcha.py <image_path>
输出: 识别出的验证码文本（stdout），失败时输出到 stderr 并退出码 1
"""

import sys
import ddddocr


def main():
    if len(sys.argv) < 2:
        print("Usage: ocr_captcha.py <image_path>", file=sys.stderr)
        sys.exit(1)

    image_path = sys.argv[1]
    try:
        ocr = ddddocr.DdddOcr(show_ad=False)
        with open(image_path, "rb") as f:
            img = f.read()
        result = ocr.classification(img)
        if result:
            print(result)
        else:
            sys.exit(1)
    except Exception as e:
        print(f"OCR failed: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

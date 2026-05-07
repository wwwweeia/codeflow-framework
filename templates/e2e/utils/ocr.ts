import { execSync } from 'child_process'
import fs from 'fs'
import path from 'path'

const AUTH_DIR = path.join(__dirname, '..', '.auth')
const OCR_SCRIPT = path.join(__dirname, '..', 'scripts', 'ocr_captcha.py')

/**
 * 验证码 OCR 模块
 *
 * 调用 ddddocr（Python）识别验证码。
 * ddddocr 是专门针对验证码训练的 OCR 引擎，
 * 对干扰线、字符扭曲、背景噪点有很强的鲁棒性。
 */

/** OCR 识别验证码，返回 4 位大写字母数字或 null */
export async function recognizeCaptcha(buffer: Buffer): Promise<string | null> {
  // 写入临时文件供 Python 脚本读取
  const tmpPath = path.join(AUTH_DIR, 'captcha.png')
  fs.writeFileSync(tmpPath, buffer)

  try {
    const result = execSync(`python3 "${OCR_SCRIPT}" "${tmpPath}"`, {
      timeout: 15_000,
      encoding: 'utf-8',
    }).trim()

    const cleaned = result.replace(/[^A-Za-z0-9]/g, '').toUpperCase()
    if (cleaned.length === 4) {
      return cleaned
    }
    console.log(`[OCR] ddddocr raw="${result}" cleaned="${cleaned}" (len=${cleaned.length}, not 4)`)
    return null
  } catch (e) {
    return null
  }
}

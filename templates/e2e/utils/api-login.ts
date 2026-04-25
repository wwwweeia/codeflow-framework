import https from 'https'
import crypto from 'crypto'
import fs from 'fs'
import path from 'path'
import { execSync } from 'child_process'
import md5 from 'md5'
import { encrypt } from './encryption'

/**
 * API 直接登录模块
 *
 * 不通过浏览器，直接用 HTTP API 完成登录流程：
 * 1. 获取验证码图片
 * 2. OCR 识别
 * 3. 提交登录
 * 4. 加密认证数据写入 sessionStorage 文件
 */

const AUTH_DIR = path.join(__dirname, '..', '.auth')
const SESSION_FILE = path.join(AUTH_DIR, 'session-storage.json')
const CAPTCHA_IMAGE = path.join(AUTH_DIR, 'captcha.png')
const OCR_SCRIPT = path.join(__dirname, '..', 'scripts', 'read_captcha.swift')

interface LoginResponse {
  code: number
  data: {
    token: { token: string; tokenType?: string; [key: string]: unknown }
    userInfo: Record<string, unknown>
    resourceTree: Record<string, unknown>
    orgTree: unknown[]
    agentInfo?: unknown[]
    agentFunctionEnable?: boolean
    [key: string]: unknown
  }
  message?: string
}

/** 发起 HTTPS 请求（忽略证书错误） */
function request(options: https.RequestOptions, body?: Buffer): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const req = https.request(
      { ...options, rejectUnauthorized: false },
      (res) => {
        const chunks: Buffer[] = []
        res.on('data', (chunk) => chunks.push(chunk))
        res.on('end', () => resolve(Buffer.concat(chunks)))
        res.on('error', reject)
      },
    )
    req.on('error', reject)
    if (body) req.write(body)
    req.end()
  })
}

/** GET 请求 */
async function get(baseUrl: string, apiPath: string): Promise<Buffer> {
  const url = new URL(apiPath, baseUrl)
  return request({
    hostname: url.hostname,
    port: url.port || 443,
    path: url.pathname + url.search,
    method: 'GET',
    headers: { 'Accept': '*/*' },
  })
}

/** POST multipart/form-data */
async function postMultipart(
  baseUrl: string,
  apiPath: string,
  fields: Record<string, string>,
): Promise<Buffer> {
  const boundary = '----E2EFormBoundary' + crypto.randomBytes(8).toString('hex')
  const parts: Buffer[] = []

  for (const [name, value] of Object.entries(fields)) {
    parts.push(
      Buffer.from(
        `--${boundary}\r\nContent-Disposition: form-data; name="${name}"\r\n\r\n${value}\r\n`,
      ),
    )
  }
  parts.push(Buffer.from(`--${boundary}--\r\n`))
  const body = Buffer.concat(parts)

  const url = new URL(apiPath, baseUrl)
  return request(
    {
      hostname: url.hostname,
      port: url.port || 443,
      path: url.pathname + url.search,
      method: 'POST',
      headers: {
        'Content-Type': `multipart/form-data; boundary=${boundary}`,
        'Content-Length': body.length,
      },
    },
    body,
  )
}

/** OCR 验证码 */
function ocrCaptcha(imagePath: string): string | null {
  try {
    const result = execSync(`swift "${OCR_SCRIPT}" "${imagePath}"`, {
      timeout: 10_000,
      encoding: 'utf-8',
    }).trim()
    if (result && /^[A-Z0-9]{4}$/.test(result)) {
      return result
    }
    return null
  } catch {
    return null
  }
}

export interface ApiLoginResult {
  sessionStorageData: Record<string, string>
  token: string
}

/**
 * API 直接登录
 *
 * @returns 加密后的 sessionStorage 数据和原始 token
 */
export async function apiLogin(
  baseUrl: string,
  username: string,
  password: string,
  maxOcrAttempts = 10,
): Promise<ApiLoginResult> {
  fs.mkdirSync(AUTH_DIR, { recursive: true })

  for (let attempt = 1; attempt <= maxOcrAttempts; attempt++) {
    const uuid = crypto.randomUUID()

    // 1. 获取验证码图片
    const captchaBuffer = await get(baseUrl, `/api/uias-service/oauth/captcha?uuid=${uuid}`)
    fs.writeFileSync(CAPTCHA_IMAGE, captchaBuffer)

    // 2. OCR 识别
    const captchaText = ocrCaptcha(CAPTCHA_IMAGE)
    if (!captchaText) {
      console.log(`[API-Login] OCR 失败 (attempt ${attempt}/${maxOcrAttempts})`)
      continue
    }
    console.log(`[API-Login] OCR 识别: ${captchaText} (attempt ${attempt})`)

    // 3. 提交登录
    const loginBody = await postMultipart(baseUrl, '/api/uias-service/oauth/token', {
      username,
      password: md5(password),
      captcha: captchaText,
      uuid,
      appCode: 'ai-kg',
      loginType: 'user',
      client_id: 'browser',
      client_secret: 'browser',
      tenantKey: '3a57a9ab730e40ae181533ebb703512c',
    })

    const loginResp: LoginResponse = JSON.parse(loginBody.toString('utf-8'))
    if (loginResp.code !== 0) {
      console.log(
        `[API-Login] 登录失败: ${loginResp.message || 'unknown'} (attempt ${attempt})`,
      )
      continue
    }

    // 4. 加密认证数据
    const { token, userInfo, resourceTree, orgTree, agentInfo, agentFunctionEnable } =
      loginResp.data
    const sessionStorageData: Record<string, string> = {
      authUser: encrypt(JSON.stringify(token), 'authUser'),
      permission: encrypt(JSON.stringify(resourceTree), 'permission'),
      info: encrypt(JSON.stringify(userInfo), 'info'),
      org: encrypt(JSON.stringify(orgTree), 'org'),
      agentInfo: encrypt(JSON.stringify(agentInfo || []), 'agentInfo'),
      agentFunctionEnable: String(agentFunctionEnable ?? false),
    }

    // 5. 写入文件
    fs.writeFileSync(SESSION_FILE, JSON.stringify(sessionStorageData, null, 2))
    console.log(`[API-Login] 登录成功! token: ${String(token).substring(0, 20)}...`)

    return {
      sessionStorageData,
      token: typeof token === 'string' ? token : (token.token as string),
    }
  }

  throw new Error(`API 登录失败: ${maxOcrAttempts} 次 OCR 尝试后仍未成功`)
}

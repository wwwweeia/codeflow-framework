import crypto from 'crypto'

/**
 * AES-128-CBC 加密工具
 *
 * Key: (storageKey + "9vApxLk5G3PAsJrM").slice(0, 16)
 * IV:  "FnJL7EDzjqWjcaY9"
 */
const SALT = '9vApxLk5G3PAsJrM'
const IV = 'FnJL7EDzjqWjcaY9'

export function encrypt(data: string, key: string): string {
  const k = key + SALT
  const aesKey = Buffer.from(k.slice(0, 16), 'utf8')
  const iv = Buffer.from(IV, 'utf8')
  const cipher = crypto.createCipheriv('aes-128-cbc', aesKey, iv)
  let crypted = cipher.update(data, 'utf8', 'hex')
  crypted += cipher.final('hex')
  return crypted
}

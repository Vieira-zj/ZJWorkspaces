import { Message } from 'element-ui'

export function isSuperUserCn (flag) {
  return flag === 'y' ? '是' : '否'
}

export function toUnicode (text) {
  return escape(text)
    .replace(/%/g, '\\')
    .toLowerCase()
}

export function showErrorMessage (msg) {
  Message({
    message: msg,
    type: 'error',
    duration: 5 * 1000
  })
}

export function respErrorHandler (err) {
  if (!Boolean(err)) {
    return
  }

  if (Boolean(err.response)) {
    console.error('status:', err.response.status)
    console.error('headers:', err.response.headers)
    console.error("body:", JSON.stringify(err.response.data))
    if (err.response.status === 403) {
      showErrorMessage('授权失败，用户名或密码不正确！')
    } else {
      showErrorMessage(`[Error]: code:${err.response.data.code} message:${err.response.data.msg}`)
    }
    return
  }

  console.error(err)
  showErrorMessage(err.message)
}

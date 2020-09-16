export function isSuperUserCn (flag) {
  return flag === "y" ? "是" : "否"
};

export function errorHandler (vm, err) {
  if (err.response) {
    console.error("status:", err.response.status)
    console.error("headers:", err.response.headers)
    console.error("data:", err.response.data)
    if (err.response.status === 403) {
      vm.$message.error("授权失败，用户名或密码不正确！")
    } else {
      vm.$message.error(
        `[Error]: code:${err.response.data.code} message:${err.response.data.msg}`
      )
    }
    return
  }
  if (err) {
    console.error(err)
  }
};

export function toUnicode (text) {
  return escape(text)
    .replace(/%/g, "\\")
    .toLowerCase()
}

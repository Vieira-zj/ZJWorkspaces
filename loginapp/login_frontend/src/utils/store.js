// use vuex instead of sessionStorage

export function setIsSuperUser (flag) {
  sessionStorage.setItem("IsSuperUser", flag)
}

export function getIsSuperUser () {
  return sessionStorage.getItem("IsSuperUser") === "true" ? true : false
}

export function setLogonUserName (name) {
  sessionStorage.setItem("LogonUserName", name)
}

export function getLogonUserName () {
  return sessionStorage.getItem("LogonUserName")
}

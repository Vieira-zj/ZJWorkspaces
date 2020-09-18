// sessionStorage

export function setIsSuperUser (flag) {
  let save = flag ? 'y' : 'n'
  sessionStorage.setItem('IsSuperUser', save)
}

export function getIsSuperUser () {
  return sessionStorage.getItem('IsSuperUser') === 'y' ? true : false
}

export function setLogonUserName (name) {
  sessionStorage.setItem('LogonUserName', name)
}

export function getLogonUserName () {
  return sessionStorage.getItem('LogonUserName')
}

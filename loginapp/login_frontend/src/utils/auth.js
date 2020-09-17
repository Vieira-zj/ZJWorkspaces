import Cookie from 'js-cookie'
import { showErrorMessage } from './global'

// validate

export function validateName (str) {
  let name = str || ''
  if (name.length < 4) {
    showErrorMessage('输入用户名长度不能小于4！')
    return false
  }
  return true
}

export function validatePassword (str) {
  let password = str || ''
  if (password.length < 6) {
    showErrorMessage('输入密码长度不能小于6！')
    return false
  }
  return true
}

// use js-cookie instead of document.cookie

const authKey = 'User-Token'

export function getUserToken () {
  return Cookie.get(authKey)
}

export function setUserToken (token) {
  return Cookie.set(authKey, token)
}

export function removeUserToken () {
  return Cookie.remove(authKey)
}

// document.cookie

export function setCookie (cname, cvalue, exdays) {
  let d = new Date()
  d.setTime(d.getTime() + exdays * 24 * 60 * 60 * 1000)
  let expires = 'expires=' + d.toUTCString()
  document.cookie = `${cname}=${cvalue};${expires}`
}

export function getCookie (name) {
  let cookies = document.cookie.split(';')
  for (let i = 0; i < cookies.length; i++) {
    let c = cookies[i]
    while (c.charAt(0) === ' ') c = c.substring(1)
    if (c.indexOf(name) != -1) {
      return c.substring(name.length + 1, c.length)
    }
  }
  return ''
}

export function removeCookie (cname) {
  let cvalue = getCookie(cname)
  if (Boolean(cvalue)) {
    let d = new Date()
    d.setTime(d.getTime() - 1)
    let expires = 'expires=' + d.toUTCString()
    document.cookie = `${cname}=${cvalue};${expires}`
  }
}

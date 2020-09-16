import Cookie from 'js-cookie'

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

// user document.cookie

export function setCookie (cname, cvalue, exdays) {
  if (exdays > 0) {
    let d = new Date()
    d.setTime(d.getTime() + exdays * 24 * 60 * 60 * 1000)
    let expires = "expires=" + d.toUTCString()
    document.cookie = `${cname}=${cvalue};${expires}`
  } else {
    document.cookie = `${cname}=${cvalue};${exdays}`
  }
}

export function getCookie (name) {
  let cookies = document.cookie.split(";")
  for (let i = 0; i < cookies.length; i++) {
    let c = cookies[i]
    while (c.charAt(0) === " ") c = c.substring(1)
    if (c.indexOf(name) != -1) {
      return c.substring(name.length + 1, c.length)
    }
  }
  return ""
}

export function removeCookie (name) {
  setCookie(name, "", -1)
}

import request from '@/utils/request'

export function apiLogin (data) {
  return request({
    url: process.env.VUE_APP_BASE_API + '/login',
    method: 'post',
    data
  })
}

export function apiGetUser (name) {
  return request({
    url: process.env.VUE_APP_BASE_API + "/getuser",
    method: "get",
    params: { name }

  })
}

export function apiGetUsers (data) {
  return request({
    url: process.env.VUE_APP_BASE_API + "/getusers",
    method: "post",
    data
  })
}

export function apiNewUser (data) {
  return request({
    url: process.env.VUE_APP_BASE_API + '/newuser',
    method: 'post',
    data
  })
}

export function apiEditUser (data) {
  return request({
    url: process.env.VUE_APP_BASE_API + "/edituser",
    method: "post",
    data
  })
}

export function apiIsSuperUser () {
  return request({
    url: process.env.VUE_APP_BASE_API + "/issuperuser",
    method: "get"
  })
}

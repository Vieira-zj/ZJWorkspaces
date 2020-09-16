import request from '@/utils/request'

export function apiLogin (data) {
  return request({
    url: process.env.VUE_APP_BASE_API + '/login',
    method: 'post',
    data: data
  })
}

export function apiNewUser (data) {
  return request({
    url: process.env.VUE_APP_BASE_API + '/newuser',
    method: 'post',
    data: data
  })
}

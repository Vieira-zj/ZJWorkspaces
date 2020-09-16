import request from '@/utils/request'

export function loginRequest (data) {
  return request({
    url: process.env.VUE_APP_BASE_API + '/login',
    method: 'post',
    headers: { 'Content-Type': 'application/json' },
    data: data
  })
}
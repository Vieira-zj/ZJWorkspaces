import request from '@/utils/request'

export function apiLogin (data) {
  return request({
    url: '/login',
    method: 'post',
    data
  })
}

export function apiGetUser (name) {
  return request({
    url: '/getuser',
    method: 'get',
    params: { name }
  })
}

export function apiGetUsers (data) {
  return request({
    url: '/getusers',
    method: 'post',
    data
  })
}

export function apiNewUser (data) {
  return request({
    url: '/newuser',
    method: 'post',
    data
  })
}

export function apiEditUser (data) {
  return request({
    url: '/edituser',
    method: 'post',
    data
  })
}

export function apiIsSuperUser () {
  return request({
    url: '/issuperuser',
    method: 'get'
  })
}

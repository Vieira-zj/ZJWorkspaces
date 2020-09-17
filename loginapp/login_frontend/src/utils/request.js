// use request instead of axios

import axios from 'axios'
import { respErrorHandler } from './global'
import { getUserToken } from './auth'

const service = axios.create({
  baseURL: process.env.VUE_APP_BASE_API,
  timeout: 5000,
  // 允许携带cookie, 解决跨域cookie丢失问题
  withCredentials: true,
})

// request interceptor
service.interceptors.request.use(
  config => {
    let token = getUserToken()
    if (token) {
      config.headers['Authorization'] = token
      config.headers['Content-Type'] = 'application/json'
    }
    return config
  },
  err => {
    respErrorHandler(err)
    return Promise.reject(err)
  }
)

// response interceptor
service.interceptors.response.use(
  response => {
    let { data } = response
    if (data.code !== '0') {
      respErrorHandler({ response })
      return Promise.reject(err)
    }
    return data
  },
  err => {
    respErrorHandler(err)
    return Promise.reject(err)
  }
)

export default service

import axios from 'axios'
import { respErrorHandler } from './global'
import { getUserToken } from './auth'

const request = axios.create({
  baseURL: process.env.VUE_APP_BASE_API,
  // 允许携带cookie, 解决跨域cookie丢失问题
  withCredentials: true,
  timeout: 5000,
})

// request interceptor
request.interceptors.request.use(
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
request.interceptors.response.use(
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

export default request

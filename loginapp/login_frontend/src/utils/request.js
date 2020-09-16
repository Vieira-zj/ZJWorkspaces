import axios from 'axios'
import store from '@/store'
import { errorHandler } from './global'

const service = axios.create({
  baseURL: process.env.VUE_APP_BASE_API,
  timeout: 5000,
  withCredentials: true, // cookie
})

// request interceptor
service.interceptors.request.use(
  config => {
    let token = store.state.users.userToken
    if (token) {
      config.headers['Authorization'] = token
      config.headers['Content-Type'] = 'application/json'
    }
    return config
  },
  err => {
    errorHandler(err)
    return Promise.reject(err)
  }
)

// response interceptor
service.interceptors.response.use(
  response => {
    let { data } = response
    let retCode = data.code
    if (retCode !== '0') {
      let err = new Error(`code=${retCode}, message=${data.message}`)
      errorHandler(err)
      return Promise.reject(err)
    }
    return data
  },
  err => {
    errorHandler(err)
    return Promise.reject(error)
  }
)

export default service

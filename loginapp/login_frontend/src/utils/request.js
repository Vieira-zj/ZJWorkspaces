import axios from 'axios'
import { MessageBox, Message } from 'element-ui'
import store from '@/store'

const service = axios.create({
  baseURL: process.env.VUE_APP_BASE_API,
  timeout: 5000,
  withCredentials: true,
})

// request interceptor
service.interceptors.request.use(
  config => {
    let token = store.state.users.userToken
    if (token) {
      config.headers['Authorization'] = token
    }
    return config
  },
  err => {
    console.error(err)
    return Promise.reject(err)
  }
)

// response interceptor
service.interceptors.response.use(
  response => {
    // TODO: handle non-200 return code
    return response
  },
  err => {
    console.error('error:', err)
    Message({
      message: err.message,
      type: 'error',
      duration: 5 * 1000
    })
    return Promise.reject(error)
  }
)

export default service

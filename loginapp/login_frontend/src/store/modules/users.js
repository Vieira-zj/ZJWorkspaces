import { apiLogin, apiNewUser } from '@/api/users'
import { getUserToken } from '@/utils/auth'

const state = {
  authToken: "",
  logonUserName: "",
  isSuperUser: false,
  registerName: "",
}

const getters = {}

const mutations = {
  setAuthToken (state) {
    state.authToken = getUserToken()
  },
  setLogonUserName (state, name) {
    state.logonUserName = name
  },
  setIsSuperUser (state, flag) {
    state.isSuperUser = flag
  },
  setRegisterName (state, name) {
    state.registerName = name
  }
}

const actions = {
  login ({ commit, state }, userInfo) {
    return new Promise((resolve, reject) => {
      apiLogin(userInfo)
        .then(respData => {
          console.log('login success')
          commit('setLogonUserName', respData.name)
          commit('setIsSuperUser', respData.issuperuser === 'y' ? true : false)
          commit('setAuthToken')
          console.log('token cookie:', state.authToken)
          resolve()
        }).catch(err => {
          reject(err)
        })
    })
  },

  register1 ({ commit }, registerData) {
    return new Promise((resolve, reject) => {
      apiNewUser(registerData)
        .then(() => {
          console.log('register step1 success')
          commit('setRegisterName', registerData.name)
          resolve()
        }).catch(err => {
          reject(err)
        })
    })
  }
}

export default {
  namespaced: true,
  state,
  getters,
  mutations,
  actions
}

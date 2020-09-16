import { apiLogin, apiNewUser, apiEditUser } from '@/api/users'
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
  login ({ commit, state }, userData) {
    return new Promise((resolve, reject) => {
      apiLogin(userData)
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

  register1 ({ commit }, userData) {
    return new Promise((resolve, reject) => {
      apiNewUser(userData)
        .then(() => {
          console.log('register step1 success')
          commit('setRegisterName', userData.name)
          resolve()
        }).catch(err => {
          reject(err)
        })
    })
  },

  editUser ({ commit }, userData) {
    return new Promise((resolve, reject) => {
      apiEditUser(userData).then(() => {

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

import { apiLogin, apiGetUser, apiNewUser, apiEditUser } from '@/api/users'
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
          console.log('login success:', respData.user)
          commit('setLogonUserName', respData.user.name)
          commit('setIsSuperUser', respData.user.issuperuser === 'y' ? true : false)
          commit('setAuthToken')
          console.log('token cookie:', state.authToken)
          resolve()
        }).catch(err => {
          reject(err)
        })
    })
  },

  register ({ commit }, userData) {
    return new Promise((resolve, reject) => {
      apiNewUser(userData)
        .then(respData => {
          console.log('user register success:', respData.user)
          commit('setRegisterName', respData.user.name)
          resolve()
        }).catch(err => {
          reject(err)
        })
    })
  },

  getUser ({ }, userData) {
    return new Promise((resolve, reject) => {
      apiGetUser(userData)
        .then(respData => {
          console.log("load user success:", respData.user)
          resolve(respData.user)
        }).catch(err => {
          reject(err)
        })
    })
  },

  editUser ({ }, userData) {
    return new Promise((resolve, reject) => {
      apiEditUser(userData)
        .then(respData => {
          console.log('edit user success:', respData.user)
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

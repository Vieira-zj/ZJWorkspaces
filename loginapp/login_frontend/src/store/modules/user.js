import { apiLogin, apiGetUser, apiGetUsers, apiNewUser, apiEditUser, apiIsSuperUser } from '@/api/user'
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
          console.log('login success:', JSON.stringify(respData.user))
          commit('setAuthToken')
          commit('setLogonUserName', respData.user.name)
          commit('setIsSuperUser', respData.user.issuperuser === 'y' ? true : false)
          console.log('token cookie:', state.authToken)
          resolve()
        }).catch(err => {
          reject(err)
        })
    })
  },

  registerUser ({ commit }, userData) {
    return new Promise((resolve, reject) => {
      apiNewUser(userData)
        .then(respData => {
          console.log('register user success:', JSON.stringify(respData.user))
          commit('setRegisterName', respData.user.name)
          resolve()
        }).catch(err => {
          reject(err)
        })
    })
  },

  editUser ({ }, userData) {
    return new Promise((resolve, reject) => {
      apiEditUser(userData)
        .then(respData => {
          console.log('edit user success:', JSON.stringify(respData.user))
          resolve()
        }).catch(err => {
          reject(err)
        })
    })
  },

  getUser ({ }, username) {
    return new Promise((resolve, reject) => {
      apiGetUser(username)
        .then(respData => {
          console.log("load user success:", JSON.stringify(respData.user))
          resolve(respData.user)
        }).catch(err => {
          reject(err)
        })
    })
  },

  getUsers ({ }, data) {
    return new Promise((resolve, reject) => {
      apiGetUsers(data)
        .then(respData => {
          console.log("load users success, count:", respData.users.length)
          resolve(respData)
        }).catch(err => {
          reject(err)
        })
    })
  },

  getIsSuperUser ({ commit }) {
    return new Promise((resolve, reject) => {
      apiIsSuperUser()
        .then(respData => {
          console.log("get user auth success:", JSON.stringify(respData.user))
          // 刷新保存的数据
          commit('setAuthToken')
          commit('setLogonUserName', respData.user.name)
          commit('setIsSuperUser', respData.user.issuperuser === 'y' ? true : false)
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

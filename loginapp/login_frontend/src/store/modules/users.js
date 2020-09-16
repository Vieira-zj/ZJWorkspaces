import { loginRequest } from '@/api/users'
import { getUserToken } from '@/utils/auth'

const state = {
  authToken: "",
  logonUserName: "",
  isSuperUser: false
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
  }
}

const actions = {
  login ({ commit, state }, userInfo) {
    return new Promise((resolve, reject) => {
      loginRequest(userInfo)
        .then(response => {
          console.log('login success')
          const { data } = response
          commit('setLogonUserName', data.name)
          commit('setIsSuperUser', data.issuperuser === 'y' ? true : false)
          commit('setAuthToken')
          console.log('token cookie:', state.authToken)
          resolve()
        })
        .catch(err => {
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

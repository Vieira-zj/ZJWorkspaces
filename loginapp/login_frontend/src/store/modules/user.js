import { apiLogin, apiIsSuperUser } from '@/api/user'
import { getUserToken } from '@/utils/auth'

const state = {
  authToken: '',
  logonUserName: '',
  isSuperUser: false,
}

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

  getIsSuperUser ({ commit }) {
    return new Promise((resolve, reject) => {
      apiIsSuperUser()
        .then(respData => {
          console.log('get user auth success:', JSON.stringify(respData.user))
          // 刷新vuex中保存的数据
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
  mutations,
  actions
}

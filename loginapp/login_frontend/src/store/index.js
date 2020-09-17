import Vue from 'vue'
import Vuex from 'vuex'
import user from './modules/user'
import history from './modules/history'

Vue.use(Vuex)

const store = new Vuex.Store({
  modules: {
    history,
    user
  }
})

export default store

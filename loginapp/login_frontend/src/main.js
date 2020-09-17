// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
import axios from 'axios'

import store from './store'
import router from './router'
import { getUserToken } from '@/utils/auth'

Vue.config.productionTip = false
// 允许携带cookie, 解决跨域cookie丢失问题
axios.defaults.withCredentials = true
Vue.prototype.$axios = axios
Vue.use(ElementUI)

router.beforeEach(async (to, from, next) => {
  console.log(to.path)
  if (to.path.startsWith('/register') || to.path == '/login') {
    next()
    return
  }

  const token = getUserToken()
  if (token) {
    // 解决页面刷新后vuex保存的数据重置问题
    await store.dispatch('user/getIsSuperUser')
    next()
  } else {
    console.log('no auth, back to login')
    next('/login')
  }
})

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  components: { App },
  template: '<App/>'
})

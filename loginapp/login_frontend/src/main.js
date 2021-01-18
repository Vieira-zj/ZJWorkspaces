// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'

import GoogleAuth from '@/utils/google_oAuth.js'

import store from './store'
import router from './router'

Vue.config.productionTip = false

Vue.use(ElementUI)

// refer: https://github.com/Jebasuthan/Vue-Facebook-Google-oAuth
const gauthOption = {
  clientId: '1012509776989-786crbf1nm70mvmj7cu31nmbh5t9p2tm.apps.googleusercontent.com',
  scope: 'profile email',
  prompt: 'select_account'
}
Vue.use(GoogleAuth, gauthOption)

// use custom request instead
// 允许携带cookie, 解决跨域cookie丢失问题
// axios.defaults.withCredentials = true
// Vue.prototype.$axios = axios

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  components: { App },
  template: '<App/>'
})

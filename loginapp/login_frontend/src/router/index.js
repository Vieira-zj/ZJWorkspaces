import Vue from 'vue'
import Router from 'vue-router'

import store from '@/store'
import { getUserToken } from '@/utils/auth'
import { getPageTitle } from '@/utils/global'

Vue.use(Router)

const router = new Router({
  routes: [
    {
      path: '/',
      name: 'home',
      redirect: { name: 'login' },
      meta: { title: 'home' }
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/login'),
      meta: { title: 'login' }
    },
    {
      path: '/users',
      name: 'users',
      component: () => import('@/views/usersList'),
      meta: { title: 'users' }
    },
    {
      path: '/register1',
      name: 'register1',
      component: () => import('@/views/register1'),
      meta: { title: 'register' }
    },
    {
      path: '/register2/:name',
      name: 'register2',
      component: () => import('@/views/register2'),
      meta: { title: 'register' }
    },
    {
      path: '/edit/:name',
      name: 'edit',
      component: () => import('@/views/userEdit'),
      meta: { title: 'edit' }
    }
  ]
})

router.beforeEach(async (to, from, next) => {
  // console.log('router:', from.path, to.path)
  store.commit('history/setHistoryLastPage', from.path)
  document.title = getPageTitle(to.meta.title)

  const token = getUserToken()
  if (token) {
    if (!Boolean(store.state.user.authToken)) {
      // fix, after page refreshed, vuex store data is clear
      await store.dispatch('user/getIsSuperUser')
    }
    next()
  } else if (to.path == '/login' || to.path.startsWith('/register')) {
    next()
  } else {
    console.log('no auth, back to login')
    next('/login')
  }
})

export default router

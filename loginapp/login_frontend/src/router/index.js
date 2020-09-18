import Vue from 'vue'
import Router from 'vue-router'

import store from '@/store'
import { getUserToken } from '@/utils/auth'

Vue.use(Router)

const router = new Router({
  routes: [
    {
      path: '/',
      name: 'home',
      redirect: { name: 'login' }
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/login')
    },
    {
      path: '/users',
      name: 'users',
      component: () => import('@/views/users-list')
    },
    {
      path: '/register1',
      name: 'register1',
      component: () => import('@/views/register1')
    },
    {
      path: '/register2/:name',
      name: 'register2',
      component: () => import('@/views/register2')
    },
    {
      path: '/edit/:name',
      name: 'edit',
      component: () => import('@/views/user-edit')
    }
  ]
})

router.beforeEach(async (to, from, next) => {
  store.commit('history/setLastPage', from.path)

  const token = getUserToken()
  if (token) {
    // fix, after page refreshed, vuex store data is clear
    await store.dispatch('user/getIsSuperUser')
    next()
  } else if (to.path == '/login' || to.path.startsWith('/register')) {
    next()
  } else {
    console.log('no auth, back to login')
    next('/login')
  }
})

export default router

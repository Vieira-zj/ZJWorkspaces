import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('@/views/login')
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

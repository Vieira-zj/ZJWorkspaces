import Vue from 'vue'
import Router from 'vue-router'
import Login from '@/components/Login'
import Users from '@/components/Users'
import Register1 from '@/components/Register1'
import Register2 from '@/components/Register2'
import UserEdit from '@/components/UserEdit'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'home',
      component: Login
    },
    {
      path: '/login',
      name: 'login',
      component: Login
    },
    {
      path: '/users',
      name: 'users',
      component: Users
    },
    {
      path: '/register1',
      name: 'register1',
      component: Register1
    },
    {
      path: '/register2/:name',
      name: 'register2',
      component: Register2
    },
    {
      path: '/edit/:name',
      name: 'edit',
      component: UserEdit
    }
  ]
})

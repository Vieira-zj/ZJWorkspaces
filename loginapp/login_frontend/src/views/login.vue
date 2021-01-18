<template>
  <div>
    <div id="nav">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item>登录</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div id="login-container">
      <el-form id="login-form"
               ref="loginform"
               :model="loginform"
               :rules="rules">
        <h1 style="text-align: center;">登 录 页 面</h1>
        <el-form-item style="text-align: center;">
          <el-link :type="getPrimary(isID)"
                   @click="isID = true">
            账户密码登录
          </el-link>
          <el-divider direction="vertical"></el-divider>
          <el-link :type="getPrimary(!isID)"
                   @click="isID = false">
            手机号登录
          </el-link>
        </el-form-item>
        <el-form-item prop="username">
          <el-input ref="username"
                    v-model="loginform.username"
                    :placeholder="getNamePlaceHolder()"
                    prefix-icon="el-icon-user"
                    maxlength="20"></el-input>
        </el-form-item>
        <el-form-item prop="password">
          <el-input ref="password"
                    v-model="loginform.password"
                    :placeholder="getPwdPlaceHolder()"
                    prefix-icon="el-icon-lock"
                    show-password></el-input>
        </el-form-item>
        <el-form-item>
          <el-checkbox v-model="auto">自动登录</el-checkbox>
          <el-link href="https://element.eleme.io"
                   target="_blank"
                   style="float: right;">
            忘记密码
          </el-link>
        </el-form-item>
        <el-form-item>
          <el-button type="primary"
                     style="width: 100%;"
                     @click="onLogin">
            登 录
          </el-button>
        </el-form-item>
        <el-form-item>
          <span>其他登录方式</span>
          <i class="el-icon-position"></i>
          <i class="el-icon-connection"></i>
          <i class="el-icon-eleme"></i>
          <google-login />
          <el-link style="float: right;"
                   href="#/register1">注册账户</el-link>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script>
import { validateName, validatePassword } from '@/utils/auth'
import googleLogin from '@/components/googleLogin'

export default {
  name: 'login',
  components: {
    googleLogin,
  },
  data() {
    return {
      loginform: {
        username: this.$store.state.user.logonUserName,
        password: '',
      },
      rules: {
        username: [{ required: true, message: '不能为空', trigger: 'blur' }],
        password: [{ required: true, message: '不能为空', trigger: 'blur' }],
      },
      auto: false,
      isID: true,
    }
  },
  mounted() {
    if (!this.loginform.username) {
      this.$refs.username.focus()
    } else if (!this.loginform.password) {
      this.$refs.password.focus()
    }
  },
  methods: {
    getPrimary(flag) {
      return flag ? 'primary' : ''
    },
    getNamePlaceHolder() {
      return this.isID ? '用户名' : '手机号码'
    },
    getPwdPlaceHolder() {
      return this.isID ? '密码' : '验证码'
    },
    onLogin() {
      console.log('login info:', JSON.stringify(this.loginform))
      if (!validateName(this.loginform.username)) {
        return
      }
      if (!validatePassword(this.loginform.password)) {
        return
      }

      let vm = this
      this.$store
        .dispatch('user/login', {
          name: vm.loginform.username,
          password: vm.loginform.password,
        })
        .then(() => {
          let user = vm.$store.state.user
          user.isSuperUser
            ? vm.$router.push('/users')
            : vm.$router.push('/edit/' + user.logonUserName)
        })
        .catch((err) => {
          console.error(err)
        })
    },
  },
}
</script>

<style scoped>
#login-container {
  min-height: 100%;
  width: 100%;
  overflow: hidden;
}

#login-form {
  /* position: absolute;
  top: 30%;
  left: 50%;
  margin: -150px 0 0 -200px;
  width: 300px; */

  position: relative;
  width: 380px;
  max-width: 100%;
  padding: 140px 35px 0;
  margin: 0 auto; /* 上下0 左右auto (居中) */
  overflow: hidden;
}
</style>

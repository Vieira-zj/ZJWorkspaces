<template>
  <div>
    <div id="nav">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item to="/login">登录</el-breadcrumb-item>
        <el-breadcrumb-item>注册</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div id="user-form">
      <div>
        <el-steps :align-center="true"
                  :active="1">
          <el-step title="用户信息"></el-step>
          <el-step title="上传照片"></el-step>
        </el-steps>
      </div>
      <h1 style="text-align: center;">用 户 信 息</h1>
      <el-form ref="registerform"
               :model="registerform"
               :rules="formRules"
               label-width="80px">
        <!-- prop name must be equal to v-model bind value -->
        <el-form-item label="用户姓名"
                      prop="userName">
          <el-input ref="username"
                    v-model="registerform.userName"></el-input>
        </el-form-item>
        <el-form-item label="用户昵称">
          <el-input v-model="registerform.nickName"></el-input>
        </el-form-item>
        <el-form-item label="用户密码"
                      prop="password1">
          <el-input v-model="registerform.password1"
                    show-password></el-input>
        </el-form-item>
        <el-form-item label="确认密码"
                      prop="password2">
          <el-input v-model="registerform.password2"
                    show-password></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary"
                     @click="onSubmit">下一步</el-button>
          <el-button @click="onCancel">返回</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script>
import { validateName, validatePassword } from '@/utils/auth'
import { showErrorMessage } from '@/utils/global'

export default {
  name: 'registerStep1',
  data() {
    return {
      registerform: {
        userName: '',
        nickName: '',
        password1: '',
        password2: '',
      },
      formRules: {
        userName: [
          { required: true, message: '请输入用户名', trigger: 'blur' },
        ],
        password1: [{ required: true, message: '请输入密码', trigger: 'blur' }],
        password2: [
          { required: true, message: '请输入确认密码', trigger: 'blur' },
        ],
      },
    }
  },
  mounted() {
    this.$refs.username.focus()
  },
  methods: {
    onSubmit() {
      console.log('submit user:', JSON.stringify(this.registerform))
      if (!validateName(this.registerform.userName)) {
        return
      }
      if (!validatePassword(this.registerform.password1)) {
        return
      }
      if (this.registerform.password1 !== this.registerform.password2) {
        showErrorMessage('两次输入密码不一致！')
        return
      }

      let registerData = {
        name: this.registerform.userName,
        nickname: this.registerform.nickName,
        password: this.registerform.password1,
      }
      let vm = this
      this.$store
        .dispatch('user/registerUser', registerData)
        .then((user) => {
          vm.$router.push('/register2/' + user.name)
        })
        .catch((err) => {
          console.error(err)
        })
    },
    onCancel() {
      this.$router.push('/login')
    },
  },
}
</script>

<style scoped>
#user-form {
  position: absolute;
  top: 30%;
  left: 50%;
  margin: -150px 0 0 -200px;
  width: 300px;
}
</style>

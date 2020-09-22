<template>
  <div>
    <div id="nav">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item to="/login">登录</el-breadcrumb-item>
        <el-breadcrumb-item>注册</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div id="form-container">
      <el-form id="register-form"
               ref="registerform"
               :model="registerform"
               :rules="formRules"
               label-width="80px">
        <div>
          <el-steps :align-center="true"
                    :active="1">
            <el-step title="用户信息"></el-step>
            <el-step title="上传照片"></el-step>
          </el-steps>
        </div>
        <h1 style="text-align: center;">用 户 信 息</h1>
        <!-- prop name must be equal to v-model bind value -->
        <div id="inputs">
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
        </div>
        <el-form-item>
          <el-button type="primary"
                     @click="onSubmit">下一步</el-button>
          <el-button @click="onCancel">返 回</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script>
import { validateName, validatePassword } from '@/utils/auth'
import { showErrorMessage } from '@/utils/global'
import { apiNewUser } from '@/api/user'

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
    if (!this.registerform.userName) {
      this.$refs.username.focus()
    }
  },
  methods: {
    async onSubmit() {
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
      try {
        let { user } = await apiNewUser(registerData)
        console.log('register user success:', JSON.stringify(user))
        this.$router.push('/register2/' + user.name)
      } catch (err) {
        // request aop 中已处理
        console.error(err)
      }
    },
    onCancel() {
      this.$router.push('/login')
    },
  },
}
</script>

<style scoped>
#form-container {
  min-height: 100%;
  width: 100%;
  overflow: hidden;
}

#register-form {
  position: relative;
  width: 400px;
  max-width: 100%;
  padding: 160px 35px 0;
  margin: 0 auto;
  overflow: hidden;
}

#inputs {
  padding: 10px;
}

button {
  width: 100px;
}
</style>

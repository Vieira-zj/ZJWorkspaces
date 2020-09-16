<template>
  <div>
    <div id="nav">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item to="/login">登录</el-breadcrumb-item>
        <el-breadcrumb-item>注册</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div id="user_form">
      <div>
        <el-steps :align-center="true" :active="1">
          <el-step title="用户信息"></el-step>
          <el-step title="上传照片"></el-step>
        </el-steps>
      </div>
      <h1 style="text-align: center;">用 户 信 息</h1>
      <el-form ref="form" :model="user" :rules="formRules" label-width="80px">
        <!-- prop name must be equal to v-model bind value -->
        <el-form-item label="用户姓名" prop="userName">
          <el-input v-model="user.userName"></el-input>
        </el-form-item>
        <el-form-item label="用户昵称">
          <el-input v-model="user.nickName"></el-input>
        </el-form-item>
        <el-form-item label="用户密码" prop="password1">
          <el-input v-model="user.password1" show-password></el-input>
        </el-form-item>
        <el-form-item label="确认密码" prop="password2">
          <el-input v-model="user.password2" show-password></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="onSubmit">下一步</el-button>
          <el-button @click="onCancel">返回</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script>
import { getUserToken } from "@/utils/auth";
import { errorHandler } from "@/utils/global";

export default {
  name: "register_step1",
  data() {
    return {
      user: {
        userName: "",
        nickName: "",
        password1: "",
        password2: ""
      },
      formRules: {
        userName: [
          { required: true, message: "请输入用户名", trigger: "blur" }
        ],
        password1: [{ required: true, message: "请输入密码", trigger: "blur" }],
        password2: [
          { required: true, message: "请输入确认密码", trigger: "blur" }
        ]
      }
    };
  },
  methods: {
    onSubmit() {
      console.log("submit user:", JSON.stringify(this.user));
      if (
        !Boolean(this.user.userName) ||
        !Boolean(this.user.password1) ||
        !Boolean(this.user.password2)
      ) {
        this.$message.error("输入用户名或密码为空！");
        return;
      }
      if (this.user.password1.length < 6) {
        this.$message.error("输入密码长度不能小于6！");
        return;
      }
      if (this.user.password1 !== this.user.password2) {
        this.$message.error("两次输入密码不一致！");
        return;
      }

      let vm = this;
      let registerData = {
        name: vm.user.userName,
        nickname: vm.user.nickName,
        password: vm.user.password1
      };
      this.$store
        .dispatch("users/register1", registerData)
        .then(() => {
          vm.$router.push("/register2/" + vm.user.userName);
        })
        .catch(err => {
          // handle default
        });
    },
    onCancel() {
      this.$router.push("/login");
    }
  }
};
</script>

<style scoped>
#user_form {
  position: absolute;
  top: 30%;
  left: 50%;
  margin: -150px 0 0 -200px;
  width: 300px;
}
</style>

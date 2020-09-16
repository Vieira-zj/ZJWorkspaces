<template>
  <div>
    <div id="nav">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item>登录</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div id="login">
      <h1 style="text-align: center;">登 录 页 面</h1>
      <el-form ref="form" :model="user" :rules="rules">
        <el-form-item style="text-align: center;">
          <el-link :type="getPrimary(isID)" @click="isID = true">
            账户密码登录
          </el-link>
          <el-divider direction="vertical"></el-divider>
          <el-link :type="getPrimary(!isID)" @click="isID = false">
            手机号登录
          </el-link>
        </el-form-item>
        <el-form-item prop="name">
          <el-input
            v-model="user.name"
            :placeholder="getNamePlaceHolder()"
            prefix-icon="el-icon-user"
            maxlength="20"
          ></el-input>
        </el-form-item>
        <el-form-item prop="password">
          <el-input
            v-model="user.password"
            :placeholder="getPwdPlaceHolder()"
            prefix-icon="el-icon-lock"
            show-password
          ></el-input>
        </el-form-item>
        <el-form-item>
          <el-checkbox v-model="auto">自动登录</el-checkbox>
          <el-link
            href="https://element.eleme.io"
            target="_blank"
            style="float: right;"
          >
            忘记密码
          </el-link>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" style="width: 100%;" @click="login">
            登 录
          </el-button>
        </el-form-item>
        <el-form-item>
          <span>其他登录方式</span>
          <i class="el-icon-position"></i>
          <i class="el-icon-connection"></i>
          <i class="el-icon-eleme"></i>
          <el-link style="float: right;" href="#/register1">注册账户</el-link>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script>
import { errorHandler } from "@/utils/global";

export default {
  name: "login",
  data() {
    return {
      user: {
        name: "",
        password: ""
      },
      rules: {
        name: [{ required: true, message: "请输入", trigger: "blur" }],
        password: [{ required: true, message: "请输入", trigger: "blur" }]
      },
      auto: false,
      isID: true
    };
  },
  methods: {
    getPrimary(flag) {
      return flag ? "primary" : "";
    },
    getNamePlaceHolder() {
      return this.isID ? "用户名" : "手机号码";
    },
    getPwdPlaceHolder() {
      return this.isID ? "密码" : "验证码";
    },
    login() {
      console.log("login info:", JSON.stringify(this.user));
      if (!Boolean(this.user.name) || !Boolean(this.user.password)) {
        this.$message.error("输入用户名或密码为空！");
        return;
      } else if (this.user.password.length < 6) {
        this.$message.error("输入密码长度不能小于6！");
        return;
      }

      let vm = this;
      vm.$store
        .dispatch("users/login", {
          name: vm.user.name,
          password: vm.user.password
        })
        .then(() => {
          vm.$store.state.users.isSuperUser
            ? vm.$router.push("/users")
            : vm.$router.push("/edit/" + vm.user.name);
        })
        .catch(() => {
          // handle default
        });
    }
  }
};
</script>

<style scoped>
#login {
  position: absolute;
  top: 30%;
  left: 50%;
  margin: -150px 0 0 -200px;
  width: 300px;
}
</style>

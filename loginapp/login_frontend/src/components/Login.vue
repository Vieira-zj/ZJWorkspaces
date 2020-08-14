<template>
  <div>
    <div id="nav">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item>
          <router-link to="/login">登录</router-link>
        </el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div id="login">
      <h1 style="text-align: center;">登 录 页 面</h1>
      <el-form ref="form" :model="user">
        <el-form-item style="text-align: center;">
          <el-link :type="getPrimary(isID)" @click="isID = true">
            账户密码登录
          </el-link>
          <el-divider direction="vertical"></el-divider>
          <el-link :type="getPrimary(!isID)" @click="isID = false">
            手机号登录
          </el-link>
        </el-form-item>
        <el-form-item>
          <el-input
            v-model="user.name"
            :placeholder="getNamePlaceHolder()"
            prefix-icon="el-icon-user"
            maxlength="20"
          ></el-input>
        </el-form-item>
        <el-form-item>
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
            type="primary"
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
          <el-link
            type="primary"
            href="https://element.eleme.io"
            target="_blank"
            style="float: right;"
          >
            注册账户
          </el-link>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script>
import global_ from "./Global";

export default {
  name: "login",
  data() {
    return {
      user: {
        name: "",
        password: ""
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
      if (this.user.name.length == 0 || this.user.password == 0) {
        this.$message.error("输入用户名或密码为空！");
        return;
      } else if (this.user.password.length < 6) {
        this.$message.error("输入密码长度不能小于6！");
        return;
      }

      let vm = this;
      this.$axios
        .post("http://localhost:12340/login", {
          name: vm.user.name,
          password: vm.user.password
        })
        .then(response => {
          console.log("login success");
          console.log("cookie:", document.cookie);

          if (response.data.navigation == "users") {
            vm.$router.push("/users");
          } else {
            vm.$router.push("/edit");
          }
        })
        .catch(err => {
          global_.fnErrorHandler(vm, err);
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

<template>
  <div>
    <div id="nav">
      <div style="float:left">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item to="/login">登录</el-breadcrumb-item>
          <el-breadcrumb-item to="/users" v-if="isCurSuperUser"
            >用户列表</el-breadcrumb-item
          >
          <el-breadcrumb-item>用户信息</el-breadcrumb-item>
        </el-breadcrumb>
      </div>
      <div style="float:right">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item>
            <router-link to="/login" id="logout_link" @click.native="onLogout"
              >退出</router-link
            >
          </el-breadcrumb-item>
        </el-breadcrumb>
      </div>
    </div>
    <div id="user_form">
      <h1 style="text-align: center;">用 户 信 息</h1>
      <el-form ref="form" :model="user" label-width="80px">
        <el-form-item label="用户头像">
          <!-- <img src="../assets/user01.jpeg"
               width="100px"
               height="100px"> -->
          <el-image
            :fit="imgProps.fit"
            :src="imgProps.url"
            style="width: 100px; height: 100px"
          >
            <div slot="error" class="image-slot el-image__error">
              <i class="el-icon-picture-outline"></i>
            </div>
          </el-image>
          <el-upload
            :action="uploadUrl"
            :headers="uploadHeaders"
            :show-file-list="false"
            :before-upload="onBeforeUpload"
            :on-success="onSuccessUpload"
          >
            <el-button size="small" type="primary">点击上传</el-button>
            <div slot="tip" class="el-upload__tip">
              只能上传jpg/png文件，且不超过500kb
            </div>
          </el-upload>
        </el-form-item>
        <el-form-item label="用户姓名">
          <el-input v-model="user.userName" :disabled="true"></el-input>
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
        <el-form-item label="管理员">
          <el-switch
            v-model="user.isSuperUser"
            :disabled="!isCurSuperUser"
          ></el-switch>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="onSubmit">提交</el-button>
          <el-button @click="onCancel">取消</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script>
import { getUserToken, removeUserToken } from "@/utils/auth";
import { errorHandler, toUnicode } from "@/utils/global";

let mockUser = {
  userName: "name01",
  nickName: "nick01",
  isSuperUser: false
};

export default {
  name: "userEdit",
  data() {
    return {
      isCurSuperUser: false,
      user: {
        userName: "",
        nickName: "",
        isSuperUser: false,
        picture: "",
        password1: "",
        password2: ""
      },
      imgProps: {
        fit: "fill",
        url: ""
      },
      uploadUrl: process.env.VUE_APP_BASE_API + "/uploadpic",
      uploadHeaders: {
        Authorization: ""
      }
    };
  },
  created() {
    this.isCurSuperUser = this.$store.state.users.isSuperUser;
    console.log("is current super user:", this.isCurSuperUser);

    if (
      !this.isCurSuperUser &&
      this.$route.params.name !== this.$store.state.users.logonUserName
    ) {
      this.$message.error("没有权限访问用户数据！");
      return;
    }

    let vm = this;
    this.$axios({
      method: "POST",
      url: process.env.VUE_APP_BASE_API + "/getuser",
      headers: { Authorization: getUserToken() },
      data: {
        name: vm.$route.params.name
      }
    })
      .then(resp => {
        let loadUser = resp.data.user;
        console.log("load user:", loadUser);

        vm.user = {
          userName: loadUser.name,
          nickName: loadUser.nickname,
          isSuperUser: loadUser.issuperuser === "y" ? true : false,
          picture: loadUser.picture
        };

        if (Boolean(loadUser.picture)) {
          vm.imgProps.url =
            process.env.VUE_APP_BASE_API + "/downloadpic/" + loadUser.picture;
        }
        vm.uploadHeaders = {
          Authorization: getUserToken,
          "Specified-User": loadUser.name
        };
      })
      .catch(err => {
        errorHandler(vm, err);
      });
  },
  methods: {
    onBeforeUpload(file) {
      console.log("upload file:", file.name);
      this.uploadHeaders["X-Test"] = "uploadfile_" + toUnicode(file.name);
    },
    onSuccessUpload(response, file, fileList) {
      console.log("upload file success");
      this.imgProps.url =
        process.env.VUE_APP_BASE_API + "/downloadpic/" + response.filename;
    },
    onSubmit() {
      if (Boolean(this.user.password1)) {
        if (this.user.password1.length < 6) {
          this.$message.error("输入密码长度不能小于6！");
          return;
        }
        if (this.user.password1 !== this.user.password2) {
          this.$message.error("两次输入密码不一致！");
          return;
        }
      }

      let vm = this;
      this.$axios({
        method: "POST",
        url: process.env.VUE_APP_BASE_API + "/edituser",
        headers: { Authorization: getUserToken() },
        data: {
          name: vm.$route.params.name,
          data: {
            nickname: vm.user.nickName,
            issuperuser: vm.user.isSuperUser ? "y" : "n",
            password: vm.user.password1
          }
        }
      })
        .then(resp => {
          vm.$message({
            message: "用户信息修改成功",
            type: "success"
          });
        })
        .catch(err => {
          errorHandler(vm, err);
        });
    },
    onCancel() {
      this.$router.back(-1);
    },
    onLogout() {
      removeUserToken;
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

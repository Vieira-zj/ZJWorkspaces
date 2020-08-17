<template>
  <div>
    <div id="nav">
      <div style="float:left">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item to="/login">登录</el-breadcrumb-item>
          <el-breadcrumb-item to="/users" v-if="isCurSuperUser"
            >用户列表</el-breadcrumb-item
          >
          <el-breadcrumb-item to="/edit">用户信息</el-breadcrumb-item>
        </el-breadcrumb>
      </div>
      <div style="float:right">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item to="/login" @click="onLogout"
            >退出
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
            action="http://localhost:12340/uploadpic"
            :headers="uploadHeaders"
            :show-file-list="false"
            :before-upload="onBeforeUpload"
            :on-success="onSuccessUpload"
          >
            <el-button size="small" type="primary" :disabled="!isCurSuperUser"
              >点击上传</el-button
            >
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
        <el-form-item label="管理员">
          <el-switch v-model="user.isSuperUser"></el-switch>
        </el-form-item>
        <el-form-item>
          <el-button
            type="primary"
            :disabled="!isCurSuperUser"
            @click="onSubmit"
            >提交</el-button
          >
          <el-button @click="onCancel">取消</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script>
import global_ from "./Global";

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
        picture: ""
      },
      imgProps: {
        fit: "fill",
        url: ""
      },
      uploadHeaders: {
        Authorization: ""
      }
    };
  },
  created() {
    this.isCurSuperUser = global_.fnGetIsSuperUser();
    console.log("is current super user:", this.isCurSuperUser);

    let vm = this;
    this.$axios({
      method: "POST",
      url: global_.host + "/getuser",
      headers: { Authorization: global_.fnGetCookie("user-token") },
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
          vm.imgProps.url = global_.host + "/downloadpic/" + loadUser.picture;
        }
        vm.uploadHeaders = {
          Authorization: global_.fnGetCookie("user-token"),
          "Specified-User": loadUser.name
        };
      })
      .catch(err => {
        global_.fnErrorHandler(vm, err);
      });
  },
  methods: {
    onBeforeUpload(file) {
      this.uploadHeaders["X-Test"] = "uploadfile_" + file.name;
    },
    onSuccessUpload(response, file, fileList) {
      console.log("upload file success");
      this.imgProps.url = global_.host + "/downloadpic/" + response.filename;
    },
    onSubmit() {
      let vm = this;
      this.$axios({
        method: "POST",
        url: global_.host + "/edituser",
        headers: { Authorization: global_.fnGetCookie("user-token") },
        data: {
          name: vm.$route.params.name,
          data: {
            nickname: vm.user.nickName,
            issuperuser: vm.user.isSuperUser ? "y" : "n"
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
          global_.fnErrorHandler(vm, err);
        });
    },
    onCancel() {
      this.$router.back(-1);
    },
    onLogout() {
      console.log("logout");
      global_.fnClearCookie("user-token");
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

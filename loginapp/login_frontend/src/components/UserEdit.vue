<template>
  <div>
    <div id="nav">
      <div style="float:left">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item>
            <router-link to="/login">登录</router-link>
          </el-breadcrumb-item>
          <el-breadcrumb-item v-if="isCurSuperUser">
            <router-link to="/users">用户列表</router-link>
          </el-breadcrumb-item>
          <el-breadcrumb-item>
            <router-link to="/edit">用户信息</router-link>
          </el-breadcrumb-item>
        </el-breadcrumb>
      </div>
      <div style="float:right">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item>
            <router-link to="/login" @click.native="onLogout">退出</router-link>
          </el-breadcrumb-item>
        </el-breadcrumb>
      </div>
    </div>
    <div id="user_edit">
      <h1 style="text-align: center;">用 户 信 息</h1>
      <el-form ref="form" :model="user" label-width="80px">
        <el-form-item label="用户头像">
          <!-- <img src="../assets/user01.jpeg"
               width="100px"
               height="100px"> -->
          <el-image
            style="width: 100px; height: 100px"
            :src="img.url"
            :fit="img.fit"
          ></el-image>
          <el-upload
            class="upload-demo"
            action="https://jsonplaceholder.typicode.com/posts/"
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
        <el-form-item label="管理员">
          <el-switch v-model="user.isSuperUser"></el-switch>
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
      user: {
        userName: "",
        nickName: "",
        isSuperUser: false
      },
      img: {
        fit: "fill",
        url: "/static/user01.jpeg"
      },
      isCurSuperUser: false
    };
  },
  mounted() {
    this.isCurSuperUser = global_.fnGetIsSuperUser();
    let vm = this;
    this.$axios({
      method: "POST",
      url: "http://127.0.0.1:12340/getuser",
      headers: { Authorization: global_.fnGetCookie("user-token") },
      data: {
        name: vm.$route.params.name
      }
    })
      .then(resp => {
        let loadUser = resp.data.user;
        vm.user = {
          userName: loadUser.name,
          nickName: loadUser.nickname,
          isSuperUser: loadUser.issuperuser === "y" ? true : false
        };
      })
      .catch(err => {
        global_.fnErrorHandler(vm, err);
      });
  },
  methods: {
    onSubmit() {
      let vm = this;
      this.$axios({
        method: "POST",
        url: "http://127.0.0.1:12340/edituser",
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
#user_edit {
  position: absolute;
  top: 30%;
  left: 50%;
  margin: -150px 0 0 -200px;
  width: 300px;
}
</style>

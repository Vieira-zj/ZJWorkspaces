<template>
  <div>
    <div id="nav">
      <div style="float:left">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item>
            <router-link to="/login">登录</router-link>
          </el-breadcrumb-item>
          <el-breadcrumb-item>
            <router-link to="/users">用户列表</router-link>
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
    <div id="users">
      <div style="margin-bottom: 20px">
        <span>
          <el-link type="primary">用户列表</el-link>
          <i class="el-icon-user"></i>
        </span>
      </div>
      <el-table :data="usersList" stripe border style="width: 100%">
        <el-table-column prop="userName" label="用户名" width="180">
        </el-table-column>
        <el-table-column prop="nickName" label="昵称" width="180">
        </el-table-column>
        <el-table-column prop="isSuperUser" label="管理员"> </el-table-column>
        <el-table-column fixed="right" label="操作" width="100">
          <template slot-scope="scope">
            <el-button @click="handleEdit(scope.row)" type="text" size="small"
              >编辑</el-button
            >
          </template>
        </el-table-column>
      </el-table>
      <div id="paging">
        <el-pagination
          align="center"
          layout="prev, pager, next"
          :current-page="1"
          :page-size="pageSize"
          :total="usersCount"
          @current-change="currentChange"
        ></el-pagination>
      </div>
    </div>
  </div>
</template>

<script>
import global_ from "./Global";

let mockUsers = [
  {
    userName: "name01",
    nickName: "nick01",
    isSuperUser: global_.fnIsSuperUserCn(true)
  },
  {
    userName: "name02",
    nickName: "nick02",
    isSuperUser: global_.fnIsSuperUserCn(false)
  },
  {
    userName: "name03",
    nickName: "nick03",
    isSuperUser: global_.fnIsSuperUserCn(false)
  }
];

export default {
  name: "users",
  data() {
    return {
      usersCount: 0,
      pageSize: 10,
      usersList: []
    };
  },
  created() {
    let vm = this;
    this.$axios({
      method: "GET",
      url: "http://127.0.0.1:12340/issuperuser",
      headers: { Authorization: global_.fnGetCookie("user-token") }
    })
      .then(resp => {
        if (resp.data.issuperuser !== "y") {
          this.$message.error("没有权限访问用户数据！");
          return;
        }
        this.$axios({
          method: "POST",
          url: "http://127.0.0.1:12340/getusers",
          headers: { Authorization: global_.fnGetCookie("user-token") },
          data: {
            start: "0",
            offset: "10"
          }
        })
          .then(resp => {
            vm.usersCount = parseInt(resp.data.count, 10);
            let users = resp.data.users;
            for (let i = 0; i < users.length; i++) {
              let user = users[i];
              vm.usersList.push({
                userName: user.name,
                nickName: user.nickname,
                isSuperUser: user.issuperuser
              });
            }
          })
          .catch(err => {
            global_.fnErrorHandler(vm, err);
          });
      })
      .catch(err => {
        global_.fnErrorHandler(vm, err);
      });
  },
  methods: {
    handleEdit(row) {
      this.$router.push("/edit/" + row.userName);
    },
    currentChange(currentPage) {
      let vm = this;
      this.$axios({
        method: "POST",
        url: "http://127.0.0.1:12340/getusers",
        headers: { Authorization: global_.fnGetCookie("user-token") },
        data: {
          start: ((currentPage - 1) * vm.pageSize).toString(),
          offset: vm.pageSize
        }
      })
        .then(resp => {
          vm.usersCount = parseInt(resp.data.count, 10);
          vm.usersList.splice(0, vm.usersList.length);
          let users = resp.data.users;
          for (let i = 0; i < users.length; i++) {
            let user = users[i];
            vm.usersList.push({
              userName: user.name,
              nickName: user.nickname,
              isSuperUser: user.issuperuser
            });
          }
        })
        .catch(err => {
          global_.fnErrorHandler(vm, err);
        });
    },
    onLogout() {
      console.log("logout");
      global_.fnClearCookie("user-token");
    }
  }
};
</script>

<style scoped>
#users {
  position: absolute;
  top: 10%;
  left: 10%;
  width: 800px;
}
#paging {
  text-align: center;
  margin-top: 30px;
}
</style>

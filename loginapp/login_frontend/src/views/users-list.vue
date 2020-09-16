<template>
  <div>
    <div id="nav">
      <div style="float:left">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item to="/login">登录</el-breadcrumb-item>
          <el-breadcrumb-item>用户列表</el-breadcrumb-item>
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
    <div id="users">
      <div style="margin-bottom: 20px">
        <span>
          <el-link type="primary">用户列表</el-link>
          <i class="el-icon-user"></i>
        </span>
      </div>
      <el-table
        v-loading="loading"
        :data="usersList"
        stripe
        border
        style="width: 100%"
      >
        <el-table-column prop="userName" label="用户名" width="250">
        </el-table-column>
        <el-table-column prop="nickName" label="昵称" width="250">
        </el-table-column>
        <el-table-column prop="isSuperUser" label="超极权限"></el-table-column>
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
import { getUserToken, removeUserToken } from "@/utils/auth";
import { isSuperUserCn, errorHandler } from "@/utils/global";

let mockUsers = [
  {
    userName: "name01",
    nickName: "nick01",
    isSuperUser: isSuperUserCn("y")
  },
  {
    userName: "name02",
    nickName: "nick02",
    isSuperUser: isSuperUserCn("n")
  },
  {
    userName: "name03",
    nickName: "nick03",
    isSuperUser: isSuperUserCn("n")
  }
];

export default {
  name: "users",
  data() {
    return {
      usersCount: 0,
      pageSize: 10,
      usersList: [],
      loading: true
    };
  },
  created() {
    console.log("cookie:", getUserToken());
    let vm = this;
    this.$axios({
      method: "GET",
      url: process.env.VUE_APP_BASE_API + "/issuperuser",
      headers: { Authorization: getUserToken() }
    })
      .then(resp => {
        if (resp.data.issuperuser !== "y") {
          this.$message.error("没有权限访问用户数据！");
          return;
        }
        this.$axios({
          method: "POST",
          url: process.env.VUE_APP_BASE_API + "/getusers",
          headers: { Authorization: getUserToken() },
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
                isSuperUser: isSuperUserCn(user.issuperuser)
              });
            }
            vm.loading = false;
          })
          .catch(err => {
            errorHandler(vm, err);
            vm.loading = false;
          });
      })
      .catch(err => {
        errorHandler(vm, err);
        vm.loading = false;
      });
  },
  methods: {
    handleEdit(row) {
      this.$router.push("/edit/" + row.userName);
    },
    currentChange(currentPage) {
      this.loading = true;
      let vm = this;
      this.$axios({
        method: "POST",
        url: process.env.VUE_APP_BASE_API + "/getusers",
        headers: { Authorization: getUserToken() },
        data: {
          start: ((currentPage - 1) * vm.pageSize).toString(),
          offset: vm.pageSize.toString()
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
            vm.loading = false;
          }
        })
        .catch(err => {
          errorHandler(vm, err);
          vm.loading = false;
        });
    },
    onLogout() {
      removeUserToken();
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

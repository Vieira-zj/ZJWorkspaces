<template>
  <div>
    <div id="nav">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item>
          <router-link to="/login">登录</router-link>
        </el-breadcrumb-item>
        <el-breadcrumb-item>
          <router-link to="/users">用户列表</router-link>
        </el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <el-divider></el-divider>
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
          :page-size="10"
          :total="usersCount"
          :current-page="1"
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
    isSuperUser: global_.fnIsSuperUser(true)
  },
  {
    userName: "name02",
    nickName: "nick02",
    isSuperUser: global_.fnIsSuperUser(false)
  },
  {
    userName: "name03",
    nickName: "nick03",
    isSuperUser: global_.fnIsSuperUser(false)
  }
];

export default {
  name: "users",
  data() {
    return {
      usersCount: 0,
      usersList: []
    };
  },
  mounted() {
    let c = global_.fnGetCookie("user-token");

    let vm = this;
    this.$axios({
      method: "POST",
      url: "http://127.0.0.1:12340/getusers",
      headers: { Authorization: c },
      data: {
        start: "0",
        offset: "10"
      }
    })
      .then(resp => {
        this.usersCount = parseInt(resp.data.count, 10);
        let users = resp.data.users;
        for (let i = 0; i < users.length; i++) {
          let user = users[i];
          this.usersList.push({
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
  methods: {
    handleEdit(row) {
      console.log("edit user:", row);
      this.$router.push("/edit");
    },
    currentChange(currentPage) {
      console.log("page:", currentPage);
      // TODO:
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

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
        <el-link :underline="false"
                 @click.native="onLogout">退出</el-link>
      </div>
    </div>
    <div id="users">
      <div style="margin-bottom: 20px">
        <span>
          <el-link type="primary">用户列表</el-link>
          <i class="el-icon-user"></i>
        </span>
      </div>
      <el-table v-loading="loading"
                :data="usersList"
                stripe
                border
                style="width: 100%">
        <el-table-column prop="userName"
                         label="用户名"
                         width="250">
        </el-table-column>
        <el-table-column prop="nickName"
                         label="昵称"
                         width="250">
        </el-table-column>
        <el-table-column prop="isSuperUser"
                         label="超极权限"></el-table-column>
        <el-table-column fixed="right"
                         label="操作"
                         width="100">
          <template slot-scope="scope">
            <el-button @click="onEdit(scope.row)"
                       type="text"
                       size="small">编辑</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div id="paging">
        <el-pagination align="center"
                       layout="prev, pager, next"
                       :current-page="1"
                       :page-size="pageSize"
                       :total="usersCount"
                       @current-change="onCurrentChange"></el-pagination>
      </div>
    </div>
  </div>
</template>

<script>
import { removeUserToken } from '@/utils/auth'
import { isSuperUserCn, showErrorMessage } from '@/utils/global'
import { apiGetUsers } from '@/api/user'

export default {
  name: 'usersList',
  data() {
    return {
      usersCount: 0,
      pageSize: 10,
      usersList: [],
      loading: false,
    }
  },
  async created() {
    if (!this.$store.state.user.isSuperUser) {
      showErrorMessage('没有权限访问用户数据！')
      return
    }

    this.loading = true
    try {
      let respData = await apiGetUsers({ start: '0', offset: '10' })
      console.log('load users success')
      this.updateUserList(respData)
      this.loading = false
    } catch (err) {
      console.error(err)
      this.loading = false
    }
  },
  methods: {
    updateUserList(respData) {
      if (this.usersList.length > 0) {
        this.usersList.splice(0, this.usersList.length)
      }
      this.usersCount = parseInt(respData.count, 10)
      let users = respData.users
      for (let i = 0; i < users.length; i++) {
        let user = users[i]
        this.usersList.push({
          userName: user.name,
          nickName: user.nickname,
          isSuperUser: isSuperUserCn(user.issuperuser),
        })
      }
    },
    onEdit(row) {
      this.$router.push('/edit/' + row.userName)
    },
    async onCurrentChange(currentPage) {
      this.loading = true
      try {
        let respData = await apiGetUsers({
          start: ((currentPage - 1) * this.pageSize).toString(),
          offset: this.pageSize.toString(),
        })
        this.updateUserList(respData)
        this.loading = false
      } catch (err) {
        console.error(err)
        this.loading = false
      }
    },
    onLogout() {
      removeUserToken()
      this.$router.push('/login')
    },
  },
}
</script>

<style scoped>
#users {
  position: absolute;
  top: 10%;
  left: 25%;
  width: 800px;
}
#paging {
  text-align: center;
  margin-top: 30px;
}
</style>

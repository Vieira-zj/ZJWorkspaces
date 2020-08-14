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
      <el-table :data="usersList"
                stripe
                border
                style="width: 100%">
        <el-table-column prop="userName"
                         label="用户名"
                         width="180">
        </el-table-column>
        <el-table-column prop="nickName"
                         label="昵称"
                         width="180">
        </el-table-column>
        <el-table-column prop="isSuperUser"
                         label="管理员">
        </el-table-column>
        <el-table-column fixed="right"
                         label="操作"
                         width="100">
          <template slot-scope="scope">
            <el-button @click="handleEdit(scope.row)"
                       type="text"
                       size="small">编辑</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>
  </div>
</template>

<script>
function fnIsSuperUser (flag) {
  return flag ? '是' : '否'
}

export default {
  name: 'users',
  data () {
    return {
      usersList: [
        { userName: 'name01', nickName: 'nick01', isSuperUser: fnIsSuperUser(true) },
        { userName: 'name02', nickName: 'nick02', isSuperUser: fnIsSuperUser(false) },
        { userName: 'name03', nickName: 'nick03', isSuperUser: fnIsSuperUser(false) }
      ]
    }
  },
  mounted () {
    console.log('TODO: get users')
  },
  methods: {
    handleEdit (row) {
      console.log('edit user:', row)
      this.$router.push('/edit')
    }
  }
}
</script>

<style scoped>
#users {
  position: absolute;
  top: 10%;
  left: 10%;
  width: 800px;
}
</style>

<template>
  <div>
    <div id="nav">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item>
          <router-link to="/login">登录</router-link>
        </el-breadcrumb-item>
        <el-breadcrumb-item>
          <router-link to="/edit">用户信息</router-link>
        </el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div id="user_edit">
      <h1 style="text-align: center;">用 户 信 息</h1>
      <el-form ref="form"
               :model="user"
               label-width="80px">
        <el-form-item label="用户头像">
          <!-- <img src="../assets/user01.jpeg"
               width="100px"
               height="100px"> -->
          <el-image style="width: 100px; height: 100px"
                    :src="img.url"
                    :fit="img.fit"></el-image>
          <el-upload class="upload-demo"
                     action="https://jsonplaceholder.typicode.com/posts/">
            <el-button size="small"
                       type="primary">点击上传</el-button>
            <div slot="tip"
                 class="el-upload__tip">只能上传jpg/png文件，且不超过500kb</div>
          </el-upload>
        </el-form-item>
        <el-form-item label="用户姓名">
          <el-input v-model="user.userName"
                    :disabled="true"></el-input>
        </el-form-item>
        <el-form-item label="用户昵称">
          <el-input v-model="user.nickName"></el-input>
        </el-form-item>
        <el-form-item label="管理员">
          <el-switch v-model="user.isSuperUser"></el-switch>
        </el-form-item>
        <el-form-item>
          <el-button type="primary"
                     @click="onSubmit">提交</el-button>
          <el-button>取消</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'userEdit',
  data () {
    return {
      user: {
        userName: 'name01', nickName: 'nick01', isSuperUser: false
      },
      img: {
        fit: 'fill',
        url: '/static/user01.jpeg'
      }
    }
  },
  methods: {
    onSubmit () {
      console.log('TODO: submit')
    }
  }
}
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
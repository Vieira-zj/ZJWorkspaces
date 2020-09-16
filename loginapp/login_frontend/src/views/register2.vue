<template>
  <div>
    <div id="nav">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item>登录</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div id="user_form">
      <div>
        <el-steps :align-center="true" :active="2">
          <el-step title="用户信息"></el-step>
          <el-step title="上传照片"></el-step>
        </el-steps>
      </div>
      <h1 style="text-align: center;">用 户 信 息</h1>
      <el-form ref="form" :model="user" label-width="80px">
        <el-form-item label="用户头像">
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
        <el-form-item>
          <el-button type="primary" @click="onNext">完成</el-button>
          <el-button @click="onNext">跳过</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script>
import { getUserToken } from "@/utils/auth";
import { toUnicode } from "@/utils/global";

export default {
  name: "register_step2",
  data() {
    return {
      user: {
        picture: ""
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
    this.uploadHeaders = {
      Authorization: getUserToken("user-token"),
      "Specified-User": this.$route.params.name
    };
  },
  methods: {
    onNext() {
      console.log("next");
      this.$router.push("/login");
    },
    onBeforeUpload(file) {
      console.log("upload file:", file.name);
      this.uploadHeaders["X-Test"] = "uploadfile_" + toUnicode(file.name);
    },
    onSuccessUpload(response, file, fileList) {
      console.log("upload file success");
      this.imgProps.url =
        process.env.VUE_APP_BASE_API + "/downloadpic/" + response.filename;
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

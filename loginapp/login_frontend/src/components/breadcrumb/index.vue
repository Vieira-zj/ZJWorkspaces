<template>
  <el-breadcrumb separator="/">
    <transition-group name="breadcrumb">
      <el-breadcrumb-item v-for="(item,index) in levelList"
                          :key="item.path">
        <span v-if="item.redirect==='noRedirect'||index==levelList.length-1"
              class="no-redirect">{{ item.meta.title }}</span>
        <a v-else
           @click.prevent="handleLink(item)">{{ item.meta.title }}</a>
      </el-breadcrumb-item>
    </transition-group>
  </el-breadcrumb>
</template>

<script>
import pathToRegexp from 'path-to-regexp'

export default {
  name: 'breadcrumb',
  data() {
    return {
      levelList: null,
    }
  },
  watch: {
    $route() {
      this.getBreadcrumb()
    },
  },
  mounted() {
    this.getBreadcrumb()
  },
  methods: {
    getBreadcrumb() {
      // $route.matched 包含当前路由的所有嵌套路径片段的路由记录
      this.levelList = this.$route.matched.filter(
        (item) => item.meta && item.meta.title && item.meta.breadcrumb !== false
      )

      console.log('route items:')
      this.levelList.forEach((item) => {
        console.log(item.meta.title)
      })
    },
    handleLink(item) {
      const { redirect, path } = item
      if (redirect) {
        this.$router.push(redirect)
        return
      }
      this.$router.push(this.pathCompile(path))
    },
    pathCompile(path) {
      const { params } = this.$route
      var toPath = pathToRegexp.compile(path)
      return toPath(params)
    },
  },
}
</script>

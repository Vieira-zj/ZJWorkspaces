# login_frontend

> login demo frontend base on Vue and ElementUI.

## Build Setup

```sh
# install dependencies
npm install

# serve with hot reload at localhost:8080
npm run dev

# build for production with minification
npm run build

# build for production and view the bundle analyzer report
npm run build --report
```

For a detailed explanation on how things work, check out the [guide](http://vuejs-templates.github.io/webpack/) and [docs for vue-loader](http://vuejs.github.io/vue-loader).

## project

Configs:

- build: compile and package configs by webpack for diff env.
- config/index.js: application global basic configs.
- config/dev.env.js: global env variables.
- index.html: webpack html entry point.
- src/main.js: vue app entry point.

Views:

- login.vue: 登录页
- register*: 新用户注册页
- user-edit.vue: 用户信息编辑页
- user-list.vue: 用户列表页

Src:

- api: 封装后端rest api接口
- router/index.js: 路由和路由aop逻辑
- utils/request.js: 封装axios api访问和请求aop逻辑

## issue

1. 路由监听使用 `watch '$route.path'` 或 router hook `beforeEach`

2. 页面刷新后，vuex中保存的数据丢失


# login-frontend

> A login demo frontend base on Vue and ElementUI.

## Project Setup

1. Craete project

```sh
vue create login_frontend
```

2. Update `package.json`, install dep modules and fix

```sh
npm install
npm audit fix --force
```

## Project Structure

Configs:

- `build`: compile and package configs by webpack for dev or prod env.
- `config/index.js`: webpack global basic configs.
- `config/dev.env.js`: app global env variables for dev.
- `index.html`: webpack html entry point.
- `src/main.js`: vue app entry point.

Views:

- `login.vue`: 登录页
- `register*.vue`: 新用户注册页
- `userEdit.vue`: 用户信息编辑页
- `userList.vue`: 用户列表页

Source:

- `api/*.js`: 封装后端rest api接口
- `router/index.js`: 路由和路由aop逻辑
- `utils/request.js`: 封装axios和请求aop逻辑

## Project Configs

1. `package.json` 中配置启动的文件

```json
{
  "dev": "webpack-dev-server --inline --progress --config build/webpack.dev.conf.js"
}
```

> Note: login project is packaged by webpack.

2. `build/webpack.base.conf.js` 为基础配置，被 `webpack.dev.conf.js` 和 `webpack.prod.conf.js` 引用

- `webpack.base.conf.js`

```js
{
  context: path.resolve(__dirname, '../'),
  entry: {
    app: './src/main.js'
  },
  output: {
    path: config.build.assetsRoot,
    filename: '[name].js',
    publicPath: process.env.NODE_ENV === 'production'
      ? config.build.assetsPublicPath
      : config.dev.assetsPublicPath
  },
  resolve: {
    extensions: ['.js', '.vue', '.json'],
    alias: {
      'vue$': 'vue/dist/vue.esm.js',
      '@': resolve('src'),
    }
  },
}
```

- `webpack.dev.conf.js`

```js
{
  new webpack.DefinePlugin({
    // process.env set by config
    'process.env': require('../config/dev.env')
  }),
  new HtmlWebpackPlugin({
    filename: 'index.html',
    template: 'index.html',
    inject: true
  }),
}
```

## Issues

1. 路由监听使用 `watch '$route.path'` 或 router hook `beforeEach`
2. 页面刷新后，vuex中保存的数据丢失


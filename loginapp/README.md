# Entry Task Login

## 需求

实现一个用户管理系统，用户可以注册、登录、拉取和编辑他们的profiles.

用户可以通过在Web页面输入username和password登录，backend系统负责校验用户身份。成功登录后，页面需要展示用户的相关信息；否则页面展示相关错误。

成功登录后，用户可以编辑以下内容：

- 上传profile picture
- 修改nickname（需要支持Unicode字符集，utf-8编码）

用户信息包括：

- username（不可更改）
- nickname
- profile picture
- issuperuser 

只允许superuser查看用户列表页，并且拥有查看、编辑所有用户的权限。

需要提前将初始用户数据插入数据库用于测试。确保测试数据库中包含100,000条用户账号信息。

## 设计要求

- 使用Vue进行前端开发
- 选用任意语言进行后端开发
- 用户账号信息必须存储在MySQL数据库
- 代码质量
- 性能

## 交付

- Git源代码
- 设计文档
- 部署、运维文档
- 现场演示

文档使用markdown编写并一同源代码提交至Git仓库。


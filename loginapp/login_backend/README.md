# login-backend

> login demo backend base on Flask and pymysql.

## DB

Create database and init users data in mysql.

```sql
-- create
SHOW DATABASES;
SHOW CREATE DATABASE test;

CREATE TABLE `users` (
  `id` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(32) NOT NULL COMMENT 'user name',
  `nickname` varchar(32) NOT NULL COMMENT 'user nickname',
  `password` varchar(128) NOT NULL COMMENT 'user password',
  `issuperuser` char(1) NOT NULL DEFAULT 'n' COMMENT 'is super user',
  `picture` varchar(128) NOT NULL DEFAULT ' ' COMMENT 'user profile picture address'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
SHOW CREATE TABLE users;

-- prepare data
INSERT INTO users (name, nickname, password, issuperuser) VALUES ('name01', 'nick01', 'test', 'n');
SELECT * FROM users;

-- clearup
UPDATE users SET picture = "";
DROP TABLE users;
```

## Project 目录

- app.py: api接口层
- services: 服务层
- models: 数据层，使用mysql数据库
- utils: 工具类

## API Specification

- `/`

test:

```sh
curl -v "http://127.0.0.1:12340/" | jq .
curl -v "http://localhost:12340/ping" -d '{"value":"text"}' -H "Content-Type: application/json" | jq .
```

response:

```json
{
  "code": "0",
  "status": "ok",
  "message": "",
  "count": "1"
}
```

- `/login`

test:

```sh
curl -v -XPOST "http://127.0.0.1:12340/login" -H "Content-Type: application/json" \
  -d '{"name": "name10", "password": "test10"}' | jq .
```

response (set cookie user-token):

```json
{
  "code": "0",
  "status": "ok",
  "message": "",
  "user": {
    "name": "name10",
    "issuperuser": "y"
  }
}
```

- `/getuser?name=name11`

test:

```sh
curl -v "http://127.0.0.1:12340/getuser?name=name11" -H "Authorization: bmFtZTEwfHRlc3QxMA==" | jq .
```

response:

```json
{
  "code": "0",
  "status": "ok",
  "message": "",
  "user": {
    "id": 11,
    "name": "name20",
    "nickname": "nick20",
    "password": "test20",
    "issuperuser": "y",
    "picture": " "
  }
}
```

- `/getusers`

test:

```sh
curl -v -XPOST "http://127.0.0.1:12340/getusers" -H "Authorization: bmFtZTEwfHRlc3QxMA==" \
  -H "Content-Type: application/json" -d '{"offset": "10", "limit": "5"}' | jq .
```

response:

```json
{
  "code": "0",
  "status": "ok",
  "message": "",
  "count": "20",
  "users": [
    {
      "name": "name20",
      "nickname": "nick20",
      "issuperuser": "y",
      "picture": " "
    }
  ]
}
```

- `/newuser`

test:

```sh
curl -v -XPOST "http://127.0.0.1:12340/newuser" \
  -H "Content-Type: application/json" -H "Authorization: bmFtZTEwfHRlc3QxMA==" \
  -d '{"name": "name19a", "nickname": "nick-19a", "issuperuser": "n", "password": "test12"}' | jq .
```

response:

```json
{
  "code": "0",
  "status": "ok",
  "message": "",
  "user": {
    "name": "name19a",
    "nickname": "nick-19a",
    "issuperuser": "n",
    "picture": " "
  }
}
```

- `/edituser`

test:

```sh
curl -v -XPOST "http://127.0.0.1:12340/edituser" \
  -H "Content-Type: application/json" -H "Authorization: bmFtZTEwfHRlc3QxMA==" \
  -d '{"name": "name11", "data": {"nickname": "new_nick11", "issuperuser": "n"}}' | jq .
```

response:

```json
{
  "code": "0",
  "status": "ok",
  "message": "",
  "user": {
    "name": "name11",
    "nickname": "new_nick11",
    "issuperuser": "n",
    "picture": ""
  }
}
```

- `/issuperuser`

test:

```sh
curl -v "http://127.0.0.1:12340/issuperuser" -H "Authorization: bmFtZTEwfHRlc3QxMA==" | jq .
```

response:

```json
{
  "code": "0",
  "status": "ok",
  "message": "",
  "user": {
    "name": "name10",
    "issuperuser": "y"
  }
}
```

- `/uploadpic?isauth=y`

test:

```sh
curl -v -XPOST -H "Authorization: bmFtZTEwfHRlc3QxMA==" -H "Specified-User: namex1" \
  -F "file=@./user01.jpeg" "http://localhost:12340/uploadpic?isauth=y" | jq .
```

response:

```json
{
  "code": "0",
  "status": "ok",
  "message": "upload file success",
  "filename": "6e03231d18c7.jpeg"
}
```

- `/downloadpic`

test:

```sh
curl -v "http://127.0.0.1:12340/downloadpic/user01.jpeg" -H "Authorization: bmFtZTEwfHRlc3QxMA==" -o "user01.jpeg"
```

response:

```text
HTTP/1.0 200 OK
```

## Todos

### 接口数据使用template.

- 请求数据：

```json
{
  "meta": {
  },
  "data": {
  }
}
```

- 返回数据：

```json
{
  "code:": 0,
  "status": "",
  "message": "",
  "meta": {
  },
  "data": {
  }
}
```


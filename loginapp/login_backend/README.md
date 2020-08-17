# login_backend

> login demo backend base on Flask and pymysql.

## db

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

## project

- app.py: api接口层
- service.py: 服务层
- data.py: 数据层，使用mysql数据库
- utils.py: 工具类

## apis specification

- `/`

test:

```sh
curl -v http://127.0.0.1:12340/
```

response:

```json
{
  "count": "3",
  "status": "ok"
}
```

- `/login`

test:

```sh
curl -v -XPOST "http://127.0.0.1:12340/login" -d '{"name": "name10", "password": "test10"}'
```

response (set cookie user-token):

```json
{
  "code": "0",
  "status": "ok",
  "msg": "",
  "issuperuser": "y"
}
```

- `/getuser`

test:

```sh
curl -v -XPOST "http://127.0.0.1:12340/getuser" -H "Authorization: bmFtZTEwfHRlc3QxMA==" -d '{"name": "name20"}'
```

response:

```json
{
  "code": "0",
  "status": "ok",
  "msg": "",
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
curl -v -XPOST "http://127.0.0.1:12340/getusers" -H "Authorization: bmFtZTEwfHRlc3QxMA==" -d '{"start": "10", "offset": "5"}'
```

response:

```json
{
  "code": "0",
  "status": "ok",
  "msg": "",
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
curl -v -XPOST "http://127.0.0.1:12340/newuser" -H "Authorization: bmFtZTEwfHRlc3QxMA==" -d \
  '{"name": "name34", "nickname": "nick34", "issuperuser": "n", "password": "test34"}'
```

response:

```json
{
  "code": "0",
  "status": "ok",
  "msg": ""
}
```

- `/edituser`

test:

```sh
curl -v -XPOST "http://127.0.0.1:12340/edituser" -H "Authorization: bmFtZTEwfHRlc3QxMA==" -d \
  '{"name": "name11", "data": {"nickname": "new_nick", "issuperuser": "n"'
```

response:

```json
{
  "code": "0",
  "status": "ok",
  "msg": ""
}
```

- `issuperuser`

test:

```sh
curl -v "http://127.0.0.1:12340/issuperuser" -H "Authorization: bmFtZTEwfHRlc3QxMA=="
```

response:

```json
{
  "code": "0",
  "status": "ok",
  "msg": "",
  "issuperuser": "y"
}
```

- `/uploadpic`

test:

```sh
curl -v -XPOST -H "Authorization: bmFtZTEwfHRlc3QxMA==" -H "Specified-User: namex1" \
  -F "file=@/tmp/user01.jpeg" "http://localhost:12340/uploadpic"
```

response:

```json
{
  "code": "0",
  "status": "ok",
  "msg": "upload file success",
  "filename": "6e03231d18c7.jpeg"
}
```

- `downloadpic`

test:

```sh
curl -v "http://127.0.0.1:12340/downloadpic/user01.jpeg" -H "Authorization: bmFtZTEwfHRlc3QxMA==" -o "user02.jpeg"
```

response:

```text
HTTP/1.0 200 OK
```

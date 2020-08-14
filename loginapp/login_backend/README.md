# login_backend

> login backend base on Flask.

## db mysql

Create database and init users data in mysql.

```sql
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

INSERT INTO users (name, nickname, password, issuperuser) VALUES ('name01', 'nick01', 'test', 'n');
SELECT * FROM users;

DROP TABLE users;
```


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
curl -v -X POST "http://127.0.0.1:12340/login" -d '{"name": "name10", "password": "test10"}'
```

response (set cookie user-token):

```json
{
  "code": "0",
  "status": "ok",
  "msg": "",
  "navigation": ""
}
```

- `/getuser`

test:

```sh
curl -v -X POST "http://127.0.0.1:12340/getuser" -H "Authorization: bmFtZTEwfHRlc3QxMA==" -d '{"name": "name20"}'
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
    "issuperuser": "y"
  }
}
```

- `/getusers`

test:

```sh
curl -v -X POST "http://127.0.0.1:12340/getusers" -H "Authorization: bmFtZTEwfHRlc3QxMA==" -d '{"start": "10", "offset": "5"}'
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

- `/edituser`

test:

```sh
curl -v -X POST "http://127.0.0.1:12340/edituser" -H "Authorization: bmFtZTEwfHRlc3QxMA==" -d \
  '{"name": "name11", "data": {"nickname": "new_nick", "issuperuser": "y", "picture": "/static/user01.jpeg"}}'
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

```

- `/uploadpic`

request:

```json
{
}
```

response:

```json
```

- `getpic`

request:

```json
{
}
```

response:

```json
```

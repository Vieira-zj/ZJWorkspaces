import logging
import pymysql
import os

logger = logging.getLogger(__name__)

db = pymysql.connect(
    host=os.getenv("MYSQL"),
    port=3306,
    user="root",
    password="example",
    database="test",
    charset="utf8",
)

cursor = db.cursor()


def init_insert_users(idx_start, idx_end):
    db_users_cols = ("name", "nickname", "password", "issuperuser")
    raw = (
        "INSERT INTO users (%s)" % ",".join(db_users_cols)
        + " VALUES ('name%s', 'nick%s', 'test%s', '%s');"
    )

    db.ping(reconnect=True)
    for i in range(idx_start, idx_end):
        if i % 10000 == 0:
            logger.debug("insert rows: " + str(i))
        sql = raw % (i, i, i, "n")
        try:
            cursor.execute(sql)
            db.commit()
        except:
            logger.error("users init failed, and rollback!")
            db.rollback()


def select_many_users(start=0, many=100):
    db_users_cols = ["name", "nickname", "issuperuser", "picture"]
    sql = "select %s from users" % ",".join(db_users_cols)
    db.ping(reconnect=True)
    cursor.execute(sql)
    cursor.scroll(start, mode="absolute")
    results = cursor.fetchmany(many)

    if results is None or len(results) == 0:
        return cursor.rowcount, list()

    ret = []
    for row in results:
        ret.append(dict(zip(db_users_cols, row)))
    return cursor.rowcount, ret


def select_user_by_name(user_name, is_include_password=False):
    sql = ""
    db_users_cols = []
    if is_include_password:
        db_users_cols = ("id", "name", "nickname", "password", "issuperuser", "picture")
        sql = "select * from users where name = '%s'" % (user_name)
    else:
        db_users_cols = ["name", "nickname", "issuperuser", "picture"]
        sql = "select %s from users where name = '%s'" % (
            ",".join(db_users_cols),
            user_name,
        )
    logger.debug(sql)

    db.ping(reconnect=True)
    cursor.execute(sql)
    results = cursor.fetchall()

    if results is None or len(results) == 0:
        return {}
    elif len(results) == 1:
        return dict(zip(db_users_cols, results[0]))
    else:
        raise Exception(f"Error: dulplicated records for name:{user_name}")


def insert_new_user(fields_dict):
    user = select_user_by_name(fields_dict["name"])
    if len(user) != 0:
        raise Exception("user:[%s] is exsit!" % fields_dict["name"])

    keys = ",".join(fields_dict.keys())
    values = ",".join(["'%s'" % v for v in fields_dict.values()])
    sql = "insert into users (%s) values (%s)" % (keys, values)
    logger.debug(sql)

    try:
        db.ping(reconnect=True)
        cursor.execute(sql)
        db.commit()
    except Exception as err:
        logger.error(err)
        logger.error("insert failed, and rollback!")
        db.rollback()
        raise err


def update_user_by_name(user_name, fields):
    user = select_user_by_name(user_name)
    if len(user) <= 0:
        raise Exception("user:[%s] is not exist!" % user_name)

    kv_list = [f"{k}='{v}'" for k, v in fields.items()]
    sql = "update users set %s where name = '%s'" % (",".join(kv_list), user_name)
    logger.debug(sql)

    try:
        db.ping(reconnect=True)
        cursor.execute(sql)
        db.commit()
    except Exception as err:
        logger.error(err)
        logger.error("update failed, and rollback!")
        db.rollback()
        raise err


def db_clearup():
    if cursor:
        cursor.close()
    if db:
        db.close()


if __name__ == "__main__":

    init_insert_users(1000, 100 * 1000)

    # count, results = select_many_users(10, 5)
    # print("row count:", count)
    # for row in results:
    #     print(row)

    # print(select_user_by_name("name11", is_include_password=True))

    # user = {"name": "name30", "nickname": "nick30", "password": "test30"}
    # insert_new_user(user)

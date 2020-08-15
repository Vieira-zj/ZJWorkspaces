import logging
import pymysql

logger = logging.getLogger(__name__)

db = pymysql.connect(
    host="localhost",
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
        "INSERT INTO users (%s)" % ",".join(db_users_cols[1:-1])
        + " VALUES ('name%s', 'nick%s', 'test%s', '%s');"
    )

    db.ping(reconnect=True)
    for i in range(idx_start, idx_end):
        sql = raw % (i, i, i, "n")
        try:
            cursor.execute(sql)
            db.commit()
        except:
            logger.error("insert failed, and rollback!")
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


def update_user_by_name(user_name, fields):
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


def db_clearup():
    cursor.close()
    db.close()


if __name__ == "__main__":

    # init_insert_users(20, 30)

    count, results = select_many_users(10, 5)
    print("row count:", count)
    for row in results:
        print(row)

    print(select_user_by_name("name11", is_include_password=True))

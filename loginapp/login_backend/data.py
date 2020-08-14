import pymysql

db = pymysql.connect(
    host="localhost",
    port=3306,
    user="root",
    password="example",
    database="test",
    charset="utf8",
)

cursor = db.cursor()

db_users_cols = ("id", "name", "nickname", "password", "issuperuser")


def init_insert_users(idx_start, idx_end):
    raw = (
        "INSERT INTO users (%s)" % ",".join(db_users_cols[1:])
        + " VALUES ('name%s', 'nick%s', 'test%s', '%s');"
    )
    for i in range(idx_start, idx_end):
        sql = raw % (i, i, i, "n")
        try:
            cursor.execute(sql)
            db.commit()
        except:
            print("insert failed, and rollback!")
            db.rollback()


def select_all_users(limit=30):
    sql = f"select * from users limit {limit}"
    cursor.execute(sql)
    results = cursor.fetchall()
    return tuple() if results is None or len(results) == 0 else results


def select_user_by_name(user_name):
    sql = "select * from users where name = '%s'" % (user_name)
    cursor.execute(sql)
    results = cursor.fetchall()
    # print(results)

    if results is None or len(results) == 0:
        return {}
    elif len(results) == 1:
        return dict(zip(db_users_cols, results[0]))
    else:
        raise Exception(f"Error: dulplicated records for name:{user_name}")


def update_user_by_name(user_name, fields):
    kv_list = [f"{k}='{v}'" for k, v in fields.items()]
    sql = "update users set %s where name = '%s'" % (",".join(kv_list), user_name)
    # print(sql)
    try:
        cursor.execute(sql)
        db.commit()
    except:
        print("update failed, and rollback!")
        db.rollback()


def db_clearup():
    cursor.close()
    db.close()


if __name__ == "__main__":

    # init_insert_users(20, 30)

    results = select_all_users()
    for row in results:
        print(row)

    print(select_user_by_name("name11"))

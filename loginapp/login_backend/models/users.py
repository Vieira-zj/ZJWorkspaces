# coding: utf-8
import os, sys
import logging
import pymysql

project_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(project_path)
from utils import DBUtils

logger = logging.getLogger(__name__)


class Users(object):
    """
    db:test table:users
    """

    def __init__(self):
        self._db = DBUtils.getDBConnection()
        self._cursor = DBUtils.getDBCursor()

        self.cols = {
            "id": "id",
            "name": "name",
            "nickname": "nickname",
            "password": "password",
            "issuperuser": "issuperuser",
            "picture": "picture",
        }

    def initInsertUsers(self, idx_start, idx_end):
        db_users_cols = (
            self.cols["name"],
            self.cols["nickname"],
            self.cols["password"],
            self.cols["issuperuser"],
        )
        raw = (
            "INSERT INTO users (%s)" % ",".join(db_users_cols)
            + " VALUES ('name%s', 'nick%s', 'test%s', '%s');"
        )

        self._db.ping(reconnect=True)
        for i in range(idx_start, idx_end):
            if i % 10000 == 0:
                logger.debug("insert rows: " + str(i))
            sql = raw % (i, i, i, "n")
            try:
                self._cursor.execute(sql)
                self._db.commit()
            except:
                logger.error("users init failed, and rollback!")
                self._db.rollback()

    def selectMultipleUsers(self, start=0, many=100):
        db_users_cols = (
            self.cols["name"],
            self.cols["nickname"],
            self.cols["issuperuser"],
            self.cols["picture"],
        )
        sql = "select %s from users" % ",".join(db_users_cols)
        self._db.ping(reconnect=True)
        self._cursor.execute(sql)
        self._cursor.scroll(start, mode="absolute")
        results = self._cursor.fetchmany(many)

        if results is None or len(results) == 0:
            return self._cursor.rowcount, list()

        ret = []
        for row in results:
            ret.append(dict(zip(db_users_cols, row)))
        return self._cursor.rowcount, ret

    def selectOneUserByName(self, user_name, is_include_password=False):
        db_users_cols = ["name", "nickname", "issuperuser", "picture"]
        if is_include_password:
            db_users_cols.append(self.cols["password"])
        sql = "select %s from users where name = '%s'" % (
            ",".join(db_users_cols),
            user_name,
        )
        logger.debug(sql)

        self._db.ping(reconnect=True)
        self._cursor.execute(sql)
        results = self._cursor.fetchall()

        if results is None or len(results) == 0:
            return {}
        elif len(results) == 1:
            return dict(zip(db_users_cols, results[0]))
        else:
            raise Exception(f"Error: dulplicated records for name:{user_name}")

    def insertANewUser(self, fields_dict):
        user = self.selectOneUserByName(fields_dict[self.cols["name"]])
        if len(user) != 0:
            raise Exception("user:[%s] is exsit!" % fields_dict[self.cols["name"]])

        keys = ",".join(fields_dict.keys())
        values = ",".join(["'%s'" % v for v in fields_dict.values()])
        sql = "insert into users (%s) values (%s)" % (keys, values)
        logger.debug(sql)

        try:
            self._db.ping(reconnect=True)
            self._cursor.execute(sql)
            self._db.commit()
        except Exception as err:
            logger.error(err)
            logger.error("insert failed, and rollback!")
            self._db.rollback()
            raise err

    def updateUserByName(self, user_name, fields):
        user = self.selectOneUserByName(user_name)
        if len(user) <= 0:
            raise Exception("user:[%s] is not exist!" % user_name)

        kv_list = [f"{k}='{v}'" for k, v in fields.items()]
        sql = "update users set %s where name = '%s'" % (",".join(kv_list), user_name)
        logger.debug(sql)

        try:
            self._db.ping(reconnect=True)
            self._cursor.execute(sql)
            self._db.commit()
        except Exception as err:
            logger.error(err)
            logger.error("update failed, and rollback!")
            self._db.rollback()
            raise err


if __name__ == "__main__":

    users = Users()
    # users.initInsertUsers(1000, 100 * 1000)

    # count, results = users.selectMultipleUsers(10, 5)
    # print("row count:", count)
    # for row in results:
    #     print(row)

    print(users.selectOneUserByName("name11", is_include_password=True))

    # user = {"name": "name30", "nickname": "nick30", "password": "test30"}
    # users.insertANewUser(user)
    DBUtils.closeDBConnection()

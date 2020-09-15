# coding: utf-8
import os
import pymysql


class DBUtils(object):
    """
    mysql connections.
    """

    _db = pymysql.connect(
        host=os.getenv("MYSQL"),
        port=13306,
        user="root",
        password="example",
        database="test",
        charset="utf8",
    )
    _cursor = _db.cursor()

    @classmethod
    def getDBConnection(cls):
        return cls._db

    @classmethod
    def getDBCursor(cls):
        return cls._cursor

    @classmethod
    def closeDBConnection(cls):
        if cls._cursor:
            cls._cursor.close()
        if cls._db:
            cls._db.close()

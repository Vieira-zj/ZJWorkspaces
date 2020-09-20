# coding: utf-8
import os
import logging
import pymysql

logger = logging.getLogger(__name__)

is_product = os.getenv("FLASK_ENV") == "prod"
mysql_host = "db" if is_product else "localhost"
mysql_port = 3306 if is_product else 13306


class DBUtils(object):
    """
    mysql connections.
    """

    _db = pymysql.connect(
        host=mysql_host,
        port=mysql_port,
        user="root",
        password="example",
        database="test",
        charset="utf8",
    )
    _cursor = _db.cursor()

    @classmethod
    def getDBConnection(cls):
        logger.info("connect to mysql: [%s:%d]" % (mysql_host, mysql_port))
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

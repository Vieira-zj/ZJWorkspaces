import logging
import pytest

from apis import AppAPI, DataSourceAPI
from utils import Config, HttpConnection, TestData

logging.getLogger('faker').setLevel(logging.ERROR)


class TestContext(object):

    def __new__(cls, *args, **kwargs):
        if not hasattr(cls, '_instance'):
            setattr(cls, '_instance', super(TestContext, cls).__new__(cls))
        return getattr(cls, '_instance')

    def __init__(self, http: HttpConnection):
        self._cfg = Config()
        self._http = http

        self._app_name = 'api-auto-test-app'
        self._app_id = 0
        self._app_api = AppAPI(self._http)

        self._ds_name = 'api-auto-test-datasource'
        self._ds_id = 0
        self._ds_review_email = self._cfg.env_config.email
        self._ds_api = DataSourceAPI(self._http)

    @property
    def http(self):
        return self._http

    @property
    def app_name(self):
        return self._app_name

    @property
    def app_id(self):
        return self._app_id

    @property
    def datasource_name(self):
        return self._ds_name

    @property
    def datasource_id(self):
        return self._ds_id

    def create_app(self):
        self._app_id = self._app_api.create_app_and_return_id(
            self._app_name, 'This is a app used by auto api test.')

    def delete_app(self):
        self._app_api.delete_app(self._app_id)

    def create_datasource(self):
        db_cfg = self._cfg.env_config.db
        data_dict = {
            'appId': self._app_id,
            'appName': self._app_name,
            'name': self._ds_name,
            'ip': db_cfg['db_host'],
            'port': db_cfg['db_port'],
            'userName': db_cfg['db_user'],
            'password': db_cfg['db_password'],
            'datasourceType': 1,
            'description': 'This is a datasource used by auto api test.',
            'techReviewer': [self._ds_review_email],
            'productReviewer': [self._ds_review_email],
        }
        resp_json = self._ds_api.create_datasource(data_dict)
        assert resp_json['statusCode'] == 0

        self._ds_id = self._ds_api.get_datasource_id_by_appid_name(
            self.app_id, self._ds_name)

    def delete_datasource(self):
        self._ds_api.delete_datasource(self._ds_id)


class TestBase(object):

    _cfg = Config()
    _http_conn = HttpConnection(access_token=_cfg.env_config.access_token)
    _ctx = TestContext(_http_conn)

    # Note: test data load process cannot be in session setup fixture,
    # because @pytest.mark.parametrize() is out of pytest lifecycle.
    TestData.load_data(_cfg.env_config.sheet_id, _cfg.env_config.range_name)

    def __del__(self):
        self._http_conn.close()

    def assert_status_code_ok(self, resp_json, code=0):
        assert resp_json['statusCode'] == code

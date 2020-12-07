import allure
import logging
import pytest
from tests import TestBase

from apis import ListAPI, DataSourceAPI
from tools import meta, MetaData
from utils import HttpConnection

logger = logging.getLogger(__name__)
suite_name = 'TestListSuite'


class TestList(TestBase):

    @classmethod
    def setup_class(cls):
        cls._http = HttpConnection(
            access_token=cls._cfg.env_config.access_token)
        cls._list_api = ListAPI(cls._http)
        cls._ds_api = DataSourceAPI(cls._http)

        cls._db_name = 'credit_db_portal_db'
        cls._tb_name = 'user_tab'

    @classmethod
    def teardown_class(cls):
        cls._http.close()

    @allure.suite(suite_name)
    @pytest.mark.smoke
    @pytest.mark.run(order=61)
    @meta(MetaData('zhengjin', '2020-12-7', ['smoke', 'manage/data']))
    def test_datasource_manage_data(self):
        data_dict = {
            'appId': self._ctx.app_id,
            'appName': self._ctx.app_name,
            'datasourceId': self._ctx.datasource_id,
            'datasourceName': self._ctx.datasource_name,
            'deletedRules': [],
            'updatedRules': [],
            'deletedTableIds': [],
            'updatedTableGroups': [{
                'databaseId': 0,
                'databaseName': self._db_name,
                'tableNames': [self._tb_name]}
            ]
        }
        resp_json = self._ds_api.datasource_manage_data(data_dict)
        self.assert_status_code_ok(resp_json)
        assert 'success' in resp_json['data']

    @allure.suite(suite_name)
    @pytest.mark.smoke
    @meta(MetaData('zhengjin', '2020-12-7', ['smoke', 'list/database']))
    @pytest.mark.run(order=63)
    def test_list_database(self):
        resp_json = self._list_api.list_database(self._ctx.datasource_id)
        self.assert_status_code_ok(resp_json)

        dbs = resp_json['data']['databases']
        assert len(dbs) == 1
        assert dbs[0]['name'] == self._db_name

    @allure.suite(suite_name)
    @pytest.mark.smoke
    @meta(MetaData('zhengjin', '2020-12-7', ['smoke', 'list/database']))
    @pytest.mark.run(order=65)
    def test_list_table(self):
        db_id = self._list_api.get_first_db_id_from_list_database(
            self._ctx.datasource_id)
        resp_json = self._list_api.list_table(db_id)
        self.assert_status_code_ok(resp_json)

        tbs = resp_json['data']['allTables']
        assert len(tbs) == 1
        assert tbs[0]['name'] == 'user_tab'

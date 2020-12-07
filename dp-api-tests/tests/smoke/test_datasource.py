import allure
import logging
import pytest

from apis import AppAPI, DataSourceAPI
from tests import TestBase
from utils import HttpConnection
from tools import meta, MetaData

logger = logging.getLogger(__name__)
suite_name_datasource = 'TestDataSourceSuite'
suite_name_datasource_manage = 'TestDataSourceManageSuite'


@pytest.mark.usefixtures('datasource_context_setup_teardown')
class TestDataSource(TestBase):

    @classmethod
    def setup_class(cls):
        cls._http = HttpConnection(
            access_token=cls._cfg.env_config.access_token)

        cls._app_name = cls._ctx.app_name
        cls._app_id = cls._ctx.app_id

        cls._ds_name = 'api-auto-test-datasource-tmp'
        cls._ds_review_email = cls._cfg.env_config.email
        cls._ds_api = DataSourceAPI(cls._http)

    @classmethod
    def teardown_class(cls):
        cls._http.close()

    @allure.suite(suite_name_datasource)
    @pytest.mark.smoke
    @pytest.mark.run(order=21)
    @meta(MetaData('zhengjin', '2020-12-7', ['smoke', 'datasource/create']))
    def test_create_datasource(self):
        data_dict = self._get_create_datasource_dict()
        resp_json = self._ds_api.create_datasource(data_dict)
        self.assert_status_code_ok(resp_json)
        assert resp_json['data'] == 'success'

    @allure.suite(suite_name_datasource)
    @pytest.mark.smoke
    @pytest.mark.run(order=23)
    @meta(MetaData('zhengjin', '2020-12-7', ['smoke', 'datasource/get']))
    def test_get_datasource(self):
        data_dict = self._get_query_datasource_dict()
        resp_json = self._ds_api.get_datasource(data_dict)
        self.assert_status_code_ok(resp_json)

        assert resp_json['data']['total'] == 1
        assert resp_json['data']['items'][0]['name'] == self._ds_name

    @allure.suite(suite_name_datasource)
    @pytest.mark.skip(reason='this api is unused.')
    @pytest.mark.run(order=25)
    @meta(MetaData('zhengjin', '2020-12-7', ['smoke', 'datasource/admin/get']))
    def test_get_datasource_admin(self):
        data_dict = self._get_query_datasource_dict()
        resp_json = self._ds_api.get_datasource_admin(data_dict)
        self.assert_status_code_ok(resp_json)

        assert resp_json['data']['total'] == 1
        assert resp_json['data']['items'][0]['name'] == self._ds_name

    @allure.suite(suite_name_datasource)
    @pytest.mark.smoke
    @pytest.mark.run(order=27)
    @meta(MetaData('zhengjin', '2020-12-7', ['smoke', 'datasource/mini-get']))
    def test_get_datasource_mini_list(self):
        resp_json = self._ds_api.get_datasource_mini_list(self._app_id)
        self.assert_status_code_ok(resp_json)
        assert len(resp_json['data']['dataSources']) > 0

    @allure.suite(suite_name_datasource)
    @pytest.mark.smoke
    @pytest.mark.run(order=29)
    @meta(MetaData('zhengjin', '2020-12-7', ['smoke', 'datasource/get']))
    def test_get_datasource_by_id(self):
        dsId = self._get_created_datasource_id()
        resp_json = self._ds_api.get_datasource_by_id(dsId)
        self.assert_status_code_ok(resp_json)
        assert resp_json['data']['name'] == self._ds_name

    @allure.suite(suite_name_datasource)
    @pytest.mark.smoke
    @pytest.mark.run(order=31)
    @meta(MetaData('zhengjin', '2020-12-7', ['smoke', 'datasource/update']))
    def test_update_datasource(self):
        ds_id = self._get_created_datasource_id()
        new_desc = 'This is a datasource used by auto api test. New'
        data_dict = self._get_create_datasource_dict()
        data_dict['id'] = ds_id
        data_dict['description'] = new_desc
        data_dict['status'] = 1
        resp_json = self._ds_api.update_datasource(data_dict)
        self.assert_status_code_ok(resp_json)

    @allure.suite(suite_name_datasource_manage)
    @pytest.mark.smoke
    @pytest.mark.run(order=40)
    @meta(MetaData('zhengjin', '2020-12-7', ['smoke', 'datasource/manage/connect']))
    def test_datasource_connection(self):
        db_cfg = self._cfg.env_config.db
        data_dict = {
            'ip': db_cfg['db_host'],
            'port': db_cfg['db_port'],
            'userName': db_cfg['db_user'],
            'password': db_cfg['db_password'],
        }
        resp_json = self._ds_api.datasource_connection(data_dict)
        self.assert_status_code_ok(resp_json)
        assert len(resp_json['data']['databases']) > 0

    @allure.suite(suite_name_datasource_manage)
    @pytest.mark.smoke
    @pytest.mark.run(order=42)
    @meta(MetaData('zhengjin', '2020-12-7', ['smoke', 'datasource/manage/get-db']))
    def test_get_datasource_databases_by_id(self):
        ds_id = self._get_created_datasource_id()
        resp_json = self._ds_api.get_datasource_databases_by_id(ds_id)
        self.assert_status_code_ok(resp_json)
        assert len(resp_json['data']) > 0

    @allure.suite(suite_name_datasource_manage)
    @pytest.mark.smoke
    @pytest.mark.run(order=44)
    @meta(MetaData('zhengjin', '2020-12-7', ['smoke', 'datasource/manage/get-db-info']))
    def test_get_datasource_database_info(self):
        ds_id = self._get_created_datasource_id()
        db_name = self._ds_api.get_datasource_first_db_by_id(ds_id)
        data_dict = {
            'datasourceId': ds_id,
            'databases': [db_name]
        }
        resp_json = self._ds_api.get_datasource_database_info(data_dict)
        self.assert_status_code_ok(resp_json)
        assert len(resp_json['data']['tables']) == 1

        db = resp_json['data']['tables'][0]
        assert db['name'] == db_name
        assert len(db['tables']) > 0

    @allure.suite(suite_name_datasource_manage)
    @pytest.mark.smoke
    @pytest.mark.run(order=46)
    @meta(MetaData('zhengjin', '2020-12-7', ['smoke', 'datasource/manage/get-tb']))
    def test_get_datasource_table_columns(self):
        ds_id = self._get_created_datasource_id()
        db_name = self._ds_api.get_datasource_first_db_by_id(ds_id)
        tb_name = self._ds_api.get_datasource_first_table_by_id(ds_id, db_name)
        data_dict = {
            'datasourceId': ds_id,
            'database': db_name,
            'tables': [tb_name]
        }
        resp_json = self._ds_api.get_datasource_table_columns(data_dict)
        self.assert_status_code_ok(resp_json)
        assert len(resp_json['data']) == 1

        tb = resp_json['data'][0]
        assert tb['name'] == tb_name
        assert len(tb['columns']) > 0

    @allure.suite(suite_name_datasource_manage)
    @pytest.mark.smoke
    @pytest.mark.run(order=48)
    @meta(MetaData('zhengjin', '2020-12-7', ['smoke', 'datasource/delete']))
    def test_delete_datasource(self):
        ds_id = self._get_created_datasource_id()
        resp_json = self._ds_api.delete_datasource(ds_id)
        self.assert_status_code_ok(resp_json)

    def _get_created_datasource_id(self):
        return self._ds_api.get_datasource_id_by_appid_name(self._app_id, self._ds_name)

    def _get_query_datasource_dict(self):
        data_dict = {
            'appId': self._app_id,
            'name': self._ds_name,
            'page': 1,
            'pageSize': 10,
            'status': 1
        }
        return data_dict

    def _get_create_datasource_dict(self):
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
        return data_dict

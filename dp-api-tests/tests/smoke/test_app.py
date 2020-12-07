import allure
import logging
import pytest

from apis import AppAPI
from tests import TestBase
from utils import common, HttpConnection
from tools import meta, MetaData

logger = logging.getLogger(__name__)
suite_name = 'TestAppSuite'


class TestApp(TestBase):

    @classmethod
    def setup_class(cls):
        cls._http = HttpConnection(
            access_token=cls._cfg.env_config.access_token)
        cls._app_api = AppAPI(cls._http)
        cls._app_name = 'api-auto-test-app-tmp'

    @classmethod
    def teardown_class(cls):
        cls._http.close()

    @allure.suite(suite_name)
    @allure.severity(allure.severity_level.NORMAL)
    @pytest.mark.run(order=10)
    @pytest.mark.smoke
    @meta(MetaData('zhengjin', '2020-12-4', ['smoke', 'app/create app']))
    def test_create_app(self):
        data_dict = {
            'name': self._app_name,
            'description': 'This is a app used by auto api test.'
        }
        resp = self._app_api.create_app(data_dict)
        self.assert_status_code_ok(resp)

        assert resp['data']['name'] == self._app_name
        assert resp['data']['id'] > 0

    @allure.suite(suite_name)
    @allure.severity(allure.severity_level.NORMAL)
    @pytest.mark.run(order=12)
    @pytest.mark.smoke
    @meta(MetaData('zhengjin', '2020-12-4', ['smoke', 'app/get_app']))
    def test_get_app(self):
        data_dict = {
            'page': 1,
            'pageSize': 10,
            'name': self._app_name
        }
        resp = self._app_api.get_app(data_dict)
        self.assert_status_code_ok(resp)

        assert resp['data']['total'] == 1
        dp_app = resp['data']['items'][0]
        assert dp_app['name'] == self._app_name
        logger.debug("get app id: %d, desc: %s" %
                     (dp_app['id'], dp_app['description']))

    @allure.suite(suite_name)
    @allure.severity(allure.severity_level.NORMAL)
    @pytest.mark.run(order=14)
    @pytest.mark.smoke
    @meta(MetaData('zhengjin', '2020-12-4', ['smoke', 'app/get_app']))
    def test_get_app_by_id(self):
        id = self._app_api.get_app_id_by_name(self._app_name)
        resp = self._app_api.get_app_by_id(id)
        self.assert_status_code_ok(resp)

        assert resp['data']['name'] == self._app_name
        assert resp['data']['id'] == id

    @allure.suite(suite_name)
    @allure.severity(allure.severity_level.NORMAL)
    @pytest.mark.run(order=16)
    @pytest.mark.smoke
    @meta(MetaData('zhengjin', '2020-12-4', ['smoke', 'app/get_apps']))
    def test_get_all_apps(self):
        resp = self._app_api.get_all_apps()
        self.assert_status_code_ok(resp)
        assert len(resp['data']['apps']) > 0

    @allure.suite(suite_name)
    @allure.severity(allure.severity_level.NORMAL)
    @pytest.mark.run(order=18)
    @pytest.mark.smoke
    @meta(MetaData('zhengjin', '2020-12-4', ['smoke', 'app/update_app']))
    def test_update_app(self):
        id = self._app_api.get_app_id_by_name(self._app_name)
        desc = 'This is a app used by auto api test. New.'
        data_dict = {
            'id': id,
            'name': self._app_name,
            'description': desc
        }
        resp = self._app_api.update_app(data_dict)
        self.assert_status_code_ok(resp)

        assert resp['data']['name'] == self._app_name
        assert resp['data']['description'] == desc

    @allure.suite(suite_name)
    @allure.severity(allure.severity_level.NORMAL)
    @pytest.mark.run(order=20)
    @pytest.mark.smoke
    @meta(MetaData('zhengjin', '2020-12-4', ['smoke', 'app/delete_app']))
    def test_delete_app(self):
        id = self._app_api.get_app_id_by_name(self._app_name)
        resp = self._app_api.delete_app(id)
        self.assert_status_code_ok(resp)
        assert resp['data']['affected'] == 1

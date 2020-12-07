import allure
import logging
import pytest

from apis import UserAPI
from tests import TestBase
from utils import HttpConnection
from tools import meta, MetaData


logger = logging.getLogger(__name__)
suite_name = 'TestUserSuite'


class TestUser(TestBase):

    @classmethod
    def setup_class(cls):
        # cls._http = HttpConnection(access_token=auth.get_login_token())
        cls._http = HttpConnection(
            access_token=cls._cfg.env_config.access_token)
        cls._user_api = UserAPI(cls._http)
        cls._email = cls._cfg.env_config.email

    @classmethod
    def teardown_class(cls):
        cls._http.close()

    @allure.suite(suite_name)
    @allure.severity(allure.severity_level.NORMAL)
    @pytest.mark.smoke
    @meta(MetaData('zhengjin', '2020-12-5', ['smoke', 'user/list_users']))
    def test_user_list_all(self):
        data_dict = {'pageSize': 10, 'page': 1}
        resp_json = self._user_api.user_list(data_dict)
        self.assert_status_code_ok(resp_json)

        total = resp_json['data']['total']
        logger.debug(f"total users retrieved: {total}")
        assert total >= 0

        if total > 0:
            assert len(resp_json['data']['items']) > 0

    @allure.suite(suite_name)
    @allure.severity(allure.severity_level.NORMAL)
    @pytest.mark.smoke
    @meta(MetaData('zhengjin', '2020-12-5', ['smoke', 'user/list_user']))
    def test_user_list_by_email(self):
        data_dict = {'pageSize': 10, 'page': 1, 'email': self._email}
        resp_json = self._user_api.user_list(data_dict)
        self.assert_status_code_ok(resp_json)

        total = resp_json['data']['total']
        assert total == 1
        assert len(resp_json['data']['items']) == 1
        assert resp_json['data']['items'][0]['email'] == self._email

    @allure.suite(suite_name)
    @allure.severity(allure.severity_level.NORMAL)
    @pytest.mark.smoke
    @meta(MetaData('zhengjin', '2020-12-5', ['smoke', 'user/download_user']))
    def test_user_download_by_email(self):
        data_dict = {'pageSize': 10, 'page': 1, 'email': self._email}
        resp_content = self._user_api.user_download(data_dict)
        assert len(resp_content) > 0
        assert self._email in resp_content

    @allure.suite(suite_name)
    @allure.severity(allure.severity_level.NORMAL)
    @pytest.mark.smoke
    @meta(MetaData('zhengjin', '2020-12-5', ['smoke', 'user/unfrozen_user']))
    def test_user_unfrozen(self):
        user_id = self._user_api.get_user_id_by_email(self._email)
        data_dict = {'isFrozen': False, 'userIds': [user_id]}
        resp_json = self._user_api.user_frozen(data_dict)
        self.assert_status_code_ok(resp_json)
        assert len(resp_json['data']) == 1
        assert resp_json['data'][0]['id'] == user_id

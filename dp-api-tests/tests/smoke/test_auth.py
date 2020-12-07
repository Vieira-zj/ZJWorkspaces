import allure
import logging
import requests
import pytest

from apis import DefaultAPI, AuthAPI
from utils import Config, HttpConnection
from tests import TestBase
from tools import meta, MetaData

logger = logging.getLogger(__name__)
cfg = Config()
suite_name = 'TestAuthSuite'


class TestAuth(TestBase):

    @classmethod
    def setup_class(cls):
        logger.debug('setup_class')
        cls._http = HttpConnection()
        cls._default_api = DefaultAPI(cls._http)
        cls._auth_api = AuthAPI()

    @classmethod
    def teardown_class(cls):
        logger.debug('teardown_class')
        cls._http.close()

    @allure.suite(suite_name)
    @allure.severity(allure.severity_level.CRITICAL)
    @pytest.mark.skip(reason='this api is unused.')
    @pytest.mark.flaky(reruns=2, reruns_delay=1)
    @pytest.mark.timeout(cfg.case_timeout)
    @meta(MetaData('zhengjin', '2020-12-3', ['skip', 'health-check', 'unused']))
    def test_get_default(self):
        assert self._default_api.get_default()

    @allure.suite(suite_name)
    @allure.severity(allure.severity_level.BLOCKER)
    @pytest.mark.smoke
    @pytest.mark.skip(reason='todo: auto google login.')
    @meta(MetaData('zhengjin', '2020-12-3', ['skip', 'auth/login', 'pending']))
    def test_auth(self):
        resp_json = self._auth_api.login()
        self.assert_status_code_ok(resp_json)
        assert len(resp_json['data']['accessToken']) > 16

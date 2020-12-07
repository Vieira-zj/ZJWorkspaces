import allure
import logging
import pytest

from apis import LogAPI
from tests import TestBase
from utils import HttpConnection, common
from tools import meta, MetaData

logger = logging.getLogger(__name__)
suite_name = 'TestLogSuite'


class TestLog(TestBase):

    @classmethod
    def setup_class(cls):
        # cls._http = HttpConnection(access_token=auth.get_login_token())
        cls._http = HttpConnection(
            access_token=cls._cfg.env_config.access_token)
        cls._log_api = LogAPI(cls._http)

    @classmethod
    def teardown_class(cls):
        cls._http.close()

    @allure.suite(suite_name)
    @allure.severity(allure.severity_level.NORMAL)
    @pytest.mark.smoke
    @meta(MetaData('zhengjin', '2020-12-4', ['smoke', 'log/get_log']))
    def test_get_log(self):
        data_dict = {'pageSize': 10,
                     'page': 1,
                     'startTime': common.get_lastday_timestamp(),
                     'endTime': common.get_current_timestamp()}
        resp_json = self._log_api.get_log(data_dict)
        self.assert_status_code_ok(resp_json)

        total = resp_json['data']['total']
        logger.debug(f"total logs retrieved: {total}")
        assert total >= 0
        if total > 0:
            assert len(resp_json['data']['items']) > 0

    @allure.suite(suite_name)
    @allure.severity(allure.severity_level.BLOCKER)
    @pytest.mark.smoke
    @pytest.mark.skip(reason='this api is developing.')
    @meta(MetaData('zhengjin', '2020-12-4', ['smoke', 'log/log_download', 'not impl']))
    def test_log_download(self):
        data_dict = {'pageSize': 10,
                     'page': 1,
                     'startTime': common.get_lastday_timestamp(),
                     'endTime': common.get_current_timestamp()}
        resp_content = self._log_api.log_download(data_dict)
        logger.debug(resp_content)

import allure
import json
import logging
import pytest

from tests.base import TestBase
from tools import meta, MetaData
from utils import Config, TestData

logger = logging.getLogger(__name__)
cfg = Config()
suite_name = 'hello_world_suite'


class TestHello(TestBase):

    @classmethod
    def setup_class(cls):
        logger.debug('setup_class')

    @classmethod
    def teardown_class(cls):
        logger.debug('teardown_class')

    def setup_method(self, method):
        logger.debug('setup_method')
        test_name = '%s::%s' % (self.__class__.__name__, method.__name__)
        logger.debug('run test case: ' + test_name)

    def teardown_method(self, method):
        logger.debug('teardown_method')

    @allure.story('test story')
    @allure.feature('hello world feature')
    @allure.suite(suite_name)
    @allure.severity(allure.severity_level.NORMAL)
    @allure.testcase('http://my.tms.org/TESTCASE-1')
    @meta(MetaData('zhengjin', '2020-12-3', ['test', 'hello']))
    def test_hello_world(self):
        assert True, 'pytest hello world test.'

    @allure.suite(suite_name)
    @allure.severity(allure.severity_level.CRITICAL)
    @allure.issue('http://jira.lan/browse/ISSUE-1')
    @meta(MetaData('zhengjin', '2020-12-3', ['test', 'foo']))
    def test_foo(self):
        with allure.step('step1: foo'):
            assert True, 'foo step1 check'
        with allure.step('step2: foo'):
            assert True, 'foo step2 check'

    """
    Test Data for test_params():
    https://docs.google.com/spreadsheets/d/1tSfLMHEh9LO5ZtKBq-3iSkBkCVHE-do0ERZ-iDlA8Cw/edit#gid=1756463693

                      name dataname                      item1                      item2                      item3
    0  TestHello::test_bar    data1  {"id": 1, "data": "bar1"}  {"id": 2, "data": "bar2"}  {"id": 3, "data": "bar3"}
    1  TestHello::test_bar    data2                       bar1                       bar2                       bar3
    2  TestHello::test_foo    data1  {"id": 1, "data": "foo1"}  {"id": 2, "data": "foo2"}  {"id": 3, "data": "foo3"}
    """

    @allure.suite(suite_name)
    @pytest.mark.flaky(reruns=2, reruns_delay=1)
    @pytest.mark.timeout(cfg.case_timeout)
    @pytest.mark.parametrize('input,expect', [(v1, v2) for v1, v2 in zip(TestData.get_test_data('TestHello::test_bar', 'data1'), TestData.get_test_data('TestHello::test_bar', 'data2'))])
    @meta(MetaData('zhengjin', '2020-12-7', ['test', 'param', 'marker']))
    def test_params(self, input, expect):
        logger.debug('input data: %s and expect: %s' % (str(input), expect))
        input = json.loads(input)
        assert input['data'] == expect, 'input and expect not equal.'

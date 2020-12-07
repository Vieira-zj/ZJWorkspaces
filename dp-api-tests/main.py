# coding: utf-8

import os

from apis import DefaultAPI
from utils import Config, HttpConnection, TestData
from tools import PyTestTool


def api_test():
    http = HttpConnection()
    try:
        default_api = DefaultAPI(http)
        print('check health:', default_api.get_default())
    finally:
        if http:
            http.close()


def cfg_test():
    cfg = Config()
    print(f"configs: env={cfg.env}, host={cfg.env_config.host}")

    cfg2 = Config()
    assert cfg == cfg2


def test_load_meta():
    PyTestTool.print_all_pytest_cases_metadata()


def test_load_data():
    sheet_id = '1tSfLMHEh9LO5ZtKBq-3iSkBkCVHE-do0ERZ-iDlA8Cw'
    range_name = 'DP-DB-TestData!A:F'

    TestData.load_data(sheet_id, range_name)
    print(TestData.get_test_data('TestHello::test_bar', 'data1'))
    print(TestData.get_test_data('TestHello::test_bar', 'data2'))


if __name__ == '__main__':

    cfg_test()
    # api_test()

    test_load_meta()
    # test_load_data()

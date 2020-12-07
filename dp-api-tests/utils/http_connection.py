import logging
import requests
from requests.adapters import HTTPAdapter

from utils.configs import Config

logger = logging.getLogger(__name__)


def request_deco(func):
    def _deco(_self, *args, **kwargs):
        _self._before_request()
        resp = func(_self, *args, **kwargs)
        _self._after_request(resp)
        return resp

    return _deco


class HttpConnection(object):

    _default_headers = {
        'Content-Type': 'application/json;charset=utf-8',
        'accept': 'application/json'
    }
    _cfg = Config()
    _default_timeout = _cfg.http_timeout

    def __init__(self, access_token='', is_retcode_check=True):
        self._is_retcode_check = is_retcode_check

        self._sess = requests.session()
        self._sess.mount(
            'https://', HTTPAdapter(max_retries=self._cfg.http_max_retries))
        if len(access_token) > 0:
            self._default_headers['authorization'] = 'Bearer ' + access_token
        self._sess.headers.update(self._default_headers)

    @property
    def session(self):
        return self._sess

    @property
    def is_retcode_check(self):
        return self._is_retcode_check

    @is_retcode_check.setter
    def is_retcode_check(self, is_retcode_check):
        self._is_retcode_check = is_retcode_check

    @request_deco
    def get(self, *args, **kwargs) -> requests.Response:
        resp = self._sess.get(*args, timeout=self._default_timeout, **kwargs)
        return resp

    @request_deco
    def post(self, *args, **kwargs) -> requests.Response:
        resp = self._sess.post(*args, timeout=self._default_timeout, **kwargs)
        return resp

    @request_deco
    def patch(self, *args, **kwargs) -> requests.Response:
        resp = self._sess.patch(*args, timeout=self._default_timeout, **kwargs)
        return resp

    @request_deco
    def delete(self, *args, **kwargs) -> requests.Response:
        resp = self._sess.delete(
            *args, timeout=self._default_timeout, **kwargs)
        return resp

    def _before_request(self):
        pass

    def _after_request(self, resp: requests.Response):
        self._log_request_info(resp.request)
        self._log_response_info(resp)

        if self._is_retcode_check:
            assert resp.status_code in (200, 201)

    def _log_request_info(self, request):
        logger.debug("| " + "*" * 30 + "REQUEST START " + "*" * 30)

        logger.debug("|  Method: " + request.method)
        logger.debug("|  Url: " + request.url)
        logger.debug("|  Headers:")
        for k, v in request.headers.items():
            logger.debug("|    %s: %s" % (k, v))

        data = request.body
        if data and len(data) > 0:
            logger.debug("|  Request Data:")
            logger.debug("|    " + str(data))
        logger.debug("| " + "*" * 30 + " REQUEST END  " + "*" * 30)

    def _log_response_info(self, resp):
        logger.debug("| " + "*" * 30 + "RESPONSE START" + "*" * 30)
        logger.debug("|  Status Code: " + str(resp.status_code))
        logger.debug("|  Headers:")
        for k, v in resp.headers.items():
            logger.debug("|    %s: %s" % (k, v))

        data = resp.content
        if data and len(data) > 0:
            logger.debug("|  Response Data:")
            logger.debug("|    " + str(data))
        logger.debug("| " + "*" * 30 + " RESPONSE END " + "*" * 30)

    def close(self):
        self._sess.close()

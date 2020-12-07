import requests

from utils import Config


class AuthAPI(object):

    def __init__(self):
        self._cfg = Config()

    def login(self):
        url = self._cfg.env_config.host + 'auth/login'
        headers = {
            'Content-Type': 'application/json;charset=utf-8',
            'accept': 'application/json',
        }
        resp = requests.post(url, headers=headers, json={
            'token': self._cfg.env_config.google_token})
        return resp.json()

    def get_login_token(self):
        ret = self.login()
        if ret['statusCode'] != 0:
            raise Exception(
                f"Get login token failed: error={ret['error']}, message={ret['message']}")
        return ret['data']['accessToken']

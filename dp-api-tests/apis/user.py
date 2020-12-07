from utils import Config, HttpConnection


class UserAPI(object):

    def __init__(self, http: HttpConnection):
        self._cfg = Config()
        self._http = http

    def user_list(self, data_dict):
        url = self._cfg.env_config.host + 'user/list'
        resp = self._http.post(url, json=data_dict)
        return resp.json()

    def get_user_id_by_email(self, email):
        data_dict = {'pageSize': 10, 'page': 1, 'email': email}
        resp_json = self.user_list(data_dict)
        if len(resp_json['data']['items']) == 0:
            raise Exception(f"No user found for email [{email}]")

        return resp_json['data']['items'][0]['id']

    def user_download(self, data_dict):
        url = self._cfg.env_config.host + 'user/download'
        resp = self._http.post(url, json=data_dict)
        return resp.text

    def user_frozen(self, data_dict):
        url = self._cfg.env_config.host + 'user/frozen'
        resp = self._http.post(url, json=data_dict)
        return resp.json()

from utils import Config, HttpConnection


class LogAPI(object):

    def __init__(self, http: HttpConnection):
        self._cfg = Config()
        self._http = http

    def get_log(self, data_dict):
        url = self._cfg.env_config.host + 'log'
        resp = self._http.get(url, params=data_dict)
        return resp.json()

    def log_download(self, data_dict):
        url = self._cfg.env_config.host + 'log/download'
        resp = self._http.get(url, params=data_dict)
        return resp.text

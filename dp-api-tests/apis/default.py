from utils import Config, HttpConnection


class DefaultAPI(object):

    def __init__(self, http: HttpConnection):
        self._cfg = Config()
        self._http = http

    def get_default(self) -> bool:
        url = self._cfg.env_config.host + 'api'
        resp = self._http.get(url)
        return 'Hello World' in resp.text

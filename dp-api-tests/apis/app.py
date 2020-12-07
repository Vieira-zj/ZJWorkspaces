from utils import Config, HttpConnection


class AppAPI(object):

    def __init__(self, http: HttpConnection):
        self._cfg = Config()
        self._http = http

    def get_app(self, data_dict):
        url = self._cfg.env_config.host + 'app'
        resp = self._http.get(url, params=data_dict)
        return resp.json()

    def get_app_by_id(self, app_id: str):
        url = self._cfg.env_config.host + f"app/{app_id}"
        resp = self._http.get(url)
        return resp.json()

    def get_all_apps(self):
        url = self._cfg.env_config.host + 'app/all'
        resp = self._http.get(url)
        return resp.json()

    def get_app_id_by_name(self, name):
        resp = self.get_app({'name': name})
        if resp['data']['total'] == 0:
            raise Exception(f"No app [{name}] found!")
        return resp['data']['items'][0]['id']

    def create_app(self, data_dict):
        url = self._cfg.env_config.host + 'app'
        resp = self._http.post(url, json=data_dict)
        return resp.json()

    def create_app_by_name_desc(self, name, desc) -> bool:
        data_dict = {
            'name': name,
            'description': desc
        }
        resp = self.create_app(data_dict)
        return resp['statusCode'] == 0

    def create_app_and_return_id(self, name, desc):
        assert self.create_app_by_name_desc(name, desc)
        return self.get_app_id_by_name(name)

    def update_app(self, data_dict):
        url = self._cfg.env_config.host + 'app'
        resp = self._http.patch(url, json=data_dict)
        return resp.json()

    def delete_app(self, app_id: str):
        url = self._cfg.env_config.host + f"app/{app_id}"
        resp = self._http.delete(url)
        return resp.json()

from utils import Config, HttpConnection


class DataSourceAPI(object):

    def __init__(self, http: HttpConnection):
        self._cfg = Config()
        self._http = http

    def create_datasource(self, data_dict):
        url = self._cfg.env_config.host + 'datasource'
        resp = self._http.post(url, json=data_dict)
        return resp.json()

    def get_datasource(self, data_dict):
        url = self._cfg.env_config.host + 'datasource'
        resp = self._http.get(url, params=data_dict)
        return resp.json()

    def get_datasource_id_by_appid_name(self, app_id, name):
        data_dict = {
            'appId': app_id,
            'name': name,
            'page': 1,
            'pageSize': 10,
        }
        resp_json = self.get_datasource(data_dict)
        if resp_json['data']['total'] == 0:
            raise Exception(f"No data source [{name}] found!")
        return resp_json['data']['items'][0]['id']

    def get_datasource_admin(self, data_dict):
        url = self._cfg.env_config.host + 'datasource/admin'
        resp = self._http.get(url, params=data_dict)
        return resp.json()

    def get_datasource_mini_list(self, app_id):
        url = self._cfg.env_config.host + 'datasource/mini-list'
        resp = self._http.get(url, params={'appId': app_id})
        return resp.json()

    def get_datasource_by_id(self, ds_id):
        url = self._cfg.env_config.host + f"datasource/{ds_id}"
        resp = self._http.get(url)
        return resp.json()

    def update_datasource(self, data_dict):
        url = self._cfg.env_config.host + 'datasource'
        resp = self._http.patch(url, json=data_dict)
        return resp.json()

    def delete_datasource(self, ds_id):
        url = self._cfg.env_config.host + f"datasource/{ds_id}"
        resp = self._http.delete(url)
        return resp.json()

    def datasource_connection(self, data_dict):
        url = self._cfg.env_config.host + 'datasource/connection'
        resp = self._http.post(url, json=data_dict)
        return resp.json()

    def get_datasource_databases_by_id(self, ds_id):
        url = self._cfg.env_config.host + f"datasource/manage/database/{ds_id}"
        resp = self._http.get(url)
        return resp.json()

    def get_datasource_first_db_by_id(self, ds_id) -> str:
        resp_json = self.get_datasource_databases_by_id(ds_id)
        dbs = resp_json['data']
        if len(dbs) == 0:
            raise Exception(f"No database found for datasource [{ds_id}]!")
        return dbs[0]['name']

    def get_datasource_database_info(self, data_dict):
        url = self._cfg.env_config.host + 'datasource/manage/dataArr'
        resp = self._http.post(url, json=data_dict)
        return resp.json()

    def get_datasource_first_table_by_id(self, ds_id, db_name) -> str:
        data_dict = {
            'datasourceId': ds_id,
            'databases': [db_name]
        }
        resp_json = self.get_datasource_database_info(data_dict)
        tbs = resp_json['data']['tables'][0]['tables']
        if len(tbs) == 0:
            raise Exception(
                f"No table found for datasource [{ds_id}], database [{db_name}]")
        return tbs[0]['name']

    def get_datasource_table_columns(self, data_dict):
        url = self._cfg.env_config.host + 'datasource/manage/data/columns'
        resp = self._http.post(url, json=data_dict)
        return resp.json()

    def datasource_manage_data(self, data_dict):
        url = self._cfg.env_config.host + 'datasource/manage/data'
        resp = self._http.patch(url, json=data_dict)
        return resp.json()

    # TODO:
    # /api/v1/datasource/manage/data/increment 增量更新数据源

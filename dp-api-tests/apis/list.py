from utils import Config, HttpConnection


class ListAPI(object):

    def __init__(self, http: HttpConnection):
        self._cfg = Config()
        self._http = http

    def list_database(self, ds_id):
        url = self._cfg.env_config.host + 'database/list'
        resp = self._http.get(url, params={'dataSourceId': ds_id})
        return resp.json()

    def get_first_db_id_from_list_database(self, ds_id):
        resp_json = self.list_database(ds_id)
        dbs = resp_json['data']['databases']
        if len(dbs) == 0:
            raise Exception(f"No database found for datasource [id={ds_id}]!")
        return dbs[0]['id']

    def list_table(self, db_id):
        url = self._cfg.env_config.host + 'table/list'
        resp = self._http.get(url, params={'databaseId': db_id})
        return resp.json()

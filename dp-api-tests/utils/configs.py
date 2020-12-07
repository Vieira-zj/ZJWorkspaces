import logging
import os
import configparser


class Config(object):

    def __new__(cls, *args, **kwargs):
        if not hasattr(cls, '_instance'):
            setattr(cls, '_instance', super(Config, cls).__new__(cls))
        return getattr(cls, '_instance')

    def __init__(self):
        self._main_cfg_dict = self._load_main_configs()
        setattr(self, self.env, EnvConfig(self._load_env_configs(self.env)))

    @property
    def env_config(self):
        return getattr(self, self.env)

    @property
    def env(self):
        return self._main_cfg_dict['common']['env']

    @property
    def is_use_fixture(self):
        is_use = self._main_cfg_dict['case']['is_use_fixture']
        return True if is_use.lower() == 'true' else False

    @property
    def case_timeout(self):
        return int(self._main_cfg_dict['case']['timeout'])

    @property
    def http_timeout(self):
        return int(self._main_cfg_dict['http']['timeout'])

    @property
    def http_max_retries(self):
        return int(self._main_cfg_dict['http']['max_retries'])

    @property
    def log_level(self) -> int:
        log_level = self._main_cfg_dict['log']['loglevel'].lower()
        if log_level == 'error':
            return logging.ERROR
        elif log_level == 'debug':
            return logging.DEBUG
        else:
            return logging.INFO

    def _load_main_configs(self):
        return self._get_configs_dict('configs.ini')

    def _load_env_configs(self, env):
        return self._get_configs_dict(f"configs-{env}.ini")

    def _get_configs_dict(self, file_name):
        cfg_path = os.path.join(
            self._get_project_path(), 'configs', file_name)
        if not os.path.exists(cfg_path):
            raise FileNotFoundError('config file not found: ' + cfg_path)

        cfg_reader = configparser.ConfigParser()
        cfg_reader.read(cfg_path)

        ret_cfg_dict = {}
        for section in cfg_reader.sections():
            options = cfg_reader.options(section)
            tmp_dict = {}
            for option in options:
                tmp_dict[option] = cfg_reader.get(section, option)
            ret_cfg_dict[section] = tmp_dict
        return ret_cfg_dict

    def _get_project_path(self):
        return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


class EnvConfig(object):

    def __init__(self, cfg_dict):
        self._env_cfg_dict = cfg_dict

    @property
    def host(self):
        return self._env_cfg_dict['common']['host']

    @property
    def google_token(self):
        return self._env_cfg_dict['common']['google_token']

    @property
    def access_token(self):
        return self._env_cfg_dict['common']['access_token']

    @property
    def db(self):
        return self._env_cfg_dict['db']

    @property
    def email(self):
        return self._env_cfg_dict['testdata']['user_email']

    @property
    def sheet_id(self):
        return self._env_cfg_dict['testdata']['sheet_id']

    @property
    def range_name(self):
        return self._env_cfg_dict['testdata']['range_name']

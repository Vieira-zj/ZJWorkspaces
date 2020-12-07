import logging
import pickle
import os.path
import pandas as pd

from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request


class TestData(object):

    _test_data: pd.DataFrame = None

    @classmethod
    def _get_creds(cls):
        SCOPES = ['https://www.googleapis.com/auth/spreadsheets.readonly']

        creds = None
        token_path = 'confidential/token.pickle'
        if os.path.exists(token_path):
            with open(token_path, 'rb') as token:
                creds = pickle.load(token)

        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                flow = InstalledAppFlow.from_client_secrets_file(
                    'confidential/credentials.json', SCOPES)
                creds = flow.run_local_server(port=0)
            with open(token_path, 'wb') as token:
                pickle.dump(creds, token)

        return creds

    @classmethod
    def load_data(cls, sheet_id, range_name):
        sheet_id = '1tSfLMHEh9LO5ZtKBq-3iSkBkCVHE-do0ERZ-iDlA8Cw'
        range_name = 'DP-DB-TestData!A:F'

        service = build(
            'sheets', 'v4', credentials=cls._get_creds(), cache_discovery=False)
        results = service.spreadsheets().values().get(
            spreadsheetId=sheet_id, range=range_name).execute()
        values = results.get('values', [])
        if len(values) == 0:
            # logger not init, use print instead
            print("No test data found!")
            return

        cols = values[0]
        rows = values[1:]
        cls._test_data = pd.DataFrame(rows, columns=cols)
        # print('load tests data count: %d' % len(cls._test_data))

    @classmethod
    def get_test_data(cls, test_name, data_name=''):
        df = cls._test_data.loc[lambda x: x['name'] == test_name]
        if len(data_name) > 0:
            df = df.loc[lambda x: x['dataname'] == data_name]
        if len(df) == 0:
            return []

        s = df.iloc[0]
        # fields = list(s.index.values[2:])
        return s.tolist()[2:]


# cfg = Config()
# TestData.load_data(cfg.env_config.sheet_id, cfg.env_config.range_name)

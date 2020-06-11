# -*- coding: utf-8 -*-
import json
import random
import requests

url = ''
headers = {'Content-Type': 'application/json'}
data_file = '/tmp/cess_item_data.csv'

def data_load():
    with open(data_file, 'r') as items_f:
        i = 0
        items = []
        lines = items_f.readlines()
        for line in lines:
            tmp_dict = {}
            fields = line.split(',')
            tmp_dict['itemId'] = fields[0]
            tmp_dict['originItemId'] = fields[1]
            tmp_dict['title'] = fields[5]
            tmp_dict['content'] = fields[6]
            tmp_dict['url'] = fields[12]
            tmp_dict['isSingle'] = fields[16]
            tmp_dict['publishTime'] = fields[14]
            tmp_dict['publishId'] = fields[8]
            tmp_dict['tag'] = fields[4]
            tmp_dict['coverUrl'] = fields[13]
            tmp_dict['type'] = fields[2]
            tmp_dict['storeId'] = fields[17]
            tmp_dict['price'] = random.randint(500, 3000)
            tmp_dict['stock'] = random.randint(1000, 5000)
            tmp_dict['sales'] = random.randint(1000, 10000)
            tmp_dict['country'] = '中国'
            tmp_dict['province'] = random.choice(['广东','湖南','湖北','吉林','辽宁'])
            tmp_dict['city'] = random.choice(['上海','北京','武汉','深圳','广州'])

            items.append(tmp_dict)
            i += 1

            if i % 5 == 0:
                # print(items)
                resp = requests.post(url=url, headers=headers, data=json.dumps(items))
                print(resp.status_code)
                print(json.dumps(resp.json()).decode('unicode_escape'))
                # items = []  # for py2.7
                items.clear()

if __name__ == '__main__':

    data_load()
    print('cess data load done.')

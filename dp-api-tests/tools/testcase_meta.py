class MetaData(object):

    def __init__(self, author, date, tags: list, trace=''):
        self._author = author
        self._date = date
        self._tags = ':'.join(tags)

    def __str__(self):
        return f"author={self._author},date={self._date},desc={self._tags}"


def meta(data: MetaData):

    def _deco(func):
        func.meta_data = data
        return func

    return _deco

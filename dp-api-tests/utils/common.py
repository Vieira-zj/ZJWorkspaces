import time
import os


def get_current_timestamp() -> int:
    return int(round(time.time() * 1000))


def get_lastday_timestamp() -> int:
    return int(round((time.time() - float(3600 * 24)) * 1000))


def get_random_str(length=8):
    import uuid
    if length > 32:
        raise Exception('string length exceed max 32.')
    ret = ''.join(str(uuid.uuid4()).split('-'))
    return ret[:length]


if __name__ == '__main__':

    print(get_random_str(12))

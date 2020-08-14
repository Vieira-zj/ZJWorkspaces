from data import select_user_by_name


def is_auth(user_name, password):
    row = select_user_by_name(user_name)
    return True if row.get("password", "") == password else False


if __name__ == "__main__":
    pass

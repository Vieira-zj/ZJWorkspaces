import base64
import logging
import uuid

logging.basicConfig(
    level=logging.DEBUG, format="%(asctime)s - %(levelname)s: %(message)s"
)
logger = logging.getLogger(__name__)


def string_encode(text: str) -> str:
    b_encode = base64.b64encode(text.encode(encoding="utf-8"))
    return b_encode.decode(encoding="utf-8")


def string_decode(text: str) -> str:
    return base64.b64decode(text).decode(encoding="utf-8")


def get_file_type(file_name: str) -> str:
    return file_name.rsplit(".", 1)[1].lower()


def is_valid_file_type(file_name: str) -> bool:
    # type "txt" for test
    valid_types = ("png", "jpeg", "txt")
    return file_name.find(".") > -1 and get_file_type(file_name) in valid_types


def create_random_str(length=8):
    if length > 32:
        raise ValueError("string length must be less than 32!")

    uid = str(uuid.uuid4())
    suid = "".join(uid.split("-"))
    return suid[:length]


if __name__ == "__main__":
    str_encode = string_encode("hello")
    print(str_encode)
    str_decode = string_decode(str_encode)
    print(str_decode)

    print(is_valid_file_type("user.jpeg"))
    print(create_random_str(12))

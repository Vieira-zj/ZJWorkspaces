import base64
import logging

logging.basicConfig(
    level=logging.DEBUG, format="%(asctime)s - %(levelname)s: %(message)s"
)
logger = logging.getLogger(__name__)


def string_encode(text: str) -> str:
    b_encode = base64.b64encode(text.encode(encoding="utf-8"))
    return b_encode.decode(encoding="utf-8")


def string_decode(text: str) -> str:
    return base64.b64decode(text).decode(encoding="utf-8")


def is_valid_file_type(file_name: str) -> bool:
    valid_types = ("png", "jpeg")
    return (
        file_name.find(".") > -1 and file_name.rsplit(".", 1)[1].lower() in valid_types
    )


if __name__ == "__main__":
    str_encode = string_encode("hello")
    print(str_encode)

    str_decode = string_decode(str_encode)
    print(str_decode)

    print(is_valid_file_type("user.jpeg"))

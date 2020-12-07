import logging
import pytest

from utils import Config

logger = logging.getLogger(__name__)
cfg = Config()


@pytest.fixture(scope='session', autouse=cfg.is_use_fixture)
def all_tests_session_setup_teardown(request):
    """
    All db test session setup and teardown.
    """
    logger.debug('db test session setup.')

    def session_clearup():
        logger.debug('db test session clearup.')

    request.addfinalizer(session_clearup)
    # yield
    # session_clearup()

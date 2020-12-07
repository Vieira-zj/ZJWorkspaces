import logging
import pytest

from tests.base import TestContext
from utils import Config

logger = logging.getLogger(__name__)
cfg = Config()


@pytest.fixture(scope='class', autouse=False)
def datasource_context_setup_teardown(request):
    """
    datasource context setup and teardown.
    """
    logger.debug('datasource context setup.')

    ctx = TestContext()
    ctx.create_app()
    ctx.create_datasource()
    logger.info('create app [id=%d] and datasource [id=%d]' % (
        ctx.app_id, ctx.datasource_id))

    def datasource_context_teardown():
        logger.debug('datasource context clearup.')
        ctx.delete_datasource()
        ctx.delete_app()

    request.addfinalizer(datasource_context_teardown)

import sys
import chromedriver_binary

from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.webdriver.chrome.options import Options as ChromeOptions


def google_login_and_return_cookies(url, port):
    '''
    webdriver selenium dependency:
    pip install selenium
    pip install chromedriver-binary==84.0.4147.30.0
    注：chromedriver版本号与本地chrome浏览器版本号一致
    '''
    caps = {
        'browserName': 'chrome',
        'version': '',
        'platform': 'MAC',
        'javascriptEnabled': True,
    }

    br_options = ChromeOptions()
    br_options.add_experimental_option("debuggerAddress", f"localhost:{port}")

    browser = webdriver.Chrome(
        desired_capabilities=caps, options=br_options)
    browser.implicitly_wait(8)

    browser.get(url)
    cookies = browser.get_cookies()

    try:
        login_btn = browser.find_element_by_partial_link_text("Google")
        login_btn.click()
    except Exception as e:
        print(e)
        print("login direct.")
    return cookies


if __name__ == '__main__':

    if len(sys.argv) < 3:
        raise ValueError("url or port is not specified!")

    url = sys.argv[1]
    port = sys.argv[2]
    cookies = google_login_and_return_cookies(url, port)
    print("cookies:", cookies)

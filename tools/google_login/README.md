# 获取Google Cookies

## 方法1 通过UI自动化获取cookies

> 前提条件：手动完成google登录验证，本地有已保存的cookies.

1. python selenium 环境安装

```sh
pip install selenium
pip install chromedriver-binary==84.0.4147.30.0
```

**注**：chromedriver版本号要与本地chrome浏览器版本号一致。

2. 启动chrome浏览器

如果有chrome浏览器正在运行，先退出。如下命令重新启动chrome, 打开remote debug端口。

正常启动的chrome浏览器，webdriver并不能访问，必须要设置`--remote-debugging-port`选项。端口为本地一个大于1024并且未被占用的端口。

```sh
cd /Applications/Google\ Chrome.app/Contents/MacOS/
./Google\ Chrome --remote-debugging-port=17890
```

3. 执行自动化脚本

通过开放的remote debug端口连接到打开的chrome浏览器，进行登录及获取cookies操作。

```python
def google_login_and_return_cookies(url, port):
    """
    url: 要访问的页面地址
    port: chrome浏览器remote debug端口
    """
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
```

## 方法2 直接访问本地chrome cookies文件

> 前提条件：手动完成google登录，本地有已保存的cookies.

Chrome cookies本地文件存储为sqlite db文件，同时对存储的cookie值作了加密处理。可以通过第三方库pycookiecheat来完成。

1. 环境准备

```sh 
# 依赖库
pip install pycookiecheat
 
# 获取cookies文件
cp ${HOME}/Library/Application\ Support/Google/Chrome/Profile\ 1/Cookies /tmp/Cookies.db
chmod 644 /tmp/Cookies.db
```

2. 测试代码

```python
import requests
from pycookiecheat import chrome_cookies
 
def test():
    '''
    refer to: https://github.com/n8henrie/pycookiecheat
    '''
    url = 'https://docs.google.com/presentation/d/1GAByZxeqd7VzG_QoPjvNTgsnSc7xb3Tj_m7sIb6x1ZY/edit#slide=id.g87a7ccd906_0_56'
    cookies = chrome_cookies(url=url, cookie_file="/tmp/Cookies.db")
    print(f"cookie from {url}:")
    print(cookies)


if __name__ == '__main__':
    test()
```

执行结果：

```text
{'_ga': 'GA1.2-3.125769499.1597212278', 'APISID': 'vtiDvg0cockCV7tY/AEEKx27ccZ63eOfwb', 'HSID': 'ALKHn9yRBiIrcuSjC', 'SAPISID': 'zhiGIjUSdDDKV37D/AWADHSnBi-KkxQnvm', 'SSID': 'AT7WN9VNF9SDw2KT4', '__Secure-3PAPISID': 'zhiGIjUSdDDKV37D/AWADHSnBi-KkxQnvm', 'CGIC': 'Inx0ZXh0L2h0bWwsYXBwbGljYXRpb24veGh0bWwreG1sLGFwcGxpY2F0aW9uL3htbDtxPTAuOSxpbWFnZS93ZWJwLGltYWdlL2FwbmcsKi8qO3E9MC44LGFwcGxpY2F0aW9uL3NpZ25lZC1leGNoYW5nZTt2PWIzO3E9MC45', 'SID': '0Adn9or8kPUCYX9dZunB3yahQIqtn6-Ser_f5xdC9OW5fzgdnWZGYSPhvKoanBEk4n-LZw.', '__Secure-3PSID': '0Adn9or8kPUCYX9dZunB3yahQIqtn6-Ser_f5xdC9OW5fzgd9HZe4VnPP3JmValC94aAXA.', '__utma': '173272373.1094727634.1597406403.1597406403.1597406403.1', '__utmz': '173272373.1597406403.1.1.utmcsr=product|utmccn=forms|utmcmd=forms_logo', 'ANID': 'AHWqTUli1yLzTU06OUhD8FymgVlOh-RiQ3-78ZeIsWb79FmhoOFZdeY8bisENe2D', 'SNID': 'APx-0P3kPpAePrxOKYYzxDB1FI77y6kpUzHaySyQbJE0dlniOSQ1PvdI7afKjWxlP9jlD3G6Y9c5nsxasayf', '1P_JAR': '2020-08-24-02', 'NID': '204=IypN88dfGa7bVgIOxmR8115hl0WQyfVjZ0CF1ipo10Ou-VMp_M1nUXwvoIPRFgP4Di1j-_yAwjdyDWb4FrfY9RSku71vZPnYxfhnYjlb3bmpTXfCGyTzvKuzDvrTkVbcrkrh0gzLt1LtlOgSgCJ9seaDMg-KUC5GuoliRMnmWFayf5TCgogK1tSRvdNQtuPbkN0k7LcNXSWFS8WDxcYanjPxkNkOwjvNqt3Uag', 'SIDCC': 'AJi4QfFpbAorQFDv7T1IP0cOhby1KdpFwfFCTNMlSUeuWFds3hKk3yggVyr12ElC4SLih1QZAg', 'S': 'apps-presentations=05Wig6GiADtqYdzKGOOzSCoUXH3V2b3zyKVhA0r0vQs'}
```

可以成功获取本地cookies, Google登录授权信息存储在字段 SID 和 HSID 中。


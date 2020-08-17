<script>
let host = "http://localhost:12340";
let IsSuperUser = false;

let fnSetIsSuperUser = function(flag) {
  IsSuperUser = flag;
};

let fnGetIsSuperUser = function() {
  return IsSuperUser;
};

let fnIsSuperUserCn = function(flag) {
  return flag === "y" ? "是" : "否";
};

let fnSetCookie = function(cname, cvalue, exdays) {
  let d = new Date();
  d.setTime(d.getTime() + exdays * 24 * 60 * 60 * 1000);
  let expires = "expires=" + d.toUTCString();
  document.cookie = `${cname}=${cvalue};${exdays}`;
};

let fnGetCookie = function(name) {
  let cookies = document.cookie.split(";");
  for (let i = 0; i < cookies.length; i++) {
    let c = cookies[i];
    while (c.charAt(0) === " ") c = c.substring(1);
    if (c.indexOf(name) != -1) {
      return c.substring(name.length + 1, c.length);
    }
  }
  return "";
};

let fnClearCookie = function(name) {
  fnSetCookie(name, "", -1);
};

let fnErrorHandler = function(vm, err) {
  if (err.response) {
    console.error("status:", err.response.status);
    console.error("headers:", err.response.headers);
    console.error("data:", err.response.data);
    if (err.response.status === 403) {
      vm.$message.error("授权失败，用户名或密码不正确！");
    } else {
      vm.$message.error(
        `[Error]: code:${err.response.data.code} message:${err.response.data.msg}`
      );
    }
    return;
  }
  console.error(err);
};

export default {
  host,
  fnSetIsSuperUser,
  fnGetIsSuperUser,
  fnIsSuperUserCn,
  fnSetCookie,
  fnGetCookie,
  fnClearCookie,
  fnErrorHandler
};
</script>

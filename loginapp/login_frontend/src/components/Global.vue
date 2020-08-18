<script>
let host = "http://localhost:12340"; // test
// let host = "http://logindemo.zj.com:8080"; // prod

let fnSetIsSuperUser = function(flag) {
  // TODO: use vuex instead of sessionStorage for global var
  sessionStorage.setItem("IsSuperUser", flag);
};

let fnGetIsSuperUser = function() {
  return sessionStorage.getItem("IsSuperUser") === "true" ? true : false;
};

let fnSetLogonUserName = function(name) {
  sessionStorage.setItem("LogonUserName", name);
};

let fnGetLogonUserName = function() {
  return sessionStorage.getItem("LogonUserName");
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
  fnSetLogonUserName,
  fnGetLogonUserName,
  fnIsSuperUserCn,
  fnSetCookie,
  fnGetCookie,
  fnClearCookie,
  fnErrorHandler
};
</script>

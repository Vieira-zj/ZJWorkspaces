<script>
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
    console.log("status:", err.response.status);
    console.log("headers:", err.response.headers);
    console.log("data:", err.response.data);
    if (err.response.status === 403) {
      vm.$message.error("授权失败，用户名或密码不正确！");
      return;
    }
  }
  console.log(err);
  vm.$message.error("服务器遇到错误！");
};

export default {
  fnSetIsSuperUser,
  fnGetIsSuperUser,
  fnIsSuperUserCn,
  fnSetCookie,
  fnGetCookie,
  fnClearCookie,
  fnErrorHandler
};
</script>

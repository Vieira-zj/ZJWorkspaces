# Ingress-nginx灰度发布

## Echo service 部署

1. k8s cluster info

```sh
kc version --short
# Client Version: v1.19.2
# Server Version: v1.19.2
```

2. add host

```sh
echo "$(minikube ip) k8s.echo.test" >> /etc/hosts
```

3. deploy echo service v1 and check

```sh
kc create -f echoservice_v1_deploy.yml

curl -v http://k8s.echo.test/ | grep host
# Hostname: echoserverv1-6fb869d7f5-b9r4x
```

## Echo service 灰度部署

### Case 1: 按服务的请求百分比执行灰度

1. set canary and `50%` weight

```text
nginx.ingress.kubernetes.io/canary: "true"
nginx.ingress.kubernetes.io/canary-weight: "50"
```

2. deploy echo service v2 and check

```sh
kc create -f echoservice_v2_deploy.yml

for i in {1..10}; do curl -sS http://k8s.echo.test/ | grep hostname; done
# Hostname: echoserverv2-6c5c89d468-7jvth
# Hostname: echoserverv2-6c5c89d468-7jvth
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv2-6c5c89d468-7jvth
# Hostname: echoserverv2-6c5c89d468-7jvth
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv2-6c5c89d468-7jvth
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv2-6c5c89d468-7jvth
```

### Case 2: 根据自定义header，按服务的请求百分比执行灰度

1. edit ingress deploy with below annotations

```text
nginx.ingress.kubernetes.io/canary-by-header: "x-canary"
```

自定义hearder取值：

- `x-canary:always` 流量会全部流入v2；
- `x-canary:never` 流量会全部流入v1；
- `x-canary:true` 流量会按照配置的权重流入对应版本的服务。

2. deploy echo service v2

```sh
kc create -f echoservice_v2_deploy.yml

kc get pod -n k8s-test
# NAME                            READY   STATUS    RESTARTS   AGE
# echoserverv1-6fb869d7f5-b9r4x   1/1     Running   0          169m
# echoserverv2-6c5c89d468-8qv47   1/1     Running   0          15m
```

3. check without header

```sh
for i in {1..10}; do curl -sS http://k8s.echo.test/ | grep hostname; done
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv2-6c5c89d468-8qv47
```

4. check with header as `true`

```sh
for i in {1..10}; do curl -sS -H "x-canary:true" http://k8s.echo.test/ | grep hostname; done
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv1-6fb869d7f5-b9r4x
```

5. check with header as `always`

```sh
for i in {1..10}; do curl -sS -H "x-canary:always" http://k8s.echo.test/ | grep hostname; done
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv2-6c5c89d468-8qv47
# Hostname: echoserverv2-6c5c89d468-8qv47
```

6. check with header as `never`

```sh
for i in {1..10}; do curl -sS -H "x-canary:never" http://k8s.echo.test/ | grep hostname; done
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv1-6fb869d7f5-b9r4x
# Hostname: echoserverv1-6fb869d7f5-b9r4x
```


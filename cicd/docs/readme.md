# CICD

## 分支模型

### 旧分支模型

- dev: 开发调试、自测
- test: 开发完成后合入、集成测试
- uat: 双周，基于版本统一合入，local验收测试
  - 脚本检查jira单及mr（踢出不合规需求），合入版本需求
  - uat发布过程人工介入，可插入临时需求
  - 并行服务发布
- master: 单周，单个feature合入后发布
  - master分支拉出一个临时release分支，合入feature分支，解决代码冲突（原因：1.master分支权限问题；2.在临时分支上操作安全）
  - release合回master分支，添加tag并执行发布
  - 对于紧急版本，直接从master分支拉出feature分支进行开发，完成后合入master分支，发布

> 版本发布：包括多个repo的多个feature. 多个服务按顺序发布，无依赖的服务可并行发布。

优点：

1. 因为可插入临时需求，能够保证要上线的需求发布到uat环境，后端和移动端有明确的需求输入
2. 基于单feature发布，1）当发布上有依赖时，可拆分为更小粒度，按顺序执行；2）上线风险较小，回滚操作简单

缺点：

1. uat与master分支代码不一致
2. 没有预发布环境来执行全量回归测试
3. QA介入较多，如推动开发解决代码合入冲突

### 新分支模型

- dev: 开发调试、自测
- test: 开发完成后合入，集成测试
- uat: 一周两次，基于版本统一合入，local验收测试
  - uat需求 scope cutoff 和 code freeze 检查，不合规需求会被踢出
  - 严格控制临时需求
  - 并行服务发布
- master: 单周
  - 由开发合入mr
  - 上线需求 scope cutoff 和 code freeze 检查
  - scope cutoff 确定版本需求范围，code freeze 确定版本代码范围
- staging: 从master分支合入，预发布环境，执行全量回归测试
- release: 从staging分支合入，添加tag, 基于版本发布

> 理论上 master, stating, release 分支一致。

优点：

1. 由开发完成mr的合入
2. staging与master分支一致，上线前会经过全量回归测试
3. 严格执行 scope cutoff 和 code freeze 检查，过程可做到自动化，较少人工介入

> 减少人工投入，和线上质量。

缺点：

1. 基于版本发布，服务发布顺序问题，及多个服务发布时处理问题复杂

### tag 版本号

常规版本格式：`{module}-v{major}.{minor}.{patch}`
Hotfix and Ad hoc 紧急版本格式：`{module}-v{major}.{minor}.{patch}-{type}`

例子：

```text
current version: rm-v1.2.0
next regular: rm-v1.3.0
next adhoc after regular: rm-v1.3.1-adhoc
next hotfix after regular: rm-v1.3.1-hotfix
```

> 规则简单的版本号可做自增。在release发布时，当前版本号可以基于上一个tag版本做自增。

### 问题

1. 协调前后端发布时间
  - 后端先发布
  - 前端接口向前兼容
  - 回归测试包括api和e2e测试

2. 多个服务的多个feature发布
  - 需求与代码冻结（临时增减上线需求）
  - 服务发布顺序

3. 当前dev需要把feature分别合入到uat和master分支，有两次合入操作
  - 完成uat的需求不一定会合入到master分支
    - 前提：完成uat的需求大概率会合入到master分支
    - 将不合入到uat的需求去掉，之后将uat合入master分支
    - 合入顺序：feature -> uat <-> master <-> staging <-> release（开发只需一次合入操作）
  - local uat signoff 时间不确定
    - 从uat分支 cherrypick 要发布的需求到staging分支。（FIX: cherrypick 可能会导致mr合入顺序不一致，引起额外的代码冲突）
    - 保证uat分支与release分支同步

## 发布工具

功能：

1. 通过 jira webhook, 检查jira单及关联mr的状态
2. 通过 gitlab webhook 和 pipeline, 检查mr及关联的jira单状态
3. 通过 gitlab api 执行mr及tag操作
4. 服务依赖关系及checklist检查
5. 通过 jenkins api 执行服务发布pipeline
6. 通知与报告

## golang cicd 流程

### 主干分支

Jenkins pipeline:

![img](images/main_br_pipeline.png)

检查点：

1. 代码扫描
2. 单元测试 -> 单测覆盖率
3. API测 -> 集成测试覆盖率
4. 服务部署完成后的线上检查

输出：

- `junit.xml`: 单元测试结果。
- `ut_cover.out`: 全量的函数覆盖率报告。
- `ut_cover.html`: 全量的行覆盖率报告。

### Feature 分支

Jenkins pipeline:

![img](images/feature_br_pipeline.png)

检查点：

1. 单元测试
2. 增量代码 -> go反向调用链分析（精准测试）
3. 增量覆盖率

输出：

- `diff_cover.out`: 增量的函数覆盖率报告。

![img](images/diff_cover_func_rpt.png)

- `diff_cover_report.html`: 增量的行覆盖率报告。

![img](images/diff_cover_html_rpt.png)

diffcover工具生成的增量覆盖率报告只显示未被覆盖的行，参考 `srccode/diff_cover_patch` 同时显示 所有增量代码+未被覆盖的行。

> 增量覆盖率数据基于 单测+全量覆盖率数据+diffcover工具 生成。


# CICD

## 分支模型

### 旧分支模型

- dev: 开发调试
- test: 开发完成后合入
- uat: 双周，基于版本统一合入
  - 脚本检查jira单及mr (不合规需求会被踢出), 合入版本需求
  - uat发布过程人介入，可插入临时需求
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
3. 人工介入较多，如推动开发解决代码合入冲突

### 新分支模型

- dev: 开发调试
- test: 开发完成后合入
- uat: 单周，基于版本统一合入
  - uat需求 scope cutoff 和 code freeze 检查，不合规需求会被踢出
  - 严格控制临时需求
  - 并行服务发布
- master: 单周
  - 由开发合入mr
  - 上线需求 scope cutoff 和 code freeze 检查
  - code freeze 后确定版本范围
- staging: 从master分支合入，对应预发布环境，执行全量回归测试
- release: 从staging分支合入，添加tag, 基于版本发布

优点：

1. 由开发完成mr的合入
2. staging与master分支一致，上线前会经过全量回归测试
3. 严格执行 scope cutoff 和 code freeze 检查，过程可做到自动化，较少的人工介入

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

> 规则简单的版本号可做自增。在release分布时，当前版本号可以基于上一个tag版本做自增。

## 发布流程

1. create jira tasks
  - pm create business user-story
  - dev leader create tech user-story
  - one user-story contains multiple tasks
  - one task include only one mr
  - key fields: Plan by Due Date, Fix Version

2. status: prd
  - requirements review
  - pm / dev leader update to "developing" and asign to dev

3. status:developing env:dev
  - dev coding and deploy to test
  - qa test cases design
  - dev update to "testing" and asign to qa

4. status:testing env:test
  - qa run test
  - dev fix bug
  - qa update to "reviewing" and assign to dev leader

5. status:review env:uat
  - code review
  - dev deploy to uat
  - dev leader update to "uat" and assign to pm

6. status:uat env:uat
  - pm do local test, signoff
  - pm update to "staging"

7. status:staging
  - pm fill release cycle
  - dev merge mr to "master" branch

8. status:regression env:staging


## 发布工具

1. 通过 jira webhook, 检查jira单及关联mr的状态
2. 通过 gitlab webhook 和 pipeline, 检查mr及关联的jira单状态
3. 通过 gitlab api 执行mr及tag操作
4. 服务依赖关系检查
5. 通过 jenkins api 执行服务发布
6. 通知与报告

## golang cicd 流程

### 主干分支

Jenkins pipeline:

![img](images/main_br_pipeline.png)

检查点：

1. 代码扫描
2. 单元测试 -> 单测覆盖率
3. API测 -> 集成测试覆盖率
4. 服务部署后的线上检查

输出：

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

diffcover 增量覆盖率报告只显示未被覆盖的行，参考 `srccode/diff_cover_patch` 同时显示 所有增量代码+未被覆盖的行。

> 增量覆盖率数据基于 全量数据+diffcover工具 生成。


# 项目简介
基于 Vue3 + SpringBoot + Elastic Stack 的一站式聚合搜索平台，也是简化版的企业级搜索中台。

对用户来说，使用该平台可以在一个页面搜索出不同来源、不同类型的内容，提升用户的搜索效率和搜索体验。

对企业来说，当企业内部有多个项目的数据都存在搜索需求时，无需针对每个项目单独开发搜索功能，可以将个项目的数据源接入搜索中台，从而提升开发效率、降低系统维护成本。

# 技术选型
## 前端
* Vue 3
* Ant Design Vue 组件库
* 页面状态同步

## 后端
* SpringBoot 2.7 + 脚手架
* MySQL (8)
* Elastic Stack
  * ElasticSearch 搜索引擎
  * Logstash 数据管道
  * Kibana 数据可视化
* 数据抓取(jsoup HttpClient)
  * 离线
  * 实时
* 设计模式
  * 门面模式
  * 适配器模式
  * 注册器模式
* 数据同步 (4种同步方式)
  * 定时
  * 双写
  * Logstash
  * Canal
* JMeter压力测试
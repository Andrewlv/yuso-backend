<div align="center">

# 🔍 Yuso Backend

**One-stop aggregated-search backend — one query fans out in parallel to posts (Elasticsearch), users (MySQL) and pictures (live Bing crawling), behind a clean facade + adapter + registry design.**

**English** | [简体中文](README.zh-CN.md)

![Java](https://img.shields.io/badge/Java-8-orange?logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.7.2-6DB33F?logo=springboot&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-5.7%2B-4479A1?logo=mysql&logoColor=white)
![Elasticsearch](https://img.shields.io/badge/Elasticsearch-7.x-06B8D4?logo=elasticsearch&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-session%20store-DC382D?logo=redis&logoColor=white)
![Crawler](https://img.shields.io/badge/Crawler-Jsoup%201.15.3-8A2BE2)
![Knife4j](https://img.shields.io/badge/API%20Docs-Knife4j%203.0.3-blue)
![GitHub stars](https://img.shields.io/github/stars/Andrewlv/yuso-backend?style=social)

</div>

---

## 📖 About

Yuso (鱼搜) is the backend of a **one-stop aggregated-search platform** — think of it as a simplified enterprise search middleware. Instead of building a search feature per project, you connect data sources to this service and query them all from a single page:

- For **users**: one search box returns posts, users, and pictures at once, instead of hunting through multiple sites.
- For **enterprises**: multiple projects share one search middle-platform instead of each rolling its own search stack.

The backend demonstrates the full pipeline: crawling data in (jsoup + HTTP), storing it (MySQL), indexing it (Elasticsearch with `ik` analyzers), searching across heterogeneous sources in parallel (`CompletableFuture` fan-out), and wrapping it all in **facade / adapter / registry** design patterns so adding a new data source is a one-class change.

## ✨ Features

- 🔎 **Aggregated search** — `POST /search/all` fans out to three data sources in parallel and merges the results; pass `type: user / post / picture` to search a single source instead
- 🧩 **Extensible data sources** — every source implements a common `DataSource` interface and registers itself in a `DataSourceRegistry` (adapter + registry patterns); the `SearchFacade` orchestrates them (facade pattern)
- 🖼️ **Live picture search** — a jsoup crawler scrapes Bing image results on the fly (title + full-resolution URL), no database needed
- 📄 **Post search on Elasticsearch** — posts are indexed into ES (`ik_max_word` / `ik_smart` analyzers); queries run on ES, then the latest per-post stats (likes, favorites) are rehydrated from MySQL, and physically-deleted posts are self-cleaned out of the index
- 🔄 **Two ES sync jobs** — a full sync (`CommandLineRunner`) and an incremental sync (`@Scheduled`, every minute, posts updated in the last 5 minutes including deletions); both are disabled by default — uncomment `@Component` to enable
- 🕷️ **Data crawling** — `FetchInitPostList` pulls an initial post list from a live site into MySQL (offline crawling, disabled by default); `CrawlerTest` shows both crawler techniques
- 👥 **User & auth** — register / login / logout with role-based access (`user` / `admin` / `ban`) enforced by a custom `@AuthCheck` annotation + AOP; Spring Session keeps you logged in
- 💬 **WeChat** — Official Account message callback (subscribe / text / event handlers via `wx-java`) and Open Platform OAuth login
- 📦 **Tencent COS file upload** — per-business uploads validated by a `FileUploadBizEnum` whitelist
- 🛡️ **Engineering guardrails** — global exception handler, unified `BaseResponse` wrapper, custom error codes, global CORS, request logging AOP, and `Long → String` JSON serialization to prevent JS precision loss
- 📖 **Live API docs** — Knife4j (Swagger 2) UI

## 🧱 Tech Stack

| Category | Technology |
| --- | --- |
| Framework | Spring Boot 2.7.2 · Spring MVC · Spring AOP · Spring Scheduler |
| Data Access | MyBatis 2.2.2 · MyBatis-Plus 3.5.2 (pagination, logical delete) |
| Database | MySQL |
| Session / Cache | Redis · Spring Session Data Redis (opt-in) |
| Search | Spring Data Elasticsearch (`PostEsDao` · `ElasticsearchRestTemplate`) |
| Crawling | Jsoup 1.15.3 · Hutool HTTP (`HttpRequest`) |
| API Docs | Knife4j 3.0.3 (Swagger 2, dev/test profiles) |
| WeChat | `wx-java-mp-spring-boot-starter` 4.4.0 (MP + Open Platform) |
| Object Storage | Tencent Cloud COS (`cos_api` 5.6.89) |
| Utilities | Hutool 5.8.8 · EasyExcel 3.1.1 · Gson 2.9.1 · Commons Lang3 · Lombok |

## 📂 Project Structure

```
yuso-backend
├── sql/                                  # create_table.sql · post_es_mapping.json
├── data/passage.json                     # crawled sample passages
├── doc/swagger.png
├── Dockerfile                            # Multi-stage Maven build (prod profile)
└── src/main
    ├── java/com/yupi/yuso
    │   ├── MainApplication.java          # Entry point
    │   ├── controller/                   # Search · User · Post · PostThumb · PostFavour · Picture · File · WxMp
    │   ├── datasource/                   # DataSource SPI · PostDataSource · UserDataSource · PictureDataSource · DataSourceRegistry
    │   ├── manager/                      # SearchFacade (fan-out + merge) · CosManager
    │   ├── service/                      # User · Post · PostThumb · PostFavour · Picture services
    │   ├── esdao/                        # PostEsDao — Elasticsearch data access
    │   ├── job/
    │   │   ├── once/FetchInitPostList    # One-shot crawl of initial posts (disabled)
    │   │   ├── once/FullSyncPostToEs     # One-shot full MySQL → ES sync (disabled)
    │   │   └── cycle/IncSyncPostToEs     # Scheduled incremental sync, 1 min (disabled)
    │   ├── annotation/                   # @AuthCheck — role guard
    │   ├── aop/                          # Auth · log interceptors
    │   ├── common/                       # BaseResponse · ErrorCode · ResultUtils · PageRequest
    │   ├── config/                       # CORS · Knife4j · MyBatis-Plus · COS · JSON · WeChat
    │   ├── exception/                    # GlobalExceptionHandler · BusinessException · ThrowUtils
    │   ├── mapper/                       # MyBatis mappers
    │   ├── model/                        # DTOs · entities · enums · VOs
    │   ├── utils/                        # Net · Sql · SpringContext utils
    │   └── wxmp/                         # WeChat MP message router + handlers
    └── resources
        ├── application.yml               # Shared config (active profile: dev)
        ├── application-{test,prod}.yml
        └── mapper/                       # MyBatis XML mappers
```

## 🚀 Quick Start

### Prerequisites

| Requirement | Version | Required? | Notes |
| --- | --- | --- | --- |
| JDK | 8+ | ✅ | `pom.xml` sets `java.version = 1.8` |
| Maven | 3.6+ | ✅ | Wrapper included — `./mvnw` works standalone |
| MySQL | 5.7+ | ✅ | Database `my_db` |
| Elasticsearch | 7.x + ik analyzer | ✅ | Post full-text search |
| Redis | 6+ | ⬜ | Enables distributed login sessions |

### 1. Create the database

The script creates the `my_db` database and four tables — `user`, `post`, `post_thumb`, `post_favour`:

```bash
mysql -u root -p < sql/create_table.sql
```

### 2. Create the Elasticsearch index

Create the `post` index with the bundled mapping (uses the `ik` analyzer — install the [analysis-ik](https://github.com/medcl/elasticsearch-analysis-ik) plugin first):

```
PUT post
{
  // contents of sql/post_es_mapping.json
}
```

### 3. Point the app at your database and enable Elasticsearch

In `src/main/resources/application.yml`, replace the values marked `todo` and uncomment the `spring.elasticsearch` block:

```yml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/my_db
    username: root
    password: 123456
  elasticsearch:
    uris: http://localhost:9200
```

### 4. Run the app

```bash
# Maven wrapper (no local Maven needed)
./mvnw spring-boot:run

# — or build a jar
./mvnw package -DskipTests
java -jar target/yuso-backend-0.0.1-SNAPSHOT.jar
```

The service starts on **port 8102** (dev profile) with the base path `/api`.

### 5. Explore

| Resource | URL |
| --- | --- |
| API docs (Knife4j) | <http://localhost:8102/api/doc.html> |

![Knife4j API docs](doc/swagger.png)

### Key endpoints (base path `/api`)

| Method | Path | Description |
| --- | --- | --- |
| POST | `/search/all` | Aggregated search — all sources in parallel, or one source via `type` |
| POST | `/user/login` · `/user/register` · `/user/logout` | Auth endpoints |
| GET | `/user/login/wx_open` | WeChat Open Platform OAuth login callback |
| POST | `/post/list/page/vo` | Paged posts (Elasticsearch when `searchText` is set) |
| POST | `/post/add` | Create a post (admin) |
| POST | `/picture/list/page/vo` | Live Bing image search (page size capped at 20) |
| POST | `/post_thumb/` · `/post_favour/` | Like / favorite a post |
| POST | `/file/upload` | Upload a file to Tencent COS |

## 🧩 Optional Modules

<details>
<summary><b>Enable the ES sync jobs</b></summary>

Posts only appear in ES search after a sync. Uncomment `@Component` in both `job/once/FullSyncPostToEs.java` (runs once at startup, syncs everything) and `job/cycle/IncSyncPostToEs.java` (runs every minute, syncs posts updated in the last 5 minutes — including deletions), then restart the app.

</details>

<details>
<summary><b>Redis — distributed login</b></summary>

1. Add your Redis settings to `application.yml` (uncomment the `spring.redis` block).
2. Enable Redis-backed sessions:

    ```yml
    spring:
      session:
        store-type: redis
    ```

3. Remove the `RedisAutoConfiguration` exclude in `MainApplication.java`:

    ```java
    // Before
    @SpringBootApplication(exclude = {RedisAutoConfiguration.class})
    // After
    @SpringBootApplication
    ```

</details>

<details>
<summary><b>Crawl the initial post list</b></summary>

`FetchInitPostList` (a `CommandLineRunner`, disabled by default) pulls the newest reviewed posts from an external site and batch-inserts them into MySQL, so search has something to return. Uncomment its `@Component` to run it once at startup — or see `data/passage.json` for previously crawled sample data.

</details>

<details>
<summary><b>WeChat — Official Account & Open Platform</b></summary>

Fill in the `wx.mp` (Official Account) and `wx.open` (Open Platform) blocks in `application.yml` with your app's `appId`, `secret`, `token`, and `aesKey`. Message routing, subscribe events, and menu handling are already implemented under `wxmp/`.

</details>

<details>
<summary><b>Tencent COS — file upload</b></summary>

Fill in the `cos.client` block in `application.yml` with your `accessKey`, `secretKey`, `region`, and `bucket`. Uploads are validated against `FileUploadBizEnum` and served by `FileController` / `CosManager`.

</details>

## 🐳 Docker Deployment

The included multi-stage `Dockerfile` builds with Maven and runs the `prod` profile (port 8101 — configure `application-prod.yml` first):

```bash
docker build -t yuso-backend .
docker run -d -p 8101:8101 yuso-backend
```

## 🧪 Tests

```bash
./mvnw test
```

`src/test` covers every layer: mappers, services, the ES dao, the COS manager, an EasyExcel import/export example — and `CrawlerTest`, which makes **real HTTP requests** to live sites (Bing images and the crawled post source), so run it only when you want network access.

## 🤝 Acknowledgments

This project is based on [程序员鱼皮 (liyupi)](https://github.com/liyupi)'s **yuso (鱼搜) aggregated-search platform** course project, which is itself built on his [springboot-init](https://github.com/liyupi/springboot-init) template from the [编程导航知识星球](https://yupi.icu). Many thanks for open-sourcing the scaffolding and the course! 🙏

## ⭐ Support

If this project helped you learn aggregated search or search-middleware design, a star is appreciated — it helps other developers find it.

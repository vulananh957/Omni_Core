# OmniCore — Warehouse Management System

> A graduation-project WMS (Warehouse Management System) built on Jakarta EE.
> JSP views, Servlet controllers, Service layer, DAO layer, MySQL backend.

## Architecture

```
webapp/                       JSP views (no Java scriptlets, no inline DAO calls)
└── WEB-INF/views/...
    └── layout/               Shared header / sidebar / footer fragments

controller/                   Servlets — HTTP in, JSP out
├── BaseController.java       Common helpers (JSON, flash messages, params)
├── auth/                     Login / logout / OTP / password reset
├── category/                 Category CRUD
├── sales/                    Sales orders, channel products
├── warehouse/                Master SKU, inventory, inbound, outbound, ...
└── ...

service/                      Business logic — pure Java, no HTTP imports
├── category/
├── warehouse/
├── ledger/
└── ...

dao/                          Data Access Objects
├── BaseDAO.java              Shared JDBC helpers (queryOne, queryList, update)
├── CategoryDAO.java
├── WarehouseDAO.java
└── ...

model/                        Plain Java records / beans
                              @JsonProperty annotations drive JSON shape

util/
├── AppConstants.java         Centralised string constants
├── DBConnection.java         HikariCP-backed connection pool
├── JsonUtil.java             Shared Jackson ObjectMapper (JavaTimeModule, UTF-8)
└── DatabaseConfig.java       db.properties loader
```

### Layer rules
- JSP views **never** call DAOs or contain `<% %>` scriptlets.
- Servlets own request → response. They use `BaseController` helpers
  (`forward`, `redirect`, `setJsonAttr`, `parseJson`, `setFlash*`).
- Services own business rules. They take plain Java objects, return
  plain Java objects, and never touch `HttpServletRequest`.
- DAOs own SQL. `BaseDAO` provides `queryOne` / `queryList` / `update`
  so concrete DAOs only have to write the SQL string and a row mapper.

## Build & run

```bash
mvn clean package          # produces target/omnicore.war
cp target/omnicore.war $CATALINA_HOME/webapps/
$CATALINA_HOME/bin/startup.sh
```

Requires:
* JDK 17+
* Apache Tomcat 10.1 (Jakarta EE 10, Servlet 6.0)
* MySQL 8.x

### Database setup
1. Create the database (see `src/main/resources/mock_data.sql`).
2. Copy `src/main/resources/db.properties.example` to
   `src/main/resources/db.properties` and fill in your credentials.
3. On first deploy, `SchemaInitListener` creates the tables and seeds
   mock data.

## Code conventions

* **No `new ObjectMapper()`** — use `JsonUtil.getMapper()` (or
  `BaseController.parseJson` / `setJsonAttr` from servlets).
* **No scriptlets in JSP** — use JSTL `${}` and `${fn:escapeXml(...)}`.
* **No raw `try-with-resources` for SELECTs** in new DAO methods —
  extend `BaseDAO` and use `queryList` / `queryOne`.
* All flash messages go through `setFlash*` (session) + `consumeFlash`
  (request) on `BaseController`.
* Constants live in `AppConstants`; avoid magic strings in controllers.

## Recent refactor phases

| Phase | Goal | Status |
|-------|------|--------|
| 0 | Branch setup, baseline build, backup tag | done |
| 1 | Extract inline CSS from 16 large JSPs into separate files | done |
| 2 | Remove `<% %>` scriptlets and direct DAO calls from JSPs | done |
| 3 | Centralise JSON via `BaseController.setJsonAttr` / `parseJson` | done |
| 4 | `BaseDAO` + `RowMapper`; simplify Category/Warehouse/Order DAO | done |
| 5 | ~~Flyway migration~~ — skipped, keep `SchemaInitListener` | skipped |
| 6 | Helper consolidation, dead-code cleanup, README | done |

The backup of every phase is pushed to
<https://github.com/vulananh957/backup_omnicore> (branch
`refactor/simplify-architecture`).

## Roles

| Role | Can do |
|------|--------|
| `ADMIN` | Everything |
| `MANAGER` | Category, master SKU, approve orders, manage users |
| `WAREHOUSE_STAFF` | Inbound, outbound, inventory checks, transfers |
| `SALES_STAFF` | Create sales orders, channel SKU mapping |
| `CUSTOMER` | View their own orders only |

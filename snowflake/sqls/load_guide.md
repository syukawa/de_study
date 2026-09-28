# snow_shoji_training データ投入ガイド (MySQL)

テーブルはFK依存順に並んでいます。**この順番のままロード**してください。

```bash
# 1. テーブル作成
mysql --local-infile=1 -h <HOST> -u <USER> -p <DB> < ddl.sql

# 2. データロード (mysqlクライアント内で実行)
```

```sql
LOAD DATA LOCAL INFILE 'stores.csv' INTO TABLE stores
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'products.csv' INTO TABLE products
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'employees.csv' INTO TABLE employees
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'customers.csv' INTO TABLE customers
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'area_assignments.csv' INTO TABLE area_assignments
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'calendar_events.csv' INTO TABLE calendar_events
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'sales_orders.csv' INTO TABLE sales_orders
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'shipments.csv' INTO TABLE shipments
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'web_events.csv' INTO TABLE web_events
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'inquiries.csv' INTO TABLE inquiries
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'event_attendees.csv' INTO TABLE event_attendees
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\n' IGNORE 1 LINES;

```

---

# snow_shoji_training データ投入ガイド (PostgreSQL)

テーブルはFK依存順に並んでいます。**この順番のままロード**してください。

```bash
# 1. テーブル作成
psql -h <HOST> -U <USER> -d <DB> -f ddl.sql

# 2. データロード (psql内で実行)
```

```
\copy stores FROM 'stores.csv' WITH (FORMAT csv, HEADER true);
\copy products FROM 'products.csv' WITH (FORMAT csv, HEADER true);
\copy employees FROM 'employees.csv' WITH (FORMAT csv, HEADER true);
\copy customers FROM 'customers.csv' WITH (FORMAT csv, HEADER true);
\copy area_assignments FROM 'area_assignments.csv' WITH (FORMAT csv, HEADER true);
\copy calendar_events FROM 'calendar_events.csv' WITH (FORMAT csv, HEADER true);
\copy sales_orders FROM 'sales_orders.csv' WITH (FORMAT csv, HEADER true);
\copy shipments FROM 'shipments.csv' WITH (FORMAT csv, HEADER true);
\copy web_events FROM 'web_events.csv' WITH (FORMAT csv, HEADER true);
\copy inquiries FROM 'inquiries.csv' WITH (FORMAT csv, HEADER true);
\copy event_attendees FROM 'event_attendees.csv' WITH (FORMAT csv, HEADER true);
```

---

# snow_shoji_training データ投入ガイド (Snowflake)

テーブルはFK依存順に並んでいます。**この順番のままロード**してください。

```sql
-- 1. ddl.sql を実行してテーブル作成

-- 2. ステージ作成とファイルアップロード (SnowSQL)
CREATE OR REPLACE STAGE snow_shoji_training_stage;
PUT file:///path/to/*.parquet @snow_shoji_training_stage AUTO_COMPRESS=FALSE;

-- 3. ロード (FK依存順)
COPY INTO stores FROM @snow_shoji_training_stage/stores.parquet FILE_FORMAT=(TYPE=PARQUET) MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;
COPY INTO products FROM @snow_shoji_training_stage/products.parquet FILE_FORMAT=(TYPE=PARQUET) MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;
COPY INTO employees FROM @snow_shoji_training_stage/employees.parquet FILE_FORMAT=(TYPE=PARQUET) MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;
COPY INTO customers FROM @snow_shoji_training_stage/customers.parquet FILE_FORMAT=(TYPE=PARQUET) MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;
COPY INTO area_assignments FROM @snow_shoji_training_stage/area_assignments.parquet FILE_FORMAT=(TYPE=PARQUET) MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;
COPY INTO calendar_events FROM @snow_shoji_training_stage/calendar_events.parquet FILE_FORMAT=(TYPE=PARQUET) MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;
COPY INTO sales_orders FROM @snow_shoji_training_stage/sales_orders.parquet FILE_FORMAT=(TYPE=PARQUET) MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;
COPY INTO shipments FROM @snow_shoji_training_stage/shipments.parquet FILE_FORMAT=(TYPE=PARQUET) MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;
COPY INTO web_events FROM @snow_shoji_training_stage/web_events.parquet FILE_FORMAT=(TYPE=PARQUET) MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;
COPY INTO inquiries FROM @snow_shoji_training_stage/inquiries.parquet FILE_FORMAT=(TYPE=PARQUET) MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;
COPY INTO event_attendees FROM @snow_shoji_training_stage/event_attendees.parquet FILE_FORMAT=(TYPE=PARQUET) MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;
```

---

# snow_shoji_training データ投入ガイド (BigQuery)

テーブルはFK依存順に並んでいます。**この順番のままロード**してください。

```bash
# 1. データセット作成
bq mk --dataset <PROJECT>:snow_shoji_training

# 2. ロード (parquetはスキーマ自動検出。ddl.sqlはビュー等の参考用)
bq load --source_format=PARQUET snow_shoji_training.stores stores.parquet
bq load --source_format=PARQUET snow_shoji_training.products products.parquet
bq load --source_format=PARQUET snow_shoji_training.employees employees.parquet
bq load --source_format=PARQUET snow_shoji_training.customers customers.parquet
bq load --source_format=PARQUET snow_shoji_training.area_assignments area_assignments.parquet
bq load --source_format=PARQUET snow_shoji_training.calendar_events calendar_events.parquet
bq load --source_format=PARQUET snow_shoji_training.sales_orders sales_orders.parquet
bq load --source_format=PARQUET snow_shoji_training.shipments shipments.parquet
bq load --source_format=PARQUET snow_shoji_training.web_events web_events.parquet
bq load --source_format=PARQUET snow_shoji_training.inquiries inquiries.parquet
bq load --source_format=PARQUET snow_shoji_training.event_attendees event_attendees.parquet
```

---

# snow_shoji_training データ投入ガイド (Redshift)

テーブルはFK依存順に並んでいます。**この順番のままロード**してください。

```bash
# 1. ファイルをS3へ
aws s3 cp . s3://<BUCKET>/snow_shoji_training/ --recursive --exclude '*' --include '*.parquet'

# 2. ddl.sql でテーブル作成後、COPY (FK依存順)
```

```sql
COPY stores FROM 's3://<BUCKET>/snow_shoji_training/stores.parquet'
  IAM_ROLE '<IAM_ROLE_ARN>' FORMAT AS PARQUET;

COPY products FROM 's3://<BUCKET>/snow_shoji_training/products.parquet'
  IAM_ROLE '<IAM_ROLE_ARN>' FORMAT AS PARQUET;

COPY employees FROM 's3://<BUCKET>/snow_shoji_training/employees.parquet'
  IAM_ROLE '<IAM_ROLE_ARN>' FORMAT AS PARQUET;

COPY customers FROM 's3://<BUCKET>/snow_shoji_training/customers.parquet'
  IAM_ROLE '<IAM_ROLE_ARN>' FORMAT AS PARQUET;

COPY area_assignments FROM 's3://<BUCKET>/snow_shoji_training/area_assignments.parquet'
  IAM_ROLE '<IAM_ROLE_ARN>' FORMAT AS PARQUET;

COPY calendar_events FROM 's3://<BUCKET>/snow_shoji_training/calendar_events.parquet'
  IAM_ROLE '<IAM_ROLE_ARN>' FORMAT AS PARQUET;

COPY sales_orders FROM 's3://<BUCKET>/snow_shoji_training/sales_orders.parquet'
  IAM_ROLE '<IAM_ROLE_ARN>' FORMAT AS PARQUET;

COPY shipments FROM 's3://<BUCKET>/snow_shoji_training/shipments.parquet'
  IAM_ROLE '<IAM_ROLE_ARN>' FORMAT AS PARQUET;

COPY web_events FROM 's3://<BUCKET>/snow_shoji_training/web_events.parquet'
  IAM_ROLE '<IAM_ROLE_ARN>' FORMAT AS PARQUET;

COPY inquiries FROM 's3://<BUCKET>/snow_shoji_training/inquiries.parquet'
  IAM_ROLE '<IAM_ROLE_ARN>' FORMAT AS PARQUET;

COPY event_attendees FROM 's3://<BUCKET>/snow_shoji_training/event_attendees.parquet'
  IAM_ROLE '<IAM_ROLE_ARN>' FORMAT AS PARQUET;

```

---

# snow_shoji_training データ投入ガイド (Databricks)

テーブルはFK依存順に並んでいます。**この順番のままロード**してください。

```bash
# 1. Unity Catalog Volume へアップロード
databricks fs cp . dbfs:/Volumes/<CATALOG>/<SCHEMA>/<VOLUME>/snow_shoji_training/ --recursive

# 2. ddl.sql でテーブル作成後、COPY INTO (FK依存順)
```

```sql
COPY INTO stores
  FROM '/Volumes/<CATALOG>/<SCHEMA>/<VOLUME>/snow_shoji_training/stores.parquet'
  FILEFORMAT = PARQUET;

COPY INTO products
  FROM '/Volumes/<CATALOG>/<SCHEMA>/<VOLUME>/snow_shoji_training/products.parquet'
  FILEFORMAT = PARQUET;

COPY INTO employees
  FROM '/Volumes/<CATALOG>/<SCHEMA>/<VOLUME>/snow_shoji_training/employees.parquet'
  FILEFORMAT = PARQUET;

COPY INTO customers
  FROM '/Volumes/<CATALOG>/<SCHEMA>/<VOLUME>/snow_shoji_training/customers.parquet'
  FILEFORMAT = PARQUET;

COPY INTO area_assignments
  FROM '/Volumes/<CATALOG>/<SCHEMA>/<VOLUME>/snow_shoji_training/area_assignments.parquet'
  FILEFORMAT = PARQUET;

COPY INTO calendar_events
  FROM '/Volumes/<CATALOG>/<SCHEMA>/<VOLUME>/snow_shoji_training/calendar_events.parquet'
  FILEFORMAT = PARQUET;

COPY INTO sales_orders
  FROM '/Volumes/<CATALOG>/<SCHEMA>/<VOLUME>/snow_shoji_training/sales_orders.parquet'
  FILEFORMAT = PARQUET;

COPY INTO shipments
  FROM '/Volumes/<CATALOG>/<SCHEMA>/<VOLUME>/snow_shoji_training/shipments.parquet'
  FILEFORMAT = PARQUET;

COPY INTO web_events
  FROM '/Volumes/<CATALOG>/<SCHEMA>/<VOLUME>/snow_shoji_training/web_events.parquet'
  FILEFORMAT = PARQUET;

COPY INTO inquiries
  FROM '/Volumes/<CATALOG>/<SCHEMA>/<VOLUME>/snow_shoji_training/inquiries.parquet'
  FILEFORMAT = PARQUET;

COPY INTO event_attendees
  FROM '/Volumes/<CATALOG>/<SCHEMA>/<VOLUME>/snow_shoji_training/event_attendees.parquet'
  FILEFORMAT = PARQUET;

```
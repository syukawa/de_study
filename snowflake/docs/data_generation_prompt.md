# 演習データ生成プロンプト

外部の生成AIサイトに、下の「プロンプト本文」をそのまま貼り付けて使います。

---

## プロンプト本文

````text
架空の小売企業「スノー商事」のデータ基盤研修で使うテーブルデータを作成してください。
以下のテーブル設計に従い、各テーブルを CSV 形式（ヘッダー行あり、UTF-8）で出力してください。

# 会社の概要
- 全国に実店舗50店と EC サイトを持つ小売企業。家電・キッチン用品・衣料・食品・日用品・インテリアを販売する。
- データの期間は 2024-04-01〜2026-12-31。
- 人名・住所・電話番号・メールアドレスはすべて架空のものにする。メールのドメインは example.com / example.jp / example.net のみ。

# テーブル一覧

| No | テーブル名 | 内容 | 行数の目安 |
| --- | --- | --- | --- |
| 1 | STORES | 店舗マスタ | 50 |
| 2 | PRODUCTS | 商品マスタ | 500 |
| 3 | CUSTOMERS | 顧客マスタ（個人情報を含む） | 20,000 |
| 4 | EMPLOYEES | 社員マスタ | 120 |
| 5 | AREA_ASSIGNMENTS | 営業のエリア担当履歴 | 20 |
| 6 | CALENDAR_EVENTS | 祝日・セール・キャンペーンのカレンダー | 150 |
| 7 | SALES_ORDERS | 売上明細（店舗・EC・アプリ） | 1,000,000 |
| 8 | SHIPMENTS | 配送実績（EC・アプリの注文） | 450,000 |
| 9 | WEB_EVENTS | EC サイトのアクセスログ（JSON） | 500,000 |
| 10 | INQUIRIES | お客様からの問い合わせ | 3,000 |
| 11 | EVENT_ATTENDEES | 店頭イベントの来場者 | 1,500 |

# テーブルの関係

- SALES_ORDERS.STORE_ID → STORES.STORE_ID
- SALES_ORDERS.CUSTOMER_ID → CUSTOMERS.CUSTOMER_ID
- SALES_ORDERS.PRODUCT_ID → PRODUCTS.PRODUCT_ID
- SHIPMENTS.ORDER_ID → SALES_ORDERS.ORDER_ID（CHANNEL が EC / APP の注文のみ、1対1）
- CUSTOMERS.HOME_STORE_ID → STORES.STORE_ID
- WEB_EVENTS の user.customer_id → CUSTOMERS.CUSTOMER_ID、items[].product_id → PRODUCTS.PRODUCT_ID
- INQUIRIES.CUSTOMER_ID / ORDER_ID / PRODUCT_ID → 各テーブル
- EVENT_ATTENDEES.STORE_ID → STORES.STORE_ID（来場者の約70%は CUSTOMERS と同じメールアドレスの既存顧客）
- AREA_ASSIGNMENTS.EMPLOYEE_ID → EMPLOYEES.EMPLOYEE_ID

# テーブル定義

## 1. STORES（店舗マスタ）
| 列名 | 型 | キー | 説明・値の例 |
| --- | --- | --- | --- |
| STORE_ID | VARCHAR(4) | PK | S001〜S050 |
| STORE_NAME | VARCHAR | | スノー商事 新宿店 |
| REGION | VARCHAR | | S001〜S015=関東、S016〜S025=関西、S026〜S035=中部、S036〜S042=九州、S043〜S050=東北 |
| PREFECTURE | VARCHAR | | REGION と矛盾しない都道府県 |
| CITY | VARCHAR | | 市区町村 |
| STORE_TYPE | VARCHAR | | 路面店 / ショッピングセンター / 駅ビル |
| FLOOR_AREA_SQM | NUMBER | | 売場面積（300〜3000） |
| OPEN_DATE | DATE | | 開店日 |
| CLOSE_DATE | DATE | | 閉店日（営業中は空） |

## 2. PRODUCTS（商品マスタ）
| 列名 | 型 | キー | 説明・値の例 |
| --- | --- | --- | --- |
| PRODUCT_ID | VARCHAR(5) | PK | P0001〜P0500 |
| PRODUCT_NAME | VARCHAR | | P0001=ワイヤレスイヤホン SNOW BUDS、P0002=電気ケトル SNOW KETTLE 1.0L、P0003=ダウンジャケット SNOW DOWN（固定）。ほかはカテゴリに合った商品名 |
| CATEGORY_L | VARCHAR | | 家電 / キッチン / 衣料 / 食品 / 日用品 / インテリア |
| CATEGORY_M | VARCHAR | | 中分類（例：オーディオ、調理家電、アウター） |
| TAX_RATE | NUMBER(3,2) | | 0.10。食品のみ 0.08 |
| LIST_PRICE | NUMBER | | 税込の定価（円） |
| COST_PRICE | NUMBER | | 税抜の原価（円） |
| LAUNCH_DATE | DATE | | 発売日 |
| DISCONTINUED_DATE | DATE | | 販売終了日（販売中は空） |
| EC_ONLY | VARCHAR(1) | | Y / N |

## 3. CUSTOMERS（顧客マスタ）
| 列名 | 型 | キー | 説明・値の例 |
| --- | --- | --- | --- |
| CUSTOMER_ID | VARCHAR(7) | PK | C000001〜C020000 |
| FULL_NAME | VARCHAR | | 佐藤 花子 |
| FULL_NAME_KANA | VARCHAR | | サトウ ハナコ |
| EMAIL | VARCHAR | | user000001@example.com |
| PHONE | VARCHAR | | 090-1234-5678 |
| POSTAL_CODE | VARCHAR | | 160-0022 |
| PREFECTURE | VARCHAR | | 東京都 |
| ADDRESS_LINE | VARCHAR | | 市区町村以下の架空の住所 |
| BIRTH_DATE | DATE | | 18〜80歳 |
| GENDER | VARCHAR(1) | | M / F / U |
| REGISTERED_AT | TIMESTAMP | | 会員登録日時 |
| MEMBER_RANK | VARCHAR | | REGULAR / SILVER / GOLD |
| MAIL_OPT_IN | VARCHAR(1) | | Y / N（メール配信の同意） |
| HOME_STORE_ID | VARCHAR(4) | FK | よく利用する店舗 |
| STATUS | VARCHAR | | ACTIVE / WITHDRAWN（退会） |
| UPDATED_AT | TIMESTAMP | | 最終更新日時 |

## 4. EMPLOYEES（社員マスタ）
| 列名 | 型 | キー | 説明・値の例 |
| --- | --- | --- | --- |
| EMPLOYEE_ID | VARCHAR(5) | PK | E0001〜 |
| FULL_NAME | VARCHAR | | 北村 浩 |
| EMAIL | VARCHAR | | e0001@example.jp |
| DEPARTMENT | VARCHAR | | 情報システム部 / 経営企画部 / マーケティング部 / 営業本部 / カスタマーサポート部 / 経理部 / 情報セキュリティ室 / EC事業部 / 店舗運営部 |
| TITLE | VARCHAR | | 部長 / マネージャー / リーダー / 担当 |
| HIRE_DATE | DATE | | 入社日 |
| RETIRE_DATE | DATE | | 退職日（在籍中は空） |

※ 次の人物を含める：北村（情報システム部 部長）、佐伯（情報システム部）、高田（経営企画部）、森（マーケティング部）、石井（情報セキュリティ室）、野口（経理部）、中川（EC事業部）、小池（営業本部 東日本エリアマネージャー）、大野（カスタマーサポート部 リーダー）

## 5. AREA_ASSIGNMENTS（エリア担当履歴）
| 列名 | 型 | キー | 説明・値の例 |
| --- | --- | --- | --- |
| EMPLOYEE_ID | VARCHAR(5) | PK, FK | 営業本部の社員 |
| REGION | VARCHAR | PK | 関東 / 関西 / 中部 / 九州 / 東北 |
| VALID_FROM | DATE | PK | 担当開始日 |
| VALID_TO | DATE | | 担当終了日（担当中は空） |

※ 小池さんは関東・東北を担当し、2026-10-01 から中部も担当する。

## 6. CALENDAR_EVENTS（祝日・販促カレンダー）
| 列名 | 型 | キー | 説明・値の例 |
| --- | --- | --- | --- |
| EVENT_DATE | DATE | PK | 2026-09-21 |
| EVENT_TYPE | VARCHAR | PK | HOLIDAY / SALE / CAMPAIGN / INCIDENT |
| EVENT_NAME | VARCHAR | | 敬老の日 / 夏のボーナスセール / TVCM 放映 / EC システム障害 |
| CHANNEL | VARCHAR | | ALL / EC / STORE |

※ 2024〜2026年の日本の祝日を正確に入れる。

## 7. SALES_ORDERS（売上明細）
1行＝1注文の1商品。列の順番もこのとおりにする。
| 列名 | 型 | キー | 説明・値の例 |
| --- | --- | --- | --- |
| ORDER_ID | VARCHAR(11) | PK | ORD00000001 |
| ORDER_DATE | DATE | | 2026-05-01 |
| STORE_ID | VARCHAR(4) | FK | 実店舗はその店舗。EC / APP は顧客の HOME_STORE_ID |
| CHANNEL | VARCHAR | | STORE / EC / APP（APP は 2026-07-01 から） |
| CUSTOMER_ID | VARCHAR(7) | FK | 必ず値を入れる |
| PRODUCT_ID | VARCHAR(5) | FK | |
| QUANTITY | NUMBER | | 1〜5 |
| UNIT_PRICE | NUMBER | | 税込の販売単価（円） |

※ 曜日（週末は店舗が多い）、季節（夏・年末に山）、祝日・セールによる変動を付ける。EC と APP の合計は全体の約40%。

## 8. SHIPMENTS（配送実績）
| 列名 | 型 | キー | 説明・値の例 |
| --- | --- | --- | --- |
| SHIPMENT_ID | VARCHAR(11) | PK | SHP00000001 |
| ORDER_ID | VARCHAR(11) | FK | EC / APP の注文 |
| SHIPPED_DATE | DATE | | 注文の0〜2日後 |
| DELIVERED_DATE | DATE | | 出荷の1〜3日後 |
| CARRIER | VARCHAR | | 架空の配送会社（3社程度） |
| DELIVERY_PREFECTURE | VARCHAR | | 届け先の都道府県 |
| SHIPPING_FEE | NUMBER | | 税込。注文金額 5,000円以上は0円、未満は550円（2026-10-01 以降は基準が7,000円） |

## 9. WEB_EVENTS（EC アクセスログ）
1行に1つの JSON（JSON Lines 形式）。期間は直近180日。
```json
{"event_id":"<UUID>","event_ts":"2026-05-01T10:15:30","event_type":"page_view",
 "session_id":"<UUID>",
 "user":{"customer_id":"C001234","device":"sp"},
 "page":{"url":"/products/P0123","referrer":"search"},
 "items":[{"product_id":"P0123","qty":1}]}
```
| キー | 説明・値の例 |
| --- | --- |
| event_type | page_view / search / add_to_cart / purchase |
| user.customer_id | 非会員の閲覧は null |
| user.device | pc / sp / tablet |
| page.referrer | search / sns / direct / mail |
| items | add_to_cart と purchase のときだけ1〜3件、それ以外は空配列 |
| search_query | event_type が search のときだけ、日本語の検索語 |

## 10. INQUIRIES（問い合わせ）
| 列名 | 型 | キー | 説明・値の例 |
| --- | --- | --- | --- |
| INQUIRY_ID | VARCHAR(8) | PK | INQ00001 |
| RECEIVED_AT | TIMESTAMP | | 2026年の受付日時 |
| CUSTOMER_ID | VARCHAR(7) | FK | |
| ORDER_ID | VARCHAR(11) | FK | 注文に関する問い合わせのみ（ほかは空） |
| PRODUCT_ID | VARCHAR(5) | FK | |
| CHANNEL | VARCHAR | | STORE / EC / APP |
| CONTACT_METHOD | VARCHAR | | mail / form / phone / chat |
| INQUIRY_TEXT | VARCHAR | | 100〜300字の自然な日本語の問い合わせ本文。言い回しに変化を付ける |
| TOPIC | VARCHAR | | 配送の遅れ / 商品の破損 / 返品・交換 / サイズ・仕様の質問 / 支払い / 店舗スタッフの対応 / ポイント（本文と一致させる） |
| TONE | VARCHAR | | 怒っている / 困っている / 落ち着いている / 感謝している（本文と一致させる） |
| STATUS | VARCHAR | | OPEN / CLOSED |
| CLOSED_AT | TIMESTAMP | | 対応完了日時 |

## 11. EVENT_ATTENDEES（店頭イベントの来場者）
| 列名 | 型 | キー | 説明・値の例 |
| --- | --- | --- | --- |
| ATTENDEE_ID | VARCHAR(8) | PK | ATT00001 |
| EVENT_NAME | VARCHAR | | 春の新生活フェア |
| EVENT_DATE | DATE | | 2026年のイベント開催日 |
| STORE_ID | VARCHAR(4) | FK | 開催店舗 |
| FULL_NAME | VARCHAR | | |
| EMAIL | VARCHAR | | |
| PREFECTURE | VARCHAR | | |
| SURVEY_SCORE | NUMBER | | 1〜5 |

# 出力のルール
- 外部キーは必ず参照先に存在する値にする。
- 日付は YYYY-MM-DD、日時は YYYY-MM-DD HH:MM:SS（日本時間）。
- 行数が多いテーブルは、まず各テーブル20行ずつのサンプルを出力し、その後、全件を生成する方法（ファイルのダウンロード、または生成用のコード）を提示してください。
````

# スノー商事 研修用データセット 設計メモ

## 1. 指示の解釈

- 架空の小売企業「スノー商事」(実店舗50店 + EC + 2026-07リリースのアプリ)のデータ基盤研修用に、**11テーブル**を依存順に定義した。
- データ期間は **2024-04-01〜2026-12-31**。マスタの開店日/入社日/発売日/会員登録日時など「過去に遡る属性」だけはこの期間より前も許容している(店舗の開店日は1998年〜、顧客の登録日時は2015年〜)。
- 人名・住所・電話番号は日本語Fakerで生成。メールのドメインは `example.com`(顧客)/`example.jp`(社員)のみを使う。
- 元指示の `WEB_EVENTS` は JSON Lines だが、本スペックは列指向テーブルのみを生成するため **1行=1イベントに平坦化**した(`user.customer_id`→`customer_id`、`page.url`→`page_url`、`items[]`→`item1_*`〜`item3_*` の3スロット + `item_count`)。DWH取り込み後に `struct`/`array` へ再構成するか、そのまま平坦テーブルとして分析できる。
- 列名は DWH のカタログで扱いやすい **英小文字スネークケース**に統一した(元指示の `STORE_ID` 等と大文字小文字のみの差で、主要DWHでは同一識別子として扱われる)。`SALES_ORDERS` は元指示の8列の順序をそのまま保持し、シナリオで後から追加される列は末尾に付けている。

## 2. 各テーブルの役割と設計意図

| # | テーブル | 役割 | 設計意図 |
| --- | --- | --- | --- |
| 1 | `stores` | 店舗マスタ(50) | 地域・店舗タイプ・売場面積を持たせ、売上按分(D-01)や店舗タイプ別の週末伸び(D-02)の軸にする。`close_date` を空文字主体の選択にして S037 閉店(M-04)を表現。 |
| 2 | `products` | 商品マスタ(700) | 元指示の500点に、M-01「毎月1日に5〜10点追加」33か月分(約200点)を織り込んで **700行**にした。`tax_rate` は食品0.08を混在、`discontinued_date` は空文字主体で M-03 を表現。 |
| 3 | `employees` | 社員マスタ(131) | 120名 + M-10 の 2026-04-01 入社11名 = **131行**。`retire_date` に 2026-03-31 を混ぜて退職(M-10)を表現。 |
| 4 | `customers` | 顧客マスタ(20,000) | 研修の中心。氏名を `last_name`/`first_name`/`full_name` に分解して名寄せ演習(A-05)に使えるようにした。`status` に `MERGED`、`merged_into` を追加して顧客統合(M-08)、`updated_at` でマスタ差分(M-05/06/07)を表現。 |
| 5 | `area_assignments` | エリア担当履歴(26) | 複合PK(社員×地域×開始日)の **有効期間型履歴テーブル**。M-09 の組織変更で行追加+`valid_to` 設定が起きる前提で20→**26行**。 |
| 6 | `calendar_events` | 販促・祝日カレンダー(150) | 祝日/セール/CM/障害/規程改定を一元化。売上予測に「特別な日」として渡す想定(A-06)。複合PK(日付×種別)。 |
| 7 | `sales_orders` | 売上明細(1,000,000) | 1行=1注文1商品。時間帯分布のため `order_ts`(夜ピーク)、E-04 の列追加のため `point_used`、E-02/03/08/09 のファイル起因障害を追跡するため `source_file` を末尾に追加。 |
| 8 | `shipments` | 配送実績(450,000) | EC/APP注文と1対1。`shipping_fee` を 0/550 の2値にして送料規程改定(M-11)の前後比較に使う。 |
| 9 | `web_events` | ECアクセスログ(500,000) | 直近180日。E-06 を表現するため `device`(2026-04-27まで)と `device_type`(04-28以降)を**別列で共存**させ、`app_version` を追加。どちらか一方だけ見ると値がNULLになる罠を再現。 |
| 10 | `inquiries` | 問い合わせ(3,000) | 自然文の `inquiry_text` に加え、評価用の正解列 `contains_pii`(A-03)、`injection_flag`(A-04)を持つ。TOPICに「その他」(M-07の削除依頼)を含む。 |
| 11 | `event_attendees` | 店頭イベント来場者(1,500) | 名寄せ演習用(A-05)。正解列 `matched_customer_id` と、どのゆれを適用したかを示す `email_variant_type` を用意。 |

## 3. シナリオ(時系列・履歴)の反映方法

### D. 日次の売上パターン
- **D-01/D-02/D-03/D-08**: `sales_orders.order_date`(2024-04-01〜2026-12-31)と `order_ts`(`diurnal:true` で夜ピーク)で表現。曜日・祝日・給料日の山と年率8%成長は、生成器が日付ごとの件数ウェイトを掛ける前提。チャネル構成は `channel` の重み **STORE 59 / EC 33 / APP 8** で、期間全体(APPは2026-07以降のみ)を平均した比率にしてある。
- **D-04/D-05**: セール・TVCMは `calendar_events` に `SALE`/`CAMPAIGN` として登録。値引きは `unit_price` が `products.list_price` と一致しない行として現れる。
- **D-06/D-07**: 年末商戦は12月の日付ウェイト、悪天候3件は `calendar_events` の `INCIDENT` と、該当地域の店舗売上減・配送遅延(`shipped_date`→`delivered_date` の間隔)で表現。

### E. 日次のデータ障害
- **E-01**: `calendar_events` の `INCIDENT`(2025-11-10 / 2026-12-18)と、当日14〜19時に `channel='EC'` の行が無いこと(`order_ts`)で表現。
- **E-02/E-03/E-08/E-09**: すべて `source_file` 列で追跡可能にした。POS送信漏れ(ファイルには入っていないが `order_date` は 2026-08-18)、再送ファイル(`sales_20260713_resend.csv`)、日付跨ぎ(ファイル名の日付と `order_date` が1日ずれる)、同一ファイル内の `order_id` 重複を、`source_file` × `order_date` × `order_id` の組み合わせで検出する演習になる。
- **E-04**: `point_used` を**末尾列**に配置。2026-07-06以前の行は空、07-07以降は約85%が0、残りが10〜2,000。
- **E-05**: 不正値(`N/A`/空/負値/スラッシュ日付/存在しない `product_id`/前後空白付き `customer_id`)は、型どおりの正常値として生成したあとに0.05%(および2026-06-24分の1%)を意図的に破壊する後処理で入れる。
- **E-06**: 上表のとおり `device` / `device_type` / `app_version` の3列で表現。
- **E-07**: `channel` に `APP` を含め、2026-07-01以降のみ出現させる。

### M. マスタ変更
- **M-01/M-02/M-03/M-12**: `products` の `launch_date` / `discontinued_date` と、`list_price`(現在値のみ・履歴なし)で表現。価格改定・分類変更は**上書き**なので、`products.list_price` と過去の `sales_orders.unit_price` が一致しない=履歴テーブルが必要という気づきが得られる。
- **M-04**: `stores.open_date`(S050 = 2025-10-01)/ `close_date`(S037 = 2026-08-31)。付け替えは `customers.home_store_id` + `updated_at`。
- **M-05/M-06/M-07**: `customers` の住所3列・`member_rank`・`status` を `updated_at` 付きで更新する日次スナップショット運用を前提にした。個人情報削除(C004821)は該当列を空文字にする。
- **M-08**: `status='MERGED'` + `merged_into`(既存の `customer_id` を指す)。
- **M-09/M-10**: `area_assignments` は行追加+`valid_to` 設定で履歴を残し、`employees.department` は上書き(履歴なし)にして、履歴の有無の対比を作る。
- **M-11**: `calendar_events` に「送料規程の改定」(2026-10-01)、`shipments.shipping_fee` の 0/550 の比率変化で表現。

### A. 分析・AI向け
- **A-01**: P0001 の売上減 × 問い合わせ増 × `web_events` の `purchase` 減を、同じ `product_id` で結合して検証する。
- **A-02**: `received_at` の月別ウェイトと `topic` 分布、`contact_method` の時間帯差。
- **A-03/A-04**: `contains_pii` / `injection_flag` が評価用の正解ラベル。
- **A-05**: `matched_customer_id`(正解)と `email_variant_type`(ゆれの種類)。
- **A-06**: 2026-09-19〜23 のシルバーウィーク、2026-12、2026-06-20 CM、2026-08-21 台風を `calendar_events` に必ず登録。

## 4. このデータで試せる分析の例

1. **日次売上の異常検知**: 日別・チャネル別件数の移動平均からの乖離で、E-01(EC障害)、E-02(POS送信漏れ)、D-07(台風)を検出する。
2. **チャネル定義の罠**: `channel='EC'` だけで集計すると2026-07から売上が約2割減ったように見える(実際は APP へ移行)。
3. **重複・冪等性**: `order_id` で重複排除した場合/しない場合の売上差(E-03/E-09)。
4. **履歴の必要性**: `products` の現在価格・現在カテゴリで過去売上を集計し、当時の `unit_price` ベースの数字と突き合わせる(M-02/M-12)。顧客住所でも同じ比較(M-05)。
5. **エリア担当の時点参照**: `area_assignments` を 2026-09-30 時点と 2026-10-01 時点で `valid_from`/`valid_to` 条件で切り、担当地域の差分を出す(M-09)。
6. **RFM/会員ランク検証**: 年度購入金額と 4/1 の `member_rank` の整合(M-06)。
7. **配送SLA**: `delivered_date - shipped_date` の分布を連休・年末・悪天候で比較(D-03/D-06/D-07)。
8. **ファネル分析**: `web_events` の page_view → add_to_cart → purchase と `sales_orders` の突き合わせ、CM放映直後のセッション急増(D-05)。
9. **名寄せ**: メールの単純一致 vs 正規化(大文字小文字・空白・全角)後の一致率を `matched_customer_id` を正解として評価(A-05)。
10. **テキストAI評価**: 問い合わせの要約・分類を行い、`injection_flag` の行で出力が汚染されていないか、`contains_pii` の行でマスキングが効いているかを測る(A-03/A-04)。
11. **売上予測**: `calendar_events` を特徴量に入れる/入れないで 2026-09 シルバーウィークと 2026-12 の誤差を比較(A-06)。

## 5. 生成器への申し送り(本スペックの表現上の限界)

本スペックの `gen` は列単位の独立生成なので、次の整合は生成器側の後処理で担保すること。

- **列間の相関**: `stores` の `region`↔`prefecture`↔`city`(重みは S001〜S050 の地域配分 関東15/関西10/中部10/九州7/東北8 に合わせてある)、`products` の `category_l`↔`category_m`↔`tax_rate`(食品のみ0.08)↔価格帯、`list_price` > `cost_price`、`customers` の `full_name_kana` と `full_name` の対応。
- **日付の順序**: `open_date` < `close_date`、`launch_date` < `discontinued_date`、`hire_date` < `retire_date`、`order_date` ≤ `shipped_date` ≤ `delivered_date`(0〜2日後 / 1〜3日後)、`received_at` < `closed_at`、`birth_date` は18〜80歳。
- **NULL/空欄**: 空文字を含む `choice` で「多くは空」を表現している(`close_date`、`discontinued_date`、`retire_date`、`valid_to`、`merged_into`、`device`/`device_type`/`app_version`、`search_query`)。`web_events.customer_id`(非会員は約35%空)、`inquiries.order_id`(注文起因のみ)、`event_attendees.matched_customer_id`(新規30%は空)は FK 生成のため必ず値が入るので、後処理で空欄化する。
- **固定値の行**: P0001/P0002/P0003 の商品名、氏名指定の社員(北村・佐伯・高田・森・石井・野口・中川・小池・大野)、C004821 の削除依頼、小池さんのエリア担当行は、生成後に該当行を上書きする。
- **本文とラベルの一致**: `inquiry_text` と `topic`/`tone`/`contains_pii`/`injection_flag` は独立生成なので、本文テンプレートごとにラベルを決め打ちするか、生成後にラベルを本文から付け直すこと。`inquiry_text` の選択肢は各トピック・トーンの代表例として与えてある(実データでは言い回しを増やす)。
- **`source_file`**: `sales_{order_date}.csv` テンプレートでハイフン付きになるため、`sales_YYYYMMDD.csv` へ整形し、E-02/E-03/E-08 のケースではファイル名と `order_date` を意図的にずらす。
- **金額整合**: `shipping_fee` は注文金額(`unit_price` × `quantity`)と基準額(2026-10-01より5,000円→7,000円)から再計算する。
- **件数の日次配分**: `rows` は総件数の指定なので、D章の曜日・季節・祝日・セールのウェイトは日付サンプリング時に適用する。
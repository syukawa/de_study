CREATE TABLE stores (
  store_id STRING COMMENT '店舗ID。S001〜S050の固定長コード',
  region STRING COMMENT '地域区分。関東/関西/中部/九州/東北。店舗IDのブロック(S001-015関東など)に対応する',
  prefecture STRING COMMENT '店舗所在地の都道府県。地域区分と矛盾しない値にする',
  city STRING COMMENT '店舗所在地の市区町村',
  store_name STRING COMMENT '店舗名。「スノー商事 ○○店」の形式',
  store_type STRING COMMENT '店舗形態。路面店/ショッピングセンター/駅ビル。週末の売上伸び率が形態により異なる',
  floor_area_sqm BIGINT COMMENT '売場面積(平方メートル)。300〜3000。店舗別売上規模の按分に使う',
  open_date DATE COMMENT '開店日。この日より前に当該店舗の売上は発生しない(S050は2025-10-01開店)',
  close_date DATE COMMENT '閉店日。営業中の店舗は空。S037は2026-08-31に閉店し以降の売上はない',
  PRIMARY KEY (store_id)
) COMMENT '店舗マスタ。全国50店舗の所在地・店舗タイプ・売場面積・開閉店日を保持する。売上の地域別/店舗タイプ別分析の軸マスタ';

CREATE TABLE products (
  product_id STRING COMMENT '商品ID。P0001〜の固定長コード。毎月の新商品追加で連番が伸びる',
  category_l STRING COMMENT '商品大分類。家電/キッチン/衣料/食品/日用品/インテリア。2026-04-01の分類見直しで一部商品が大分類をまたいで移動する',
  category_m STRING COMMENT '商品中分類。大分類と矛盾しない値。2026-04-01に「調理家電」→「キッチン家電」等の改名・統合が入る',
  product_name STRING COMMENT '商品名。自社ブランド「SNOW」を冠した商品名。P0001=ワイヤレスイヤホン SNOW BUDS、P0002=電気ケトル SNOW KETTLE 1.0L、P0003=ダウンジャケット SNOW DOWN は固定',
  tax_rate DOUBLE COMMENT '消費税率。標準は0.10、食品のみ軽減税率0.08',
  list_price BIGINT COMMENT '税込の定価(円)。2025-04-01と2026-10-01の価格改定で食品・キッチン用品の約30%が5〜15%値上げされる(上書き)',
  cost_price BIGINT COMMENT '税抜の原価(円)。定価より必ず低い値にする。粗利分析に使う',
  launch_date DATE COMMENT '発売日。この日より前に当該商品の売上は発生しない。毎月1日に新商品5〜10点が追加される',
  discontinued_date DATE COMMENT '販売終了日。販売中の商品は空。四半期ごと(1/1・4/1・7/1・10/1)に3〜5点設定され、以降の売上はない',
  ec_only STRING COMMENT 'EC専売フラグ。Y=ECとアプリのみで販売、N=実店舗でも販売',
  PRIMARY KEY (product_id)
) COMMENT '商品マスタ。家電・キッチン・衣料・食品・日用品・インテリアの取扱商品。価格とカテゴリは履歴を持たず常に現在値で上書きされる(改定前の値は残らない)';

CREATE TABLE employees (
  employee_id STRING COMMENT '社員ID。E0001〜の固定長コード',
  last_name STRING COMMENT '社員の姓',
  first_name STRING COMMENT '社員の名',
  full_name STRING COMMENT '社員氏名。姓と名を半角スペースで連結した表記',
  email STRING COMMENT '社内メールアドレス。社員IDに対応する架空アドレス(example.jpドメイン)',
  department STRING COMMENT '所属部署。異動時は履歴を残さず上書きされる',
  title STRING COMMENT '役職。部長/マネージャー/リーダー/担当',
  hire_date DATE COMMENT '入社日。2026-04-01に新卒10名と中途1名(情報システム部)が入社する',
  retire_date DATE COMMENT '退職日。在籍中の社員は空。2026-03-31付で5名が退職する',
  PRIMARY KEY (employee_id)
) COMMENT '社員マスタ。所属部署・役職・在籍状況を保持する。部署異動は履歴を残さず上書きされるため、過去の所属は追跡できない';

CREATE TABLE customers (
  customer_id STRING COMMENT '顧客ID。C000001〜C020000の固定長コード。退会・統合・個人情報削除後も保持される不変キー',
  last_name STRING COMMENT '顧客の姓。旧姓のまま登録されているケースがあり名寄せの難所になる',
  first_name STRING COMMENT '顧客の名',
  full_name STRING COMMENT '顧客氏名。姓と名を半角スペースで連結した表記。個人情報削除依頼を受けた顧客は空になる',
  full_name_kana STRING COMMENT '顧客氏名のカナ表記。個人情報削除依頼を受けた顧客は空になる',
  email STRING COMMENT 'メールアドレス。user+顧客番号の架空アドレス(example.comドメイン)。重複登録された顧客では大文字小文字の違いが生じる',
  phone STRING COMMENT '電話番号。重複登録の同一人物判定に使える(氏名+電話番号が一致)',
  postal_code STRING COMMENT '郵便番号。引越しで変更される',
  prefecture STRING COMMENT '居住都道府県。引越しで変更されるため、過去売上を現住所で集計すると当時の地域別実績と一致しない',
  address_line STRING COMMENT '市区町村以下の住所。個人情報削除依頼を受けた顧客は空になる',
  birth_date DATE COMMENT '生年月日。18〜80歳の範囲。年代別分析(アプリ利用は20〜30代が中心)に使う',
  gender STRING COMMENT '性別。M=男性、F=女性、U=未回答',
  registered_at TIMESTAMP COMMENT '会員登録日時(日本時間)。この日時以前の注文は発生しない',
  member_rank STRING COMMENT '会員ランク。REGULAR/SILVER/GOLD。毎年4/1に前年度購入金額で見直され約15%が変動する(上位8%=GOLD、次の22%=SILVER)',
  mail_opt_in STRING COMMENT 'メール配信同意フラグ。Y=同意、N=非同意',
  home_store_id STRING COMMENT 'よく利用する店舗の店舗ID。EC・アプリ注文の計上店舗にもなる。閉店や引越しで付け替えられる',
  status STRING COMMENT '顧客状態。ACTIVE=有効、WITHDRAWN=退会(以降の注文なし)、MERGED=重複登録として統合済み',
  merged_into STRING COMMENT '統合先の顧客ID。重複登録が2026-11-01に統合された際、新しい側のレコードに統合先(古い側)のIDが入る。通常は空',
  updated_at TIMESTAMP COMMENT '最終更新日時(日本時間)。住所変更・ランク更新・退会・統合・個人情報削除のたびに更新される。マスタ差分取り込みの基準列',
  PRIMARY KEY (customer_id),
  FOREIGN KEY (home_store_id) REFERENCES stores (store_id)
) COMMENT '顧客マスタ(個人情報を含む)。氏名・連絡先・住所・会員ランク・在籍状況を保持する日次スナップショット。変更があった日に全件が届き、変更行はupdated_atが更新される';

CREATE TABLE area_assignments (
  employee_id STRING COMMENT '担当社員の社員ID。営業本部所属の社員のみ',
  region STRING COMMENT '担当地域。関東/関西/中部/九州/東北。店舗マスタのregionと同じ区分',
  valid_from DATE COMMENT '担当開始日。2026-10-01の組織変更で新しい担当行が追加される',
  valid_to DATE COMMENT '担当終了日。担当中は空。中部の前任者は2026-09-30で担当を外れる',
  PRIMARY KEY (employee_id, region, valid_from),
  FOREIGN KEY (employee_id) REFERENCES employees (employee_id)
) COMMENT '営業本部社員のエリア担当履歴。社員×地域×担当開始日を複合主キーとする有効期間型の履歴テーブル。過去行は削除せず、担当終了時はvalid_toを設定する';

CREATE TABLE calendar_events (
  event_date DATE COMMENT 'イベント発生日。2024〜2026年の日本の祝日、セール期間の各日、CM放映日、障害発生日、規程改定日',
  event_type STRING COMMENT 'イベント種別。HOLIDAY=祝日、SALE=セール、CAMPAIGN=販促施策、INCIDENT=障害・悪天候・規程改定',
  event_name STRING COMMENT 'イベント名称。祝日名、セール名、施策名、障害内容',
  channel STRING COMMENT '影響を受けるチャネル。ALL=全チャネル、EC=EC・アプリのみ、STORE=実店舗のみ',
  PRIMARY KEY (event_date, event_type)
) COMMENT '祝日・セール・キャンペーン・障害などのイベントカレンダー。売上変動の説明変数および売上予測モデルの特徴量として使う。日付×イベント種別の複合主キー';

CREATE TABLE sales_orders (
  order_id STRING COMMENT '注文ID。ORD+8桁の連番。同一ファイル内・再送ファイル間の重複判定キー',
  order_date DATE COMMENT '注文日。2024-04-01〜2026-12-31。深夜注文が翌日ファイルに入っても注文日は変わらない。不正データではスラッシュ区切り表記が混入する',
  store_id STRING COMMENT '計上店舗の店舗ID。実店舗注文は購入店舗、EC・アプリ注文は顧客のよく利用する店舗',
  channel STRING COMMENT '販売チャネル。STORE=実店舗、EC=ECサイト、APP=スマホアプリ(2026-07-01リリース以降のみ出現)',
  customer_id STRING COMMENT '購入顧客の顧客ID。必ず値が入る。不正データでは前後に空白が混入する',
  product_id STRING COMMENT '購入商品の商品ID。不正データでは商品マスタに存在しない値(P9999等)が混入する',
  quantity BIGINT COMMENT '購入数量。1が約75%。ギフト需要期は2以上の比率が上がる。不正データでは空や''N/A''が混入する',
  unit_price BIGINT COMMENT '税込の販売単価(円)。セール・在庫処分では定価から値引きされるため、商品マスタの現在の定価とは一致しないことがある',
  order_ts TIMESTAMP COMMENT '注文日時(日本時間)。実店舗は11〜13時と17〜20時、EC・アプリは21〜23時にピーク。障害時間帯やCM放映直後の分析に使う',
  point_used BIGINT COMMENT '使用ポイント。POSベンダーの仕様変更により2026-07-07到着分から末尾に追加された列。それ以前の行は空、追加後は約85%が0',
  source_file STRING COMMENT '取り込み元ファイル名(sales_YYYYMMDD.csv)。再送ファイル・送信漏れの遅延到着・日付跨ぎ注文の追跡に使う。注文日と一致しない場合がある',
  PRIMARY KEY (order_id),
  FOREIGN KEY (store_id) REFERENCES stores (store_id),
  FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
  FOREIGN KEY (product_id) REFERENCES products (product_id)
) COMMENT '売上明細。1行=1注文の1商品。実店舗・EC・アプリの全チャネルを含む。毎日1ファイル(sales_YYYYMMDD.csv)として翌日午前2時に到着する';

CREATE TABLE shipments (
  shipment_id STRING COMMENT '配送ID。SHP+8桁の連番',
  order_id STRING COMMENT '対象注文の注文ID。チャネルがEC/APPの注文のみが対象',
  shipped_date DATE COMMENT '出荷日。注文日の0〜2日後。連休中は減り、連休明けに集中する',
  delivered_date DATE COMMENT '配達完了日。出荷日の1〜3日後。年末や悪天候時は1〜2日延びる',
  carrier STRING COMMENT '配送会社名(架空3社)',
  delivery_prefecture STRING COMMENT '届け先の都道府県。顧客が引越した場合は変更後の都道府県になる',
  shipping_fee BIGINT COMMENT '税込送料(円)。注文金額が基準額以上で0円、未満で550円。基準額は5,000円だが2026-10-01以降は7,000円に改定',
  PRIMARY KEY (shipment_id),
  FOREIGN KEY (order_id) REFERENCES sales_orders (order_id)
) COMMENT '配送実績。EC・アプリ注文と1対1で対応する。毎日1ファイル(shipments_YYYYMMDD.csv)として、その日に出荷または配達された分が到着する';

CREATE TABLE web_events (
  event_id STRING COMMENT 'イベントID。UUID形式の一意なID',
  event_ts TIMESTAMP COMMENT 'イベント発生日時(日本時間)。夜間にピーク。平日より週末は昼間の比率が高い',
  event_type STRING COMMENT 'イベント種別。page_view=ページ閲覧、search=検索、add_to_cart=カート投入、purchase=購入。ファネル分析に使う',
  session_id STRING COMMENT 'セッションID。UUID形式。同一セッション内のイベントをまとめる単位',
  customer_id STRING COMMENT '閲覧した会員の顧客ID。非会員(未ログイン)の閲覧は空',
  device STRING COMMENT 'デバイス種別(旧キー user.device)。pc/sp/tablet。2026-04-27到着分までのみ値が入り、以降は空になる',
  device_type STRING COMMENT 'デバイス種別(新キー user.device_type)。2026-04-28到着分以降のみ値が入る。旧列だけを参照する処理ではNULLになる',
  app_version STRING COMMENT 'アプリのバージョン。2026-04-28以降、アプリ経由のアクセスにのみ値が入る。それ以外は空',
  viewed_product_id STRING COMMENT '閲覧対象の商品ID。商品ページ閲覧時に入る。商品別のPV推移(品質問題の兆候検知)に使う',
  page_url STRING COMMENT '閲覧ページのURLパス。商品ページは/products/{商品ID}の形式',
  page_referrer STRING COMMENT '参照元。search=検索、sns=SNS、direct=直接流入、mail=メール。CM放映直後はdirectとsearchが増える',
  search_query STRING COMMENT '検索語。イベント種別がsearchのときのみ値が入る。品質問題の発生時は「SNOW BUDS 充電」のような不具合関連の語が増える',
  item_count BIGINT COMMENT 'イベントに含まれる商品点数。add_to_cartとpurchaseのみ1〜3、それ以外は0',
  item1_product_id STRING COMMENT 'カート投入・購入商品1件目の商品ID。item_countが1以上のときのみ値が入る',
  item1_qty BIGINT COMMENT 'カート投入・購入商品1件目の数量',
  item2_product_id STRING COMMENT 'カート投入・購入商品2件目の商品ID。item_countが2以上のときのみ値が入る',
  item2_qty BIGINT COMMENT 'カート投入・購入商品2件目の数量',
  item3_product_id STRING COMMENT 'カート投入・購入商品3件目の商品ID。item_countが3のときのみ値が入る',
  item3_qty BIGINT COMMENT 'カート投入・購入商品3件目の数量',
  PRIMARY KEY (event_id),
  FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
  FOREIGN KEY (viewed_product_id) REFERENCES products (product_id),
  FOREIGN KEY (item1_product_id) REFERENCES products (product_id),
  FOREIGN KEY (item2_product_id) REFERENCES products (product_id),
  FOREIGN KEY (item3_product_id) REFERENCES products (product_id)
) COMMENT 'ECサイトのアクセスログ(元はJSON Lines形式を列に平坦化)。直近180日分。毎日1ファイル(weblog_YYYYMMDD.json)として到着する。2026-04-28のサイト改修でデバイス情報のキー名が変わっている';

CREATE TABLE inquiries (
  inquiry_id STRING COMMENT '問い合わせID。INQ+5桁の連番',
  received_at TIMESTAMP COMMENT '受付日時(日本時間)。2026年内。12月・1月は件数が約1.5倍に増える',
  customer_id STRING COMMENT '問い合わせ元顧客の顧客ID',
  order_id STRING COMMENT '対象注文の注文ID。注文に関する問い合わせのみ値が入り、それ以外は空',
  product_id STRING COMMENT '対象商品の商品ID。品質問題の発生時はP0001に集中する',
  channel STRING COMMENT '問い合わせ対象の購入チャネル。STORE/EC/APP',
  contact_method STRING COMMENT '問い合わせ手段。mail/form/phone/chat。phoneは平日日中、formとmailは夜間に多い',
  inquiry_text STRING COMMENT '問い合わせ本文(100〜300字の日本語)。トピックとトーンは本文の内容と一致させる。一部にお客様自身が書いた個人情報やAIへの指示を装った文が含まれる',
  topic STRING COMMENT '問い合わせトピック。配送の遅れ/商品の破損/返品・交換/サイズ・仕様の質問/支払い/店舗スタッフの対応/ポイント/その他。本文の内容と一致させる',
  tone STRING COMMENT '問い合わせの感情トーン。怒っている/困っている/落ち着いている/感謝している。本文の内容と一致させる',
  status STRING COMMENT '対応状況。OPEN=対応中、CLOSED=対応完了',
  closed_at TIMESTAMP COMMENT '対応完了日時(日本時間)。対応中の問い合わせは空。受付日時より後の値にする',
  contains_pii STRING COMMENT '本文に顧客自身が書いた個人情報が含まれるかの正解ラベル(評価用)。Y=含む(全体の約5%。電話番号50%・メール30%・住所20%)、N=含まない',
  injection_flag STRING COMMENT '本文にAIへの指示を装った文(プロンプトインジェクション)が含まれるかの正解ラベル(評価用)。Y=含む(全体で12件)、N=含まない',
  PRIMARY KEY (inquiry_id),
  FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
  FOREIGN KEY (order_id) REFERENCES sales_orders (order_id),
  FOREIGN KEY (product_id) REFERENCES products (product_id)
) COMMENT 'お客様からの問い合わせ。自然文の本文とトピック・トーンのラベルを持つ。月1回(inquiries_YYYYMM.csv)で到着する。テキストAIの要約・分類演習と、個人情報検出・プロンプトインジェクション耐性評価に使う';

CREATE TABLE event_attendees (
  attendee_id STRING COMMENT '来場者ID。ATT+5桁の連番',
  event_name STRING COMMENT 'イベント名称',
  event_date DATE COMMENT 'イベント開催日。2026年内',
  store_id STRING COMMENT '開催店舗の店舗ID',
  last_name STRING COMMENT '来場者の姓。既存顧客でも旧姓で記入され氏名が一致しないケースがある',
  first_name STRING COMMENT '来場者の名',
  full_name STRING COMMENT '来場者氏名。姓と名を半角スペースで連結した表記',
  email STRING COMMENT '来場者が記入したメールアドレス。既存顧客の場合は顧客マスタのアドレスに大文字混在・前後空白・全角文字などの表記ゆれを加えた値になる',
  prefecture STRING COMMENT '来場者の居住都道府県',
  survey_score BIGINT COMMENT 'アンケート満足度スコア。1(不満)〜5(満足)',
  matched_customer_id STRING COMMENT '名寄せの正解となる顧客ID(評価用)。既存顧客の場合のみ値が入り、新規来場者(約30%)は空',
  email_variant_type STRING COMMENT 'メールアドレスの表記ゆれ種別(評価用)。exact=完全一致、uppercase=大文字混在、space=前後空白、fullwidth=全角混在、new=新規(顧客マスタに存在しない)',
  PRIMARY KEY (attendee_id),
  FOREIGN KEY (store_id) REFERENCES stores (store_id),
  FOREIGN KEY (matched_customer_id) REFERENCES customers (customer_id)
) COMMENT '店頭イベントの来場者リスト。約70%は既存顧客だがメールアドレスに表記ゆれがあり、単純一致では名寄せできない。月1回(event_attendees_YYYYMM.csv)で到着する';
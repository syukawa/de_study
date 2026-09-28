CREATE TABLE stores (
  store_id VARCHAR(255),
  region VARCHAR(255),
  prefecture VARCHAR(255),
  city VARCHAR(255),
  store_name VARCHAR(255),
  store_type VARCHAR(255),
  floor_area_sqm BIGINT,
  open_date DATE,
  close_date DATE,
  PRIMARY KEY (store_id)
);

CREATE TABLE products (
  product_id VARCHAR(255),
  category_l VARCHAR(255),
  category_m VARCHAR(255),
  product_name VARCHAR(255),
  tax_rate DOUBLE PRECISION,
  list_price BIGINT,
  cost_price BIGINT,
  launch_date DATE,
  discontinued_date DATE,
  ec_only VARCHAR(255),
  PRIMARY KEY (product_id)
);

CREATE TABLE employees (
  employee_id VARCHAR(255),
  last_name VARCHAR(255),
  first_name VARCHAR(255),
  full_name VARCHAR(255),
  email VARCHAR(255),
  department VARCHAR(255),
  title VARCHAR(255),
  hire_date DATE,
  retire_date DATE,
  PRIMARY KEY (employee_id)
);

CREATE TABLE customers (
  customer_id VARCHAR(255),
  last_name VARCHAR(255),
  first_name VARCHAR(255),
  full_name VARCHAR(255),
  full_name_kana VARCHAR(255),
  email VARCHAR(255),
  phone VARCHAR(255),
  postal_code VARCHAR(255),
  prefecture VARCHAR(255),
  address_line VARCHAR(255),
  birth_date DATE,
  gender VARCHAR(255),
  registered_at TIMESTAMP,
  member_rank VARCHAR(255),
  mail_opt_in VARCHAR(255),
  home_store_id VARCHAR(255),
  status VARCHAR(255),
  merged_into VARCHAR(255),
  updated_at TIMESTAMP,
  PRIMARY KEY (customer_id),
  FOREIGN KEY (home_store_id) REFERENCES stores (store_id)
);

CREATE TABLE area_assignments (
  employee_id VARCHAR(255),
  region VARCHAR(255),
  valid_from DATE,
  valid_to DATE,
  PRIMARY KEY (employee_id, region, valid_from),
  FOREIGN KEY (employee_id) REFERENCES employees (employee_id)
);

CREATE TABLE calendar_events (
  event_date DATE,
  event_type VARCHAR(255),
  event_name VARCHAR(255),
  channel VARCHAR(255),
  PRIMARY KEY (event_date, event_type)
);

CREATE TABLE sales_orders (
  order_id VARCHAR(255),
  order_date DATE,
  store_id VARCHAR(255),
  channel VARCHAR(255),
  customer_id VARCHAR(255),
  product_id VARCHAR(255),
  quantity BIGINT,
  unit_price BIGINT,
  order_ts TIMESTAMP,
  point_used BIGINT,
  source_file VARCHAR(255),
  PRIMARY KEY (order_id),
  FOREIGN KEY (store_id) REFERENCES stores (store_id),
  FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
  FOREIGN KEY (product_id) REFERENCES products (product_id)
);

CREATE TABLE shipments (
  shipment_id VARCHAR(255),
  order_id VARCHAR(255),
  shipped_date DATE,
  delivered_date DATE,
  carrier VARCHAR(255),
  delivery_prefecture VARCHAR(255),
  shipping_fee BIGINT,
  PRIMARY KEY (shipment_id),
  FOREIGN KEY (order_id) REFERENCES sales_orders (order_id)
);

CREATE TABLE web_events (
  event_id VARCHAR(255),
  event_ts TIMESTAMP,
  event_type VARCHAR(255),
  session_id VARCHAR(255),
  customer_id VARCHAR(255),
  device VARCHAR(255),
  device_type VARCHAR(255),
  app_version VARCHAR(255),
  viewed_product_id VARCHAR(255),
  page_url VARCHAR(255),
  page_referrer VARCHAR(255),
  search_query VARCHAR(255),
  item_count BIGINT,
  item1_product_id VARCHAR(255),
  item1_qty BIGINT,
  item2_product_id VARCHAR(255),
  item2_qty BIGINT,
  item3_product_id VARCHAR(255),
  item3_qty BIGINT,
  PRIMARY KEY (event_id),
  FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
  FOREIGN KEY (viewed_product_id) REFERENCES products (product_id),
  FOREIGN KEY (item1_product_id) REFERENCES products (product_id),
  FOREIGN KEY (item2_product_id) REFERENCES products (product_id),
  FOREIGN KEY (item3_product_id) REFERENCES products (product_id)
);

CREATE TABLE inquiries (
  inquiry_id VARCHAR(255),
  received_at TIMESTAMP,
  customer_id VARCHAR(255),
  order_id VARCHAR(255),
  product_id VARCHAR(255),
  channel VARCHAR(255),
  contact_method VARCHAR(255),
  inquiry_text VARCHAR(255),
  topic VARCHAR(255),
  tone VARCHAR(255),
  status VARCHAR(255),
  closed_at TIMESTAMP,
  contains_pii VARCHAR(255),
  injection_flag VARCHAR(255),
  PRIMARY KEY (inquiry_id),
  FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
  FOREIGN KEY (order_id) REFERENCES sales_orders (order_id),
  FOREIGN KEY (product_id) REFERENCES products (product_id)
);

CREATE TABLE event_attendees (
  attendee_id VARCHAR(255),
  event_name VARCHAR(255),
  event_date DATE,
  store_id VARCHAR(255),
  last_name VARCHAR(255),
  first_name VARCHAR(255),
  full_name VARCHAR(255),
  email VARCHAR(255),
  prefecture VARCHAR(255),
  survey_score BIGINT,
  matched_customer_id VARCHAR(255),
  email_variant_type VARCHAR(255),
  PRIMARY KEY (attendee_id),
  FOREIGN KEY (store_id) REFERENCES stores (store_id),
  FOREIGN KEY (matched_customer_id) REFERENCES customers (customer_id)
);

COMMENT ON COLUMN stores.store_id IS '店舗ID。S001〜S050の固定長コード';
COMMENT ON COLUMN stores.region IS '地域区分。関東/関西/中部/九州/東北。店舗IDのブロック(S001-015関東など)に対応する';
COMMENT ON COLUMN stores.prefecture IS '店舗所在地の都道府県。地域区分と矛盾しない値にする';
COMMENT ON COLUMN stores.city IS '店舗所在地の市区町村';
COMMENT ON COLUMN stores.store_name IS '店舗名。「スノー商事 ○○店」の形式';
COMMENT ON COLUMN stores.store_type IS '店舗形態。路面店/ショッピングセンター/駅ビル。週末の売上伸び率が形態により異なる';
COMMENT ON COLUMN stores.floor_area_sqm IS '売場面積(平方メートル)。300〜3000。店舗別売上規模の按分に使う';
COMMENT ON COLUMN stores.open_date IS '開店日。この日より前に当該店舗の売上は発生しない(S050は2025-10-01開店)';
COMMENT ON COLUMN stores.close_date IS '閉店日。営業中の店舗は空。S037は2026-08-31に閉店し以降の売上はない';
COMMENT ON TABLE stores IS '店舗マスタ。全国50店舗の所在地・店舗タイプ・売場面積・開閉店日を保持する。売上の地域別/店舗タイプ別分析の軸マスタ';
COMMENT ON COLUMN products.product_id IS '商品ID。P0001〜の固定長コード。毎月の新商品追加で連番が伸びる';
COMMENT ON COLUMN products.category_l IS '商品大分類。家電/キッチン/衣料/食品/日用品/インテリア。2026-04-01の分類見直しで一部商品が大分類をまたいで移動する';
COMMENT ON COLUMN products.category_m IS '商品中分類。大分類と矛盾しない値。2026-04-01に「調理家電」→「キッチン家電」等の改名・統合が入る';
COMMENT ON COLUMN products.product_name IS '商品名。自社ブランド「SNOW」を冠した商品名。P0001=ワイヤレスイヤホン SNOW BUDS、P0002=電気ケトル SNOW KETTLE 1.0L、P0003=ダウンジャケット SNOW DOWN は固定';
COMMENT ON COLUMN products.tax_rate IS '消費税率。標準は0.10、食品のみ軽減税率0.08';
COMMENT ON COLUMN products.list_price IS '税込の定価(円)。2025-04-01と2026-10-01の価格改定で食品・キッチン用品の約30%が5〜15%値上げされる(上書き)';
COMMENT ON COLUMN products.cost_price IS '税抜の原価(円)。定価より必ず低い値にする。粗利分析に使う';
COMMENT ON COLUMN products.launch_date IS '発売日。この日より前に当該商品の売上は発生しない。毎月1日に新商品5〜10点が追加される';
COMMENT ON COLUMN products.discontinued_date IS '販売終了日。販売中の商品は空。四半期ごと(1/1・4/1・7/1・10/1)に3〜5点設定され、以降の売上はない';
COMMENT ON COLUMN products.ec_only IS 'EC専売フラグ。Y=ECとアプリのみで販売、N=実店舗でも販売';
COMMENT ON TABLE products IS '商品マスタ。家電・キッチン・衣料・食品・日用品・インテリアの取扱商品。価格とカテゴリは履歴を持たず常に現在値で上書きされる(改定前の値は残らない)';
COMMENT ON COLUMN employees.employee_id IS '社員ID。E0001〜の固定長コード';
COMMENT ON COLUMN employees.last_name IS '社員の姓';
COMMENT ON COLUMN employees.first_name IS '社員の名';
COMMENT ON COLUMN employees.full_name IS '社員氏名。姓と名を半角スペースで連結した表記';
COMMENT ON COLUMN employees.email IS '社内メールアドレス。社員IDに対応する架空アドレス(example.jpドメイン)';
COMMENT ON COLUMN employees.department IS '所属部署。異動時は履歴を残さず上書きされる';
COMMENT ON COLUMN employees.title IS '役職。部長/マネージャー/リーダー/担当';
COMMENT ON COLUMN employees.hire_date IS '入社日。2026-04-01に新卒10名と中途1名(情報システム部)が入社する';
COMMENT ON COLUMN employees.retire_date IS '退職日。在籍中の社員は空。2026-03-31付で5名が退職する';
COMMENT ON TABLE employees IS '社員マスタ。所属部署・役職・在籍状況を保持する。部署異動は履歴を残さず上書きされるため、過去の所属は追跡できない';
COMMENT ON COLUMN customers.customer_id IS '顧客ID。C000001〜C020000の固定長コード。退会・統合・個人情報削除後も保持される不変キー';
COMMENT ON COLUMN customers.last_name IS '顧客の姓。旧姓のまま登録されているケースがあり名寄せの難所になる';
COMMENT ON COLUMN customers.first_name IS '顧客の名';
COMMENT ON COLUMN customers.full_name IS '顧客氏名。姓と名を半角スペースで連結した表記。個人情報削除依頼を受けた顧客は空になる';
COMMENT ON COLUMN customers.full_name_kana IS '顧客氏名のカナ表記。個人情報削除依頼を受けた顧客は空になる';
COMMENT ON COLUMN customers.email IS 'メールアドレス。user+顧客番号の架空アドレス(example.comドメイン)。重複登録された顧客では大文字小文字の違いが生じる';
COMMENT ON COLUMN customers.phone IS '電話番号。重複登録の同一人物判定に使える(氏名+電話番号が一致)';
COMMENT ON COLUMN customers.postal_code IS '郵便番号。引越しで変更される';
COMMENT ON COLUMN customers.prefecture IS '居住都道府県。引越しで変更されるため、過去売上を現住所で集計すると当時の地域別実績と一致しない';
COMMENT ON COLUMN customers.address_line IS '市区町村以下の住所。個人情報削除依頼を受けた顧客は空になる';
COMMENT ON COLUMN customers.birth_date IS '生年月日。18〜80歳の範囲。年代別分析(アプリ利用は20〜30代が中心)に使う';
COMMENT ON COLUMN customers.gender IS '性別。M=男性、F=女性、U=未回答';
COMMENT ON COLUMN customers.registered_at IS '会員登録日時(日本時間)。この日時以前の注文は発生しない';
COMMENT ON COLUMN customers.member_rank IS '会員ランク。REGULAR/SILVER/GOLD。毎年4/1に前年度購入金額で見直され約15%が変動する(上位8%=GOLD、次の22%=SILVER)';
COMMENT ON COLUMN customers.mail_opt_in IS 'メール配信同意フラグ。Y=同意、N=非同意';
COMMENT ON COLUMN customers.home_store_id IS 'よく利用する店舗の店舗ID。EC・アプリ注文の計上店舗にもなる。閉店や引越しで付け替えられる';
COMMENT ON COLUMN customers.status IS '顧客状態。ACTIVE=有効、WITHDRAWN=退会(以降の注文なし)、MERGED=重複登録として統合済み';
COMMENT ON COLUMN customers.merged_into IS '統合先の顧客ID。重複登録が2026-11-01に統合された際、新しい側のレコードに統合先(古い側)のIDが入る。通常は空';
COMMENT ON COLUMN customers.updated_at IS '最終更新日時(日本時間)。住所変更・ランク更新・退会・統合・個人情報削除のたびに更新される。マスタ差分取り込みの基準列';
COMMENT ON TABLE customers IS '顧客マスタ(個人情報を含む)。氏名・連絡先・住所・会員ランク・在籍状況を保持する日次スナップショット。変更があった日に全件が届き、変更行はupdated_atが更新される';
COMMENT ON COLUMN area_assignments.employee_id IS '担当社員の社員ID。営業本部所属の社員のみ';
COMMENT ON COLUMN area_assignments.region IS '担当地域。関東/関西/中部/九州/東北。店舗マスタのregionと同じ区分';
COMMENT ON COLUMN area_assignments.valid_from IS '担当開始日。2026-10-01の組織変更で新しい担当行が追加される';
COMMENT ON COLUMN area_assignments.valid_to IS '担当終了日。担当中は空。中部の前任者は2026-09-30で担当を外れる';
COMMENT ON TABLE area_assignments IS '営業本部社員のエリア担当履歴。社員×地域×担当開始日を複合主キーとする有効期間型の履歴テーブル。過去行は削除せず、担当終了時はvalid_toを設定する';
COMMENT ON COLUMN calendar_events.event_date IS 'イベント発生日。2024〜2026年の日本の祝日、セール期間の各日、CM放映日、障害発生日、規程改定日';
COMMENT ON COLUMN calendar_events.event_type IS 'イベント種別。HOLIDAY=祝日、SALE=セール、CAMPAIGN=販促施策、INCIDENT=障害・悪天候・規程改定';
COMMENT ON COLUMN calendar_events.event_name IS 'イベント名称。祝日名、セール名、施策名、障害内容';
COMMENT ON COLUMN calendar_events.channel IS '影響を受けるチャネル。ALL=全チャネル、EC=EC・アプリのみ、STORE=実店舗のみ';
COMMENT ON TABLE calendar_events IS '祝日・セール・キャンペーン・障害などのイベントカレンダー。売上変動の説明変数および売上予測モデルの特徴量として使う。日付×イベント種別の複合主キー';
COMMENT ON COLUMN sales_orders.order_id IS '注文ID。ORD+8桁の連番。同一ファイル内・再送ファイル間の重複判定キー';
COMMENT ON COLUMN sales_orders.order_date IS '注文日。2024-04-01〜2026-12-31。深夜注文が翌日ファイルに入っても注文日は変わらない。不正データではスラッシュ区切り表記が混入する';
COMMENT ON COLUMN sales_orders.store_id IS '計上店舗の店舗ID。実店舗注文は購入店舗、EC・アプリ注文は顧客のよく利用する店舗';
COMMENT ON COLUMN sales_orders.channel IS '販売チャネル。STORE=実店舗、EC=ECサイト、APP=スマホアプリ(2026-07-01リリース以降のみ出現)';
COMMENT ON COLUMN sales_orders.customer_id IS '購入顧客の顧客ID。必ず値が入る。不正データでは前後に空白が混入する';
COMMENT ON COLUMN sales_orders.product_id IS '購入商品の商品ID。不正データでは商品マスタに存在しない値(P9999等)が混入する';
COMMENT ON COLUMN sales_orders.quantity IS '購入数量。1が約75%。ギフト需要期は2以上の比率が上がる。不正データでは空や''N/A''が混入する';
COMMENT ON COLUMN sales_orders.unit_price IS '税込の販売単価(円)。セール・在庫処分では定価から値引きされるため、商品マスタの現在の定価とは一致しないことがある';
COMMENT ON COLUMN sales_orders.order_ts IS '注文日時(日本時間)。実店舗は11〜13時と17〜20時、EC・アプリは21〜23時にピーク。障害時間帯やCM放映直後の分析に使う';
COMMENT ON COLUMN sales_orders.point_used IS '使用ポイント。POSベンダーの仕様変更により2026-07-07到着分から末尾に追加された列。それ以前の行は空、追加後は約85%が0';
COMMENT ON COLUMN sales_orders.source_file IS '取り込み元ファイル名(sales_YYYYMMDD.csv)。再送ファイル・送信漏れの遅延到着・日付跨ぎ注文の追跡に使う。注文日と一致しない場合がある';
COMMENT ON TABLE sales_orders IS '売上明細。1行=1注文の1商品。実店舗・EC・アプリの全チャネルを含む。毎日1ファイル(sales_YYYYMMDD.csv)として翌日午前2時に到着する';
COMMENT ON COLUMN shipments.shipment_id IS '配送ID。SHP+8桁の連番';
COMMENT ON COLUMN shipments.order_id IS '対象注文の注文ID。チャネルがEC/APPの注文のみが対象';
COMMENT ON COLUMN shipments.shipped_date IS '出荷日。注文日の0〜2日後。連休中は減り、連休明けに集中する';
COMMENT ON COLUMN shipments.delivered_date IS '配達完了日。出荷日の1〜3日後。年末や悪天候時は1〜2日延びる';
COMMENT ON COLUMN shipments.carrier IS '配送会社名(架空3社)';
COMMENT ON COLUMN shipments.delivery_prefecture IS '届け先の都道府県。顧客が引越した場合は変更後の都道府県になる';
COMMENT ON COLUMN shipments.shipping_fee IS '税込送料(円)。注文金額が基準額以上で0円、未満で550円。基準額は5,000円だが2026-10-01以降は7,000円に改定';
COMMENT ON TABLE shipments IS '配送実績。EC・アプリ注文と1対1で対応する。毎日1ファイル(shipments_YYYYMMDD.csv)として、その日に出荷または配達された分が到着する';
COMMENT ON COLUMN web_events.event_id IS 'イベントID。UUID形式の一意なID';
COMMENT ON COLUMN web_events.event_ts IS 'イベント発生日時(日本時間)。夜間にピーク。平日より週末は昼間の比率が高い';
COMMENT ON COLUMN web_events.event_type IS 'イベント種別。page_view=ページ閲覧、search=検索、add_to_cart=カート投入、purchase=購入。ファネル分析に使う';
COMMENT ON COLUMN web_events.session_id IS 'セッションID。UUID形式。同一セッション内のイベントをまとめる単位';
COMMENT ON COLUMN web_events.customer_id IS '閲覧した会員の顧客ID。非会員(未ログイン)の閲覧は空';
COMMENT ON COLUMN web_events.device IS 'デバイス種別(旧キー user.device)。pc/sp/tablet。2026-04-27到着分までのみ値が入り、以降は空になる';
COMMENT ON COLUMN web_events.device_type IS 'デバイス種別(新キー user.device_type)。2026-04-28到着分以降のみ値が入る。旧列だけを参照する処理ではNULLになる';
COMMENT ON COLUMN web_events.app_version IS 'アプリのバージョン。2026-04-28以降、アプリ経由のアクセスにのみ値が入る。それ以外は空';
COMMENT ON COLUMN web_events.viewed_product_id IS '閲覧対象の商品ID。商品ページ閲覧時に入る。商品別のPV推移(品質問題の兆候検知)に使う';
COMMENT ON COLUMN web_events.page_url IS '閲覧ページのURLパス。商品ページは/products/{商品ID}の形式';
COMMENT ON COLUMN web_events.page_referrer IS '参照元。search=検索、sns=SNS、direct=直接流入、mail=メール。CM放映直後はdirectとsearchが増える';
COMMENT ON COLUMN web_events.search_query IS '検索語。イベント種別がsearchのときのみ値が入る。品質問題の発生時は「SNOW BUDS 充電」のような不具合関連の語が増える';
COMMENT ON COLUMN web_events.item_count IS 'イベントに含まれる商品点数。add_to_cartとpurchaseのみ1〜3、それ以外は0';
COMMENT ON COLUMN web_events.item1_product_id IS 'カート投入・購入商品1件目の商品ID。item_countが1以上のときのみ値が入る';
COMMENT ON COLUMN web_events.item1_qty IS 'カート投入・購入商品1件目の数量';
COMMENT ON COLUMN web_events.item2_product_id IS 'カート投入・購入商品2件目の商品ID。item_countが2以上のときのみ値が入る';
COMMENT ON COLUMN web_events.item2_qty IS 'カート投入・購入商品2件目の数量';
COMMENT ON COLUMN web_events.item3_product_id IS 'カート投入・購入商品3件目の商品ID。item_countが3のときのみ値が入る';
COMMENT ON COLUMN web_events.item3_qty IS 'カート投入・購入商品3件目の数量';
COMMENT ON TABLE web_events IS 'ECサイトのアクセスログ(元はJSON Lines形式を列に平坦化)。直近180日分。毎日1ファイル(weblog_YYYYMMDD.json)として到着する。2026-04-28のサイト改修でデバイス情報のキー名が変わっている';
COMMENT ON COLUMN inquiries.inquiry_id IS '問い合わせID。INQ+5桁の連番';
COMMENT ON COLUMN inquiries.received_at IS '受付日時(日本時間)。2026年内。12月・1月は件数が約1.5倍に増える';
COMMENT ON COLUMN inquiries.customer_id IS '問い合わせ元顧客の顧客ID';
COMMENT ON COLUMN inquiries.order_id IS '対象注文の注文ID。注文に関する問い合わせのみ値が入り、それ以外は空';
COMMENT ON COLUMN inquiries.product_id IS '対象商品の商品ID。品質問題の発生時はP0001に集中する';
COMMENT ON COLUMN inquiries.channel IS '問い合わせ対象の購入チャネル。STORE/EC/APP';
COMMENT ON COLUMN inquiries.contact_method IS '問い合わせ手段。mail/form/phone/chat。phoneは平日日中、formとmailは夜間に多い';
COMMENT ON COLUMN inquiries.inquiry_text IS '問い合わせ本文(100〜300字の日本語)。トピックとトーンは本文の内容と一致させる。一部にお客様自身が書いた個人情報やAIへの指示を装った文が含まれる';
COMMENT ON COLUMN inquiries.topic IS '問い合わせトピック。配送の遅れ/商品の破損/返品・交換/サイズ・仕様の質問/支払い/店舗スタッフの対応/ポイント/その他。本文の内容と一致させる';
COMMENT ON COLUMN inquiries.tone IS '問い合わせの感情トーン。怒っている/困っている/落ち着いている/感謝している。本文の内容と一致させる';
COMMENT ON COLUMN inquiries.status IS '対応状況。OPEN=対応中、CLOSED=対応完了';
COMMENT ON COLUMN inquiries.closed_at IS '対応完了日時(日本時間)。対応中の問い合わせは空。受付日時より後の値にする';
COMMENT ON COLUMN inquiries.contains_pii IS '本文に顧客自身が書いた個人情報が含まれるかの正解ラベル(評価用)。Y=含む(全体の約5%。電話番号50%・メール30%・住所20%)、N=含まない';
COMMENT ON COLUMN inquiries.injection_flag IS '本文にAIへの指示を装った文(プロンプトインジェクション)が含まれるかの正解ラベル(評価用)。Y=含む(全体で12件)、N=含まない';
COMMENT ON TABLE inquiries IS 'お客様からの問い合わせ。自然文の本文とトピック・トーンのラベルを持つ。月1回(inquiries_YYYYMM.csv)で到着する。テキストAIの要約・分類演習と、個人情報検出・プロンプトインジェクション耐性評価に使う';
COMMENT ON COLUMN event_attendees.attendee_id IS '来場者ID。ATT+5桁の連番';
COMMENT ON COLUMN event_attendees.event_name IS 'イベント名称';
COMMENT ON COLUMN event_attendees.event_date IS 'イベント開催日。2026年内';
COMMENT ON COLUMN event_attendees.store_id IS '開催店舗の店舗ID';
COMMENT ON COLUMN event_attendees.last_name IS '来場者の姓。既存顧客でも旧姓で記入され氏名が一致しないケースがある';
COMMENT ON COLUMN event_attendees.first_name IS '来場者の名';
COMMENT ON COLUMN event_attendees.full_name IS '来場者氏名。姓と名を半角スペースで連結した表記';
COMMENT ON COLUMN event_attendees.email IS '来場者が記入したメールアドレス。既存顧客の場合は顧客マスタのアドレスに大文字混在・前後空白・全角文字などの表記ゆれを加えた値になる';
COMMENT ON COLUMN event_attendees.prefecture IS '来場者の居住都道府県';
COMMENT ON COLUMN event_attendees.survey_score IS 'アンケート満足度スコア。1(不満)〜5(満足)';
COMMENT ON COLUMN event_attendees.matched_customer_id IS '名寄せの正解となる顧客ID(評価用)。既存顧客の場合のみ値が入り、新規来場者(約30%)は空';
COMMENT ON COLUMN event_attendees.email_variant_type IS 'メールアドレスの表記ゆれ種別(評価用)。exact=完全一致、uppercase=大文字混在、space=前後空白、fullwidth=全角混在、new=新規(顧客マスタに存在しない)';
COMMENT ON TABLE event_attendees IS '店頭イベントの来場者リスト。約70%は既存顧客だがメールアドレスに表記ゆれがあり、単純一致では名寄せできない。月1回(event_attendees_YYYYMM.csv)で到着する';
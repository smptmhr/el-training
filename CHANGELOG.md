# Change Log

## [1.10.0] - 2022-03-29
### Added
- ステップ8: SQLインジェクションについてサポーターに説明する課題を追加しました

### Changed
- ステップ3: rails new する際に不要な機能を入れないようにレビューで確認・助言できるようにしたいので、このステップからPRを出すようにしました
- ステップ4: 「モデル図」ではなく「テーブル図」を作っていただきたいので、「テーブル図」という表現に変更しました
- ステップ4: 「モデル名・カラム名・データ型」という表現だと、これ以外の項目（制約や役割など）を考慮する余地を狭めてしまうので、文言を修正しました
- ステップ4: README.md に記載したあとの指示が抜けているとそのまま main に push してしまう例も見られたのでレビューに出して貰うように明記しました
- ステップ6: Circle CI の初期設定はサポーターが実施することを勧めるように明記しました
- ステップ7: 「HTTPでどのようなやり取りが行われているかを把握すること」がこの設問の意図でしたが、「Railsのルーティングの仕組みについて把握すること」を意図だと思われてしまうことがことあったため、説明を修正しました
- ステップ11: 想定しているロケールファイルの配置が行われやすくなるように文言を修正しました
- ステップ14: デフォルトブランチ名を master から main に変更
- ステップ14: Herokuアカウントの登録するときのメアドは会社・個人どちらでも良いことを明記しました

## [1.9.0] - 2021-02-25
### Added
- ステップ6へRuboCopを導入するステップを追加しました

### Changed
- RuboCopの導入がステップ6に入ったのに伴い、以降のステップ番号を整理しました
- CIツールの導入について「Circle CIなど」と記載していた箇所を、「Circle CI」のみに改めました

### Fixed
- 1.8.0 の CHANGELOG の表記内容を マンダリン語 -> マンダリン に修正

## [1.8.0] - 2020-01-29
### Added
- 開発するアプリの背景について検討してもらうフェーズを追加しました

### Changed
- メンター → サポーターに名称を変更しました
- オプション要件を整理しました
- バリデーション・DB制約を追加するステップを整理しました

### Fixed
- マンダリン版の説明を修正しました

## [1.7.0] - 2019-02-06
### Added
- 本カリキュラムの推奨図書として "現場で使える Ruby on Rails 5速習実践ガイド" を追加しました
- オプション要件としてDockerによる開発環境の構築を追加しました
- SQLへの理解度を測るステップを追加しました
- Webアプリケーションへの理解度を測る項目を追加しました
### Changed
- feature spec についての記載を system spec に変更しました
- ステップ7の内容を複数のサブステップに分割しました
- i18nを導入するステップの内容を明確化しました
- N+1についての記載をより適切なステップへ移動しました
### Fixed
- ステップ内の文章の語尾を統一しました
- 表記揺れを統一しました

## [1.6.1] - 2018-06-06
### Changed
- カリキュラム本文とトピックスのドキュメントを /docs 配下に移動しました
- README.md に本リポジトリの紹介と他言語対応してくださったリポジトリのリンクを追記しました（Thanks! @jodeci）

## [1.6] - 2018-04-20
### Changed
- ステップのタイトルをひと目見て何をするかを分かりやすくするため専門用語を削除しました
- ステップのタイトルの語尾を統一しました
- CI導入の優先度は高いとの判断の元、ステップ8の本文を一部変更しました

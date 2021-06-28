# Nibe

Nibeは、シンプルな会話ボットアプリケーションです。

## 準備

### 日本語 WordNetの用意

ユーザー入力から応答メッセージを決定する際、類義語を検索するために「[日本語 WordNet](http://compling.hss.ntu.edu.sg/wnja/)」を使用しています。

[日本語 WordNetライセンス](http://compling.hss.ntu.edu.sg/wnja/license.txt)

公式サイトより、WordNetのデータベースをダウンロードしてプロジェクトルートディレクトリに配置してください。   

### ライブラリのインストール

ユーザー入力を形態素解析するためにMecabを使用しているため、Mecabとライブラリのインストールをする必要があります。
また、WordNetにアクセスするためにSQLiteのライブラリを使用するため、こちらもインストールする必要があります。
以下はインストール方法の例です。

#### macOS

```bash
$ brew install mecab
$ brew install mecab-ipadic
```

#### Ubuntu

```bash
$ apt install mecab libmecab-dev mecab-ipadic-utf8
$ apt install sqlite3 libsqlite3-dev
```

### キャラクター画像の用意

キャラクターの画像を `frontend/assets/character.png` に配置してください。
推奨サイズは `960x720px` です。

### フッターの作成

フッターコンポーネントを `frontend/components/development/footer.vue` を参考に `frontend/components/production/footer.vue` に作成してください。

### Configの作成

`Config/production`に`config.json`を作成し、設定を書いてください。`Config/development/config.json`をコピーして変更が必要な項目のみ書き換えると楽です。

|項目|説明|
|:--|:--|
|bot.name|botの名前です。メッセージウィンドウに表示されます|
|paths.public|静的ファイルを配置するディレクトリの相対パスです|
|paths.dictionary|辞書ファイルが配置されたディレクトリの相対パスです|
|paths.wordnetFile|日本語WordNetデータベースファイルの相対パスです|
|server.origin|サーバーのOriginです。CORSやWebSocketのアップグレード判定に使用されます|
|server.wsOrigin|WebソケットサーバーのOriginです。クライアントがサーバーに接続する際に使用します|
|server.maxClientConnections|WebSocketで接続可能なクライアント数の上限です|
|server.secureOnly|Cookieにsecure属性を付与する場合はtrueにします|
|server.mongoURI|MongoDBのURIです|

## ビルド

Dockerを用いない場合はサーバーとクライアントのビルド環境を用意する必要があります。
以下の環境で動作確認済みです。

- Swift 5.4
- node v12.18.0
- yarn 1.22.10

### サーバー

サーバーのビルドは実行時に行います

### クライアント

```bash
$ cd frontend
$ yarn install
$ yarn build
```

## 実行

### 初期化

`make setup`で辞書ファイルの初期化を行ってください。
リポジトリをクローン後、1度だけ実行してください。

### アプリケーション

```bash
$ swift run Run -e prod
```

`http://localhost:8080`にアクセスするとアプリケーションが表示されます。

### 辞書エディタ

辞書ファイルを編集するためのエディタも用意しています。

```bash
$ cd editor
$ yarn install
$ yarn start
```

`http://localhost:3000`にアクセスするとエディタが表示されます。   

エディタで編集した内容は`editor/dictionaries`に反映されます。
更新した後は、アプリケーションを再起動してください。


## Dockerを使う場合

`Docker`と`Docker Compose`がインストールされている場合、簡単にアプリケーションを起動できます。

### MongoURIの変更

`config.json`の`server.mongoURI`を`mongodb://mongo/nibe`に変更してください。

### 起動

`make up`でコンテナを立ち上げます。


## ライセンス

MITライセンスで配布しています。詳細はLICENSEファイルを参照してください。



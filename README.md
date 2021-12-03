# 導入

## Dockerの環境構築
```
sudo apt update
sudo apt install make
make install
```

# 実行関係

## レスキューの実行
* 基本
```
make rioneLauncher
```
* サーバやサンプルプログラムに更新があった場合
```
make build
make rioneLauncher
```
## 更新
```
make update
```

<!-- --- -->
# コマンド解説

## コンテナのビルド(キャッシュあり)
* サーバやパッケージを更新する際に使用
```
make build
```

## コンテナをキャッシュなしでビルド
* 時間がかかるので、不具合があった際などに使用
```
make rebuild
```
## 最新のDockerFileでビルド
```
make update
```

## コンテナの実行
* コンテナ内に入って何かするときに使用
* コンテナ内のデータはscore.csvを除いですべて破棄される
```
make run
```


## ソースコードをコンテナ内に同期
* make runによってコンテナが起動中に別の端末から実行
```
make sync
```

## root権限でコンテナに接続
* make runによってコンテナが起動中のみ有効
* デバッグ用
```
make connect
```

## Dockerオブジェクトの削除

```
make clean
```

## Dockerの環境構築
```
make install
```

# ファイル解説

* Docker関連
    * Dockerfile
    * docker-compose.yml
        - makefileを使用しているため、現状では使用していない
* それ以外
    * makefile
        - コンテナ操作のレシピ
    * rescue2docker.sh
        - レスキューのソースコードをDockerファイルの保存されているディレクトリへコピーするスクリプト
    * execRioneLauncherInDocker.sh
      * make rioneLauncherのコマンドを行う際に、Ctrl+Cを検知してコンテナを終了させるために使用

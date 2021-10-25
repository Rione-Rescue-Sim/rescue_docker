# 導入

## クローン
```
git clone https://github.com/taka0628/rescue_docker.git
```

## Dockerの環境構築
```
sudo apt update
sudo apt install make
make install
```

# 実行関係

## レスキューの実行
* ファイルに変更があった場合
```
make build
make run
bash rioneLauncher_2.2.2.sh 1
```
* サーバやサンプルプログラムに更新があった場合
```
make rebuild
make run
bash rioneLauncher_2.2.2.sh 1
```

<!-- --- -->
# コマンド解説

## コンテナのビルド(キャッシュあり)
```
make build
```

## コンテナをキャッシュなしでビルド
```
make rebuild
```

## コンテナの実行
```
make run
```

## ソースコードをコンテナ内に同期
```
make sync
```

## root権限でコンテナに接続

* コンテナ実行中のみ有効

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
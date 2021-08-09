# rescue_docker

## クローン
```
git clone https://github.com/taka0628/rescue_docker.git
```

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

## Dockerオブジェクトの削除
```
make clean
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
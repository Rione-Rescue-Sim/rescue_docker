FROM ubuntu:18.04

# ユーザーを作成
# ユーザ名はランチャーと依存関係にあるので変更する際はランチャー内のDOCKER_USER_NAMEも書き換えること
ARG DOCKER_USER_=RDocker

RUN apt-get update

# パッケージインストールで参照するサーバを日本サーバに変更
# デフォルトのサーバは遠いので通信速度が遅い
RUN apt-get install -y apt-utils\
	&& apt-get install -y perl\
	&& perl -p -i.bak -e 's%(deb(?:-src|)\s+)https?://(?!archive\.canonical\.com|security\.ubuntu\.com)[^\s]+%$1http://ftp.riken.jp/Linux/ubuntu/%' /etc/apt/sources.list \
	&& apt-get update

# ターミナルで日本語の出力を可能にするための設定
RUN apt-get install -y language-pack-ja\
	bash-completion\
	gnome-terminal
RUN locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:jp
ENV LC_ALL ja_JP.UTF-8
RUN update-locale LANG=ja_JP.UTF-8

# GUI出力のためのパッケージ
RUN apt-get install -y xterm && apt-get install -y x11-xserver-utils\
	dbus-x11\
	libcanberra-gtk*

# レスキュー実行のためのパッケージ
RUN apt-get install -y \
	curl \
	wget\
	git\
	openjdk-17-jdk\
	gnome-terminal\
	cron\
	gradle\
	bc\
	nano

ENV DIRPATH home/${DOCKER_USER_}
WORKDIR $DIRPATH

# RUN groupadd rescue
RUN useradd ${DOCKER_USER_}
RUN chown -R ${DOCKER_USER_} /${DIRPATH}

USER ${DOCKER_USER_}


# レスキューサーバの取得をタグから行うため、バージョンによってディレクトリ名が変わる。
# 以降のコード内でサーバのディレクトリ名を一致させるために作成
ENV RCRS_SREVER_NAME rcrs-server-2.0
# レスキューサーバをインストール
RUN wget -q https://github.com/roborescue/rcrs-server/archive/refs/tags/v2.0.tar.gz &&\
	tar xzf v2.0.tar.gz &&\
	rm v2.0.tar.gz &&\
	cd ${RCRS_SREVER_NAME} &&\
	./gradlew completeBuild &&\
	mkdir logs && cd logs && mkdir log

# サンプルコードをインストール
RUN wget -q https://github.com/roborescue/adf-sample-agent-java/archive/refs/tags/v4.0.tar.gz &&\
	tar xzf v4.0.tar.gz &&\
	rm v4.0.tar.gz &&\
	cd /${DIRPATH}/adf-sample-agent-java-4.0 && \
	./gradlew clean && \
	./gradlew build

# ランチャーを取得
RUN git clone https://github.com/Rione-Rescue-Sim/RioneLauncher.git &&\
	cd RioneLauncher &&\
	git pull &&\
	git checkout java17

USER root
RUN apt-get clean

#  ------------これ以降はビルド時にキャッシュを使用しない------------
# ビルド時に最低限必要な処理
ARG CACHEBUST=1
RUN echo CACHEBUST: $CACHEBUST

USER ${DOCKER_USER_}

# ホストのscore.csvをマウントするためにファイル作成
RUN cd /${DIRPATH}/RioneLauncher/ \
&&	touch score.csv

# コンテナ内でgnome-terminalを開くと出てくるdbusのエラーを解消
ENV NO_AT_BRIDGE 1

RUN cd /${DIRPATH}/RioneLauncher/ \
&&	git pull

# 起動時にはランチャーの実行が楽になるようにランチャーのあるディレクトリから始める
WORKDIR /${DIRPATH}/RioneLauncher
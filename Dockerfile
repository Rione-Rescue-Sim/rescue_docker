FROM ubuntu:18.04

# ユーザーを作成
# ユーザ名はランチャーと依存関係にあるので変更する際はランチャー内のDOCKER_USER_NAMEも書き換えること
ARG DOCKER_USER_=RDocker
ARG RescueSRC_=RIORescue

RUN apt-get update

# パッケージインストールで参照するサーバを日本サーバに変更
# デフォルトのサーバは遠いので通信速度が遅い
RUN apt-get install -y apt-utils && apt-get install -y perl\
  && perl -p -i.bak -e 's%(deb(?:-src|)\s+)https?://(?!archive\.canonical\.com|security\.ubuntu\.com)[^\s]+%$1http://jp.archive.ubuntu.com/ubuntu/%' /etc/apt/sources.list \
  && apt-get update

# ターミナルで日本語の出力を可能にするための設定
RUN apt-get install -y language-pack-ja && apt-get install -y bash-completion\
  gnome-terminal
RUN locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:jp
ENV LC_ALL ja_JP.UTF-8
RUN update-locale LANG=ja_JP.UTF-8

# GUI出力のためのパッケージ
RUN apt-get update
RUN apt-get install -y xterm && apt-get install -y x11-xserver-utils\
  dbus-x11\
  libcanberra-gtk*

# レスキュー実行のためのパッケージ
RUN apt-get update
RUN apt-get install -y curl && apt-get install -y wget\
  git\
  openjdk-11-jdk\
  gnome-terminal\
  cron\
  gradle\
  bc\
  nano

ENV DIRPATH $DOCKER_USER_
WORKDIR $DIRPATH

RUN groupadd rescue
RUN useradd -d /${DIRPATH} -m ${DIRPATH}
RUN chown -R ${DOCKER_USER_} /${DIRPATH}


# ./gradlew を実行するためのラッパーを生成
# これをしないとdockerfileからの./gradlewが実行できない
# RUN gradle wrapper

USER ${DOCKER_USER_}

# レスキューサーバをインストール
RUN git clone https://github.com/roborescue/rcrs-server.git
RUN cd /${DIRPATH}/rcrs-server && \
  ./gradlew clean && \
  ./gradlew completeBuild

# サンプルコードをインストール
RUN git clone https://github.com/roborescue/rcrs-adf-sample.git
RUN cd /${DIRPATH}/rcrs-adf-sample && \
  ./gradlew clean && \
  ./gradlew build

# ランチャーを取得
RUN git clone https://github.com/Rione-Rescue-Sim/RioneLauncher.git

#  ------------これ以降はビルド時にキャッシュを使用しない------------
# ビルド時に最低限必要な処理
ARG CACHEBUST=1
RUN echo CACHEBUST: $CACHEBUST

# Docker内でupgradeは避けたほうがいいと言われているが、rescueはウェブサーバでは無いのでupgradeを使う
USER root
RUN apt-get update && apt-get -y upgrade

# レスキューのソースコードをコンテナ内にコピー
RUN mkdir ${RescueSRC_}
COPY --chown=${DOCKER_USER_}:${DIRPATH} ${RescueSRC_} /${DIRPATH}/${RescueSRC_}

USER ${DOCKER_USER_}

# ホストのscore.csvをマウントするためにファイル作成
RUN cd /${DIRPATH}/RioneLauncher/ && \
  touch score.csv

# コンテナ内でgnome-terminalを開くと出てくるdbusのエラーを解消
ENV NO_AT_BRIDGE 1

RUN cd /${DIRPATH}/rcrs-server/ && \
  git pull && \
  cd /${DIRPATH}/rcrs-adf-sample/ && \
  git pull &&\
  cd /${DIRPATH}/RioneLauncher/ && \
  git pull

# 起動時にはランチャーの実行が楽になるようにランチャーのあるディレクトリから始める
WORKDIR /${DIRPATH}/RioneLauncher
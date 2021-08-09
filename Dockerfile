FROM ubuntu:18.04

ENV USE_NAME guest

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
  bc

ENV DIRPATH /root/guest
WORKDIR $DIRPATH

# RUN wget https://raw.githubusercontent.com/MiglyA/setup/master/Ubuntu_setup.sh
# RUN wget https://raw.githubusercontent.com/MiglyA/setup/master/rescue_setup.sh

# ./gradlew を実行するためのラッパーを生成
# これをしないとdockerfileからの./gradlewが実行できない
RUN gradle wrapper

# レスキューサーバをインストール
RUN git clone https://github.com/roborescue/rcrs-server.git
RUN cd /${DIRPATH}/rcrs-server && \
 ./gradlew clean && \
  ./gradlew completeBuild

# サンプルコードをインストール
RUN git clone https://github.com/roborescue/rcrs-adf-sample.git
RUN cd ${DIRPATH}/rcrs-adf-sample && \
  ./gradlew clean && \
  ./gradlew build

#  ------------これ以降はビルド時にキャッシュを使用しない------------
# 頻繁に更新される可能性が高いため
ARG CACHEBUST=1
RUN echo CACHEBUST: $CACHEBUST

# ランチャーを取得
RUN git clone https://github.com/taka0628/RioneLauncher.git

# レスキューのソースコードをコンテナ内にコピー
RUN mkdir rionerescue
COPY rionerescue ${DIRPATH}/rionerescue

# 起動時にはランチャーの実行が楽になるようにランチャーのあるディレクトリから始める
WORKDIR ${DIRPATH}/RioneLauncher
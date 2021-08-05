FROM ubuntu:18.04

ENV USE_NAME guest

RUN apt-get update
RUN apt-get install -y apt-utils && apt-get install -y perl\
  && perl -p -i.bak -e 's%(deb(?:-src|)\s+)https?://(?!archive\.canonical\.com|security\.ubuntu\.com)[^\s]+%$1http://jp.archive.ubuntu.com/ubuntu/%' /etc/apt/sources.list \
  && apt-get update

RUN apt-get install -y language-pack-ja && apt-get install -y bash-completion\
  gnome-terminal

RUN locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:jp
ENV LC_ALL ja_JP.UTF-8
# RUN echo 'eval `dbus-launch --sh-syntax`' >> /home/jetson/.bashrc

RUN apt-get install -y curl && apt-get install -y wget\
    git\
    openjdk-11-jre\
    gnome-terminal\
    cron\
    xterm\
    x11-xserver-utils\
    libcanberra-gtk*\
    gradle

WORKDIR /root/guest

RUN wget https://raw.githubusercontent.com/MiglyA/setup/master/Ubuntu_setup.sh
RUN wget https://raw.githubusercontent.com/MiglyA/setup/master/rescue_setup.sh
RUN git clone https://github.com/taka0628/RioneLauncher.git



RUN update-locale LANG=ja_JP.UTF-8
# RUN source /etc/bash_completion

# RUN export DISPLAY=:0
# RUN env | grep DISPLAY
# RUN xhost loal:


# CMD [ "/bin/sh" ]
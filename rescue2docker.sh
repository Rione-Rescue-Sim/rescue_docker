# !/bin/bash
RescueDirName=RIORescue
RescueDockerDirName=rescue_docker

pwd

current_path=$(pwd)
root_path=$(
    cd
    pwd
)

# レスキューソースコードを探索
cd
rescue_code_path=$(find -name ${RescueDirName} -type d 2>/dev/null | grep -v "rescue_docker" | grep -v ".local")
echo rescue_code_path: $rescue_code_path

# レスキューのコードをDockerファイルのあるディレクトリ内にコピー
if [[ -n $rescue_code_path ]]; then

    cd $rescue_code_path
    cd ..
    # rsync -avh --delete --exclude=.git $RescueDirName ${current_path}
    rsync -avh --delete $RescueDirName ${current_path}

else

    echo
    echo "[ERROR] $LINENO"
    echo "レスキューのソースコード(${RescueDirName})を発見できませんでした"
    echo
    exit 1

fi

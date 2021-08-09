# !/bin/bash
RescueDirName=rionerescue
RescueDockerDirName=rescue_docker

pwd

current_path=$(pwd)
root_path=$(cd;pwd)

# レスキューソースコードを探索
cd
rescue_code_path=$(find */$RescueDirName -maxdepth 1 -type d | head -1)
echo rescue_code_path: $rescue_code_path

# レスキューのコードをDockerファイルのあるディレクトリ内にコピー
if [[ -n $rescue_code_path ]]; then

    cd $rescue_code_path
    cd ..
    rsync -avh --delete $RescueDirName ${current_path}
    
fi


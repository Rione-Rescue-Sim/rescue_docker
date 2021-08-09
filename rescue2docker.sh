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

# dockerファイルを探索
cd
docker_file_path=$(find */$RescueDockerDirName -maxdepth 1 -type d | head -1)
echo docker_file_path: $docker_file_path

# レスキューのコードをDockerファイルのあるディレクトリ内にコピー
cd $rescue_code_path
cd ..
rsync -avh --delete $RescueDirName ${root_path}/${docker_file_path}

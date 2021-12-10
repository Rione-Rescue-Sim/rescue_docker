# !/bin/bash

pwd

current_path=$(pwd)
root_path=$(
    cd
    pwd
)

# レスキューソースコードを探索
cd
rescue_code_path=($(find ~/ -maxdepth 4 -type d -name ".*" -prune -o -type f -print | grep config/module.cfg | sed 's@/config/module.cfg@@g'))
echo rescue_code_path: ${rescue_code_path[@]}

# レスキューのコードをDockerファイルのあるディレクトリ内にコピー
if [[ ${#rescue_code_path[@]} -gt 0 ]]; then

	for item in "${rescue_code_path[@]}" ; do
		cd $item
		cd ..
		rsync -avh --delete ${item} ${current_path}
	done
    # cd $rescue_code_path
    # cd ..
    # rsync -avh --delete $RescueDirName ${current_path}

else

    echo
    echo "[ERROR] $LINENO"
    echo "レスキューのソースコードを発見できませんでした"
    echo
    exit 1

fi

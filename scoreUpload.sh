#!/bin/bash
set -euxo pipefail

# レスキューのスコアをgitにアップロードする

SCORE_FILE_NAME=$1

# エラーチェック
if [[ -z $(find ./ -name $SCORE_FILE_NAME -type f) ]]; then

    echo
    echo "[ERROR] $LINENO"
    echo -e "\t スコアファイルを見つけられません"
    echo -e "\t score file: ${SCORE_FILE_NAME}"
    echo
    exit 1

fi

git clone git@github.com:Rione-Rescue-Sim/score_storage.git
cp $SCORE_FILE_NAME score_storage/score-$(date '+%F+%T').csv

cd score_storage

git add .
git commit -m"スコアアップロード"
git push origin main
cd ..
rm -rf score_storage
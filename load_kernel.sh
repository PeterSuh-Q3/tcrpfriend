#!/bin/bash

# TCRP Friend 커널 이미지 다운로드 및 로딩 스크립트
RELEASE_URL="https://api.github.com/repos/PeterSuh-Q3/tcrpfriend/releases/tags/v0.0.0e"

# 필수 패키지 설치 확인
if ! command -v jq &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y jq
fi

# 커널 이미지 다운로드 함수
download_kernel_images() {
    echo "릴리즈 정보 조회 중..."
    ASSET_URLS=$(curl -sL $RELEASE_URL | jq -r '.assets[] | select(.name | test("bzImage-friend|initrd-friend")) | .browser_download_url')
    
    for FILE_URL in $ASSET_URLS; do
        echo "다운로드 진행: $(basename $FILE_URL)"
        curl -LOs --progress-bar $FILE_URL
    done
}

# 커널 로딩 준비 함수
prepare_kernel_loading() {
    if [[ -f "bzImage-friend" && -f "initrd-friend" ]]; then
        echo "커널 로딩 명령어:"
        echo -e "qemu-system-x86_64 -kernel bzImage-friend -initrd initrd-friend -append \"console=ttyS0\" -nographic\n"
    else
        echo "에러: 필요한 파일이 존재하지 않습니다." >&2
        exit 1
    fi
}

# 메인 실행 흐름
main() {
    download_kernel_images
    prepare_kernel_loading
}

main

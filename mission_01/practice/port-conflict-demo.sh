#!/usr/bin/env bash
# 트러블슈팅 #2 재현 화면용 스크립트: 이미 사용 중인 호스트(localhost) 포트로 매핑 -> 실패 -> 수정
# 사용: bash port-conflict-demo.sh   (실행 후 터미널 화면을 캡처)
# 사전 조건: Docker 실행 중, 이미지 my-web:1.0 (없으면 자동 빌드)
set -u
BUSY=${BUSY:-8099}     # 이미 사용 중인 호스트 포트
FREE=${FREE:-8100}     # 수정 후 사용할 포트
DIR="$(cd "$(dirname "$0")" && pwd)"

run() { printf '\n$ %s\n' "$*"; eval "$@" 2>&1 | sed 's/\(endpoint [a-z-]*\) ([0-9a-f]*)/\1 (...)/'; }

cleanup() { docker rm -f use-a use-b use-c >/dev/null 2>&1; }
cleanup
docker image inspect my-web:1.0 >/dev/null 2>&1 || docker build -q -t my-web:1.0 "$DIR/webapp" >/dev/null

echo "# 1) 호스트 포트 $BUSY 를 이미 사용 중인 컨테이너(use-a)"
run "docker run -d -p $BUSY:80 --name use-a my-web:1.0 | cut -c1-12"
run "ss -ltn | grep :$BUSY"

echo; echo "# 2) 같은 호스트 포트로 매핑 시도 -> 실패"
run "docker run -d -p $BUSY:80 --name use-b my-web:1.0"
run "docker ps -a --filter name=use- --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

echo; echo "# 3) 수정: 사용 중이 아닌 포트($FREE)로 매핑"
run "docker rm -f use-b"
run "docker run -d -p $FREE:80 --name use-c my-web:1.0 | cut -c1-12"
run "docker ps --filter name=use- --format 'table {{.Names}}\t{{.Ports}}'"
run "curl -sS http://localhost:$FREE"

cleanup
echo; echo "# (정리 완료: use-a, use-b, use-c 제거)"

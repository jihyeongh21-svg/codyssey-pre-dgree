# 내 컴퓨터에 개발자용 '작업실' 꾸미기

> Codyssey 올인원 1기 입학 연수 — Pre-course Dev Setup Mission

## 📌 프로젝트 개요

<!-- 미션 목표를 2~3문장으로 요약하세요. -->
- 터미널(CLI), Docker, Git/GitHub를 직접 세팅하여 재현 가능한 개발 워크스테이션을 구축한다.
- 이미지/컨테이너 분리, 포트·볼륨 연결 방식 등 컨테이너 환경의 구조적 원칙을 실습으로 검증한다.
- 모든 수행 과정과 검증 결과를 본 문서에서 확인할 수 있도록 기록한다.

---

## 1) 실행 환경

| 항목 | 값 |
|---|---|
| OS | Windows 11 Pro + WSL2 Ubuntu 24.04.5 LTS |
| Shell | bash (zsh + Oh My Zsh + Starship 설치 완료, 기본 쉘 전환 전) |
| 터미널 | VS Code 통합 터미널 (WSL: Ubuntu-24.04 연결) |
| Docker (또는 OrbStack) | Docker Desktop (WSL2 backend) — Docker version 29.9.2, build a82e528 |
| Git | git version 2.43.0 |

```bash
$ docker --version
Docker version 29.9.2, build a82e528

$ git --version
git version 2.43.0
```

---

## 2) 수행 체크리스트

- [x] 터미널 기본 조작 및 작업 디렉토리 구성
- [x] 파일/디렉토리 권한 확인 및 변경 실습
- [x] Docker 설치 및 데몬 동작 점검
- [x] Docker 기본 운영 명령 수행 (images / ps / logs / stats)
- [x] `hello-world`, `ubuntu` 컨테이너 실행 실습
- [x] Dockerfile 기반 웹 서버 컨테이너 빌드/실행
- [x] 포트 매핑 접속 확인 (2회 이상)
- [x] 브라우저 접속 스크린샷 (주소창 포함)
- [x] 바인드 마운트 변경 반영 검증
- [x] Docker 볼륨 영속성 검증 (컨테이너 삭제 전/후)
- [x] Git 사용자 정보 및 기본 브랜치 설정
- [x] GitHub SSH 키 등록 및 `ssh -T` 인증 확인
- [x] VSCode ↔ GitHub 로그인 스크린샷
- [x] 민감정보(토큰/비밀번호/개인키) 마스킹 최종 확인 (STEP 11)

---

## 3) 터미널 조작 로그

### 3-1. 작업 디렉토리 구성

```bash
$ pwd
# 현재 위치
/home/gkwlgud129430/codyssey-pre-dgree/mission01 ### 절대경로

$ mkdir -p ~/codyssey-pre-dgree/mission01/practice
$ cd ~/codyssey-pre-dgree/mission01/practice
$ ls -la ### 단순 파일 목록만 보기 옵션 제거 -la
# 결과
total 8
drwxr-xr-x 2 gkwlgud129430 gkwlgud129430 4096 Nov  4 15:07 .
drwxr-xr-x 3 gkwlgud129430 gkwlgud129430 4096 Nov  4 15:07 ..

```

### 3-2. 파일/디렉토리 생성·복사·이동·삭제

```bash
# 파일 생성
$ touch sample.txt
# 내용 삽입
$ echo "test" > sample.txt ### touch 명령어 과정 생략 가능
# 파일 내용 확인
$ cat sample.txt
# 결과
test


# 복사 / 이동·이름변경 / 삭제
$ cp sample.txt sample_copy.txt
$ mv sample_copy.txt renamed.txt ### 이동과  변경 동시 변경은 rename 따로 존재
$ ls
# 결과
rename.txt  sample.txt
$ rm renamed.txt
$ ls
# 결과
sample.txt
```

---

## 4) 권한 실습 및 증거 기록

<!-- 파일 1개, 디렉토리 1개에 대해 권한 변경 전/후를 비교하세요. -->

### 4-1. 파일 권한 변경

| 표기 | 의미 |
|---|---|
| `r` / `w` / `x` | 읽기 / 쓰기 / 실행   |
| `644` | 소유자 rw-, 그룹 r--, 기타 r-- |
| `755` | 소유자 rwx, 그룹 r-x, 기타 r-x |

*추가로 가장앞이 d 일경우 디렉토리 없을 경우 파일*

*파일종류(디렉토리/일반파일/소유자/그룹/기타 순으로 권한 표시*


```bash
$ ls -l sample.txt
# 변경 전 권한 (예: -rw-r--r--)
-rw-r--r-- 1 gkwlgud129430 gkwlgud129430 5 Nov  4 15:13 sample.tx
### 일반파일/읽기쓰기/읽기/읽기 -> 숫자 변환 644(4+2/4/4)  
$ chmod 444 sample.txt
$ ls -l sample.txt
# 변경 후 권한
-r--r--r-- 1 gkwlgud129430 gkwlgud129430 5 Nov  4 15:13 sample.txt
# 실제 쓰기 불가능 한지 확인
$ echo "test2" > sample.txt
# 결과
permission denied: sample.txt
# 다시 쓰기 권한 부여
$ chmod 644 sample.txt
$ ls -l sample.txt
$ echo "test2" > sample.txt
# 결과
-rw-r--r-- 1 gkwlgud129430 gkwlgud129430 6 Nov  4 15:53 sample.txt
test2

```


### 4-2. 디렉토리 권한 변경

```bash
$ ls -ld ~/codyssey-pre-dgree/mission01/practice
# 변경 전
drwxr-xr-x 2 gkwlgud129430 gkwlgud129430 4096 Nov  4 15:21 /home/gkwlgud129430/codyssey-pre-dgree/mission01/practice

$ chmod 555 ~/codyssey-pre-dgree/mission01/practice
$ ls -ld ~/codyssey-pre-dgree/mission01/practice
# 변경 후
dr-xr-xr-x 2 gkwlgud129430 gkwlgud129430 4096 Nov  4 15:21 /home/gkwlgud129430/codyssey-pre-dgree/mission01/practice
# 실제 쓰기 불가능 한지 확인 
$ touch test.txt  
# 결과
touch: cannot touch 'test.txt': Permission denied
```

---

## 5) Docker 설치 및 기본 점검

```bash
$ docker --version
# 결과
Docker version 29.9.2, build a82e52
$ docker info
# (또는 동등 점검 명령) 결과
 Version:    29.9.2
 Context:    desktop-linux
 Debug Mode: false
 ...
  Insecure Registries:
  hubproxy.docker.internal:5555
  127.0.0.0/8
  ::1/128
 Live Restore Enabled: false
 Firewall Backend: iptables
```

---

## 6) Docker 기본 운영 명령 수행

```bash
# 이미지
$ docker images
# 결과
IMAGE   ID             DISK USAGE   CONTENT SIZE   EXTRA
# 컨테이너 실행/중지/목록
$ docker ps
$ docker ps -a
# 결과 (hello-world, ubuntu-test 실행 후)
CONTAINER ID   IMAGE         COMMAND                   CREATED         STATUS                              PORTS     NAMES
3170f9ae3c9c   ubuntu        "bash -c 'ls; echo \"…"   1 second ago    Exited (0) Less than a second ago             ubuntu-test
589bbe87dcaf   hello-world   "/hello"                  7 seconds ago   Exited (0) 6 seconds ago                      distracted_wozniak

# 운영: 로그/리소스 (STEP 8의 my-web 컨테이너 실행 중)
$ docker logs my-web
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/11/10 00:45:45 [notice] 1#1: nginx/1.31.8
...
172.17.0.1 - - [10/Nov/2026:00:45:47 +0000] "GET / HTTP/1.1" 200 36 "-" "curl/8.5.0" "-"

$ docker stats --no-stream
CONTAINER ID   NAME      CPU %     MEM USAGE / LIMIT     MEM %     NET I/O         BLOCK I/O     PIDS
da97c4c13957   my-web    0.00%     21.59MiB / 15.25GiB   0.14%     1.76kB / 778B   0B / 8.19kB   25
```

---

## 7) 컨테이너 실행 실습

### 7-1. hello-world

```bash
$ docker run hello-world
# 결과
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

```

### 7-2. ubuntu 컨테이너 진입 및 명령 실행

```bash
$ docker run -it --name ubuntu-test ubuntu bash
# 컨테이너 내부
$ ls
# 결과
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var

$ echo "hello from container"
#결과
hello from container

$ exit
#결과
exit
\%
```

### 7-3. attach / exec 차이 정리

<!-- 직접 관찰한 내용을 간단히 정리하세요. -->
- `docker exec`: 실행 중인 컨테이너에 새 프로세스로 진입 (여러 세션 가능)
- `docker attach`: 컨테이너의 메인 프로세스(PID 1)에 직접 연결

---

## 8) 기존 Dockerfile 기반 커스텀 이미지 제작

- **선택한 기존 베이스**: `nginx:alpine` (경량 웹 서버 이미지)
- **적용한 커스텀 포인트**:
  1. `COPY site/ /usr/share/nginx/html/` — 기본 nginx 페이지를 직접 만든 정적 콘텐츠로 교체
  2. `ENV APP_ENV=dev`, `LABEL org.opencontainers.image.title` — 실행 모드 표시 및 이미지 메타데이터 부여

### Dockerfile

```dockerfile
FROM nginx:alpine
LABEL org.opencontainers.image.title="my-custom-nginx"
ENV APP_ENV=dev
COPY site/ /usr/share/nginx/html/
```

### 빌드/실행 결과

```bash
$ docker build -t my-web:1.0 .
#5 [1/2] FROM docker.io/library/nginx:alpine@sha256:713fc2eb...
#6 [2/2] COPY site/ /usr/share/nginx/html/
#7 naming to docker.io/library/my-web:1.0 done

$ docker run -d -p 8080:80 --name my-web my-web:1.0
da97c4c13957899efc90b4c474070898fc7c057e677c9329f05fd83319b3f7b8

$ curl http://localhost:8080
<h1>Hello from my custom image</h1>

$ docker ps
CONTAINER ID   IMAGE        COMMAND                  CREATED         STATUS         PORTS                                     NAMES
da97c4c13957   my-web:1.0   "/docker-entrypoint.…"   2 seconds ago   Up 2 seconds   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   my-web
```

---

## 9) 포트 매핑 및 접속 증거

```bash
$ docker rm -f my-web   # STEP 6의 컨테이너가 8080을 쓰고 있으므로 먼저 제거
$ docker run -d -p 8080:80 --name my-web-8080 my-web:1.0
$ curl http://localhost:8080
<h1>Hello from my custom image</h1>   # 결과 1

$ docker run -d -p 8081:80 --name my-web-8081 my-web:1.0
$ curl http://localhost:8081
<h1>Hello from my custom image</h1>   # 결과 2 (2회 접속 증거)

$ docker ps
CONTAINER ID   IMAGE        COMMAND                  CREATED         STATUS         PORTS                                     NAMES
230c6a032793   my-web:1.0   "/docker-entrypoint.…"   2 seconds ago   Up 2 seconds   0.0.0.0:8081->80/tcp, [::]:8081->80/tcp   my-web-8081
b9fbe47d2e94   my-web:1.0   "/docker-entrypoint.…"   2 seconds ago   Up 2 seconds   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   my-web-8080
```

> nginx는 컨테이너 내부 **80 포트**에서 대기하므로 매핑은 `호스트포트:80`입니다. (`:5000`은 Flask 등 다른 앱용)

![port-mapping-8080](./assets/port-mapping-8080.png)

![port-mapping-8081](./assets/port-mapping-8081.png)

---

## 10) 바인드 마운트 반영 + 볼륨 영속성 증거

### 10-1. 바인드 마운트

```bash
$ docker run -d -p 8082:80 -v $(pwd)/site:/usr/share/nginx/html --name bind-test nginx:alpine

# 변경 전
$ curl http://localhost:8082
<h1>Hello from my custom image</h1>

# 호스트에서 파일 변경
$ echo "<h1>updated content</h1>" > site/index.html
$ curl http://localhost:8082
<h1>updated content</h1>
# 컨테이너 재시작 없이 변경 반영됨
```

### 10-2. 볼륨 영속성

```bash
$ docker volume create mydata
$ docker run -d --name vol-test -v mydata:/data ubuntu sleep infinity
$ docker exec -it vol-test bash -lc "echo hi > /data/hello.txt && cat /data/hello.txt"
# hi

$ docker rm -f vol-test

# 컨테이너 삭제 후 재생성하여 데이터 유지 확인
$ docker run -d --name vol-test2 -v mydata:/data ubuntu sleep infinity
$ docker exec -it vol-test2 bash -lc "cat /data/hello.txt"
# hi (삭제 전/후 데이터 유지 확인)
```

---

## 11) Git 설정 및 GitHub/VSCode 연동

```bash
$ git config --global user.name "jihyeongh21-svg"
$ git config --global user.email "<이메일>"
$ git config --global init.defaultBranch main
$ git config --global --list
user.email=<이메일>
user.name=jihyeongh21-svg
init.defaultbranch=main
core.autocrlf=input

# GitHub SSH 인증 확인 (공개키만 등록, 개인키는 노출하지 않음)
$ ssh -T git@github.com
Hi jihyeongh21-svg! You've successfully authenticated, but GitHub does not provide shell access.
```

VSCode GitHub 로그인(계정 메뉴) 및 소스 제어/커밋 그래프:

![github-vscode](./assets/github-vscode.png)

---

## 12) 트러블슈팅 (2건 이상)

### 트러블슈팅 #1

- **문제**: <!-- wsl 터미널에서 permission denied 도커 조작 실패  -->
- **원인 가설**: <!-- 도커 설정에서 터미널에서 접급을 허용하는 옵션 비활성화  -->
- **확인**: <!-- docker desktop app 에서 설정 확인 -->
- **해결/대안**: <!-- 설정 활성화 후 wsl 완전 종료후 재실행 -->

### 트러블슈팅 #2

<!-- 직접 겪은 문제로 교체하세요. 아래는 작성 시 점검한 사전 확인 사항입니다. -->
- **문제(사전 점검)**: 초안의 포트 매핑이 `-p 8080:5000`으로 되어 있었음 (nginx는 80 포트 사용)
- **원인 가설**: 컨테이너 내부 포트(`:5000`)와 nginx 실제 listen 포트(80)가 불일치
- **확인**: nginx 기본 설정이 80 포트 listen, `docker ps`의 PORTS 열 확인
- **해결/대안**: `-p 8080:80`으로 수정. STEP 6의 `my-web`이 8080을 점유하므로 STEP 7 전에 `docker rm -f my-web` 필요

---

## 13) 보너스 과제 (선택)

- [ ] Docker Compose 기초 (`docker-compose.yml` 단일 서비스)
- [ ] Docker Compose 멀티 컨테이너 (웹 서버 + 보조 서비스 2개 이상, 네트워크 통신 확인)
- [ ] Compose 운영 명령어 (`up` / `down` / `ps` / `logs`)
- [ ] 환경 변수 활용 (포트/모드 변경)
- [ ] GitHub SSH 키 설정 및 동작 확인

---

## ⚠️ 보안 및 개인정보 보호

- 본 문서와 로그/스크린샷에는 토큰, 비밀번호, 개인키, 인증 코드 등이 포함되어 있지 않음을 확인했습니다.
- 민감정보가 노출된 경우 즉시 히스토리/문서에서 제거하고 재발급 절차를 수행했습니다. (해당 시)

### 보안 점검 로그

```bash
$ git log --oneline
d703e42 docs: mission01 실행 환경의 터미널 정보 기재
e160e27 docs: mission01 스크린샷 추가 및 README 이미지 연결
26fb3e6 docs: mission01 실습 결과 및 개념 정리 추가
...

$ grep -rniE "password|token|secret" . --include="*.md"
./mission01/CONCEPTS.md:131:- 점검: `git log --oneline`, `grep -ri "password\|token\|secret" . --include="*.md"`
# 점검 명령을 설명하는 문장만 일치 (실제 비밀값 없음)

$ grep -rnE "BEGIN [A-Z ]*PRIVATE KEY|AAAAC3NzaC1|ghp_|github_pat_" . --exclude-dir=.git
# 결과 없음 (개인키·공개키·토큰 패턴 없음)
```

- SSH 키는 저장소에 올리지 않았고, 개인키는 로컬 `~/.ssh`에만 존재 (GitHub에는 공개키만 등록)
- 스크린샷에는 GitHub 사용자 이름만 표시되고 토큰/인증 코드는 없음을 눈으로 확인
- Git 이메일은 README에 `<이메일>`로 마스킹함
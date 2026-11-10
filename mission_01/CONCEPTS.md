# Mission 01 — 개념 정리 (알아야 할 것들)

실습(`README.md`)에서 다룬 개념을 한곳에 모은 정리 노트입니다.

---

## 1. 터미널 / 경로

| 개념 | 설명 | 예 |
|---|---|---|
| 절대 경로 | 루트(`/`)부터 시작하는 전체 경로 | `/home/user/codyssey` |
| 상대 경로 | 현재 위치 기준 경로 | `./practice`, `../` |
| `~` | 홈 디렉토리 | `~/projects` |
| 숨김 파일 | 이름이 `.`으로 시작, `ls -a`로 표시 | `.gitignore` |

| 명령 | 용도 |
|---|---|
| `pwd` | 현재 절대 경로 출력 |
| `ls -la` | 숨김 포함 상세 목록 |
| `mkdir -p a/b` | 중간 경로까지 한 번에 생성 |
| `cp` / `mv` / `rm` | 복사 / 이동·이름변경 / 삭제 (`rm`은 휴지통 없음) |
| `cat` | 파일 내용 출력 |

- `>` 는 덮어쓰기, `>>` 는 이어쓰기입니다.

**절대/상대 경로 선택 기준**
- **스크립트, cron, Dockerfile의 마운트 경로**처럼 어디서 실행될지 모르는 곳은 **절대 경로**(또는 `$(pwd)`로 만든 절대 경로)를 쓴다. 실행 위치가 달라져도 같은 파일을 가리킨다.
- **WSL/Windows에서는 프로젝트를 WSL 홈(`~/...`)에 둔다.** `/mnt/c` 경로는 파일 I/O가 느리고 권한(`chmod`)이 제대로 반영되지 않는다.
- **프로젝트 폴더 안에서 손으로 작업할 때**는 **상대 경로**(`./site`, `../webapp`)가 짧고, 저장소를 다른 위치로 옮겨도 그대로 동작한다.
- `mv`는 같은 디렉토리 안에서 쓰면 이름 변경이 됩니다.

---

## 2. 파일 권한

`ls -l` 출력의 첫 열: `-rw-r--r--`

```
-  rw-  r--  r--
│   │    │    └─ 기타(others)
│   │    └────── 그룹(group)
│   └─────────── 소유자(owner)
└─────────────── 종류 (- 파일, d 디렉토리, l 링크)
```

- 숫자 표기: r=4, w=2, x=1 → 합산. `644` = rw- r-- r--, `755` = rwx r-x r-x
- **디렉토리의 x**는 "안으로 들어가기(cd) 가능"이라는 뜻입니다. w가 없으면 그 안에 파일을 만들거나 지울 수 없습니다.
| 숫자 | 표기 | 해석 | 주로 쓰는 곳 |
|---|---|---|---|
| `600` | `rw-------` | 소유자만 읽기/쓰기 | SSH 개인키, 비밀 설정 파일 |
| `644` | `rw-r--r--` | 소유자 읽기/쓰기, 나머지 읽기 | 일반 파일 기본값 |
| `755` | `rwxr-xr-x` | 소유자 모든 권한, 나머지 읽기/실행 | 실행 파일, 디렉토리 기본값 |
| `444` | `r--r--r--` | 모두 읽기 전용 | 쓰기 차단 확인, 보호할 파일 |
| `555` | `r-xr-xr-x` | 모두 읽기/실행 (쓰기 없음) | 쓰기를 막은 디렉토리 |

- **디렉토리 x 예시**: `chmod 644 dir`로 x를 빼면 `cd dir`이 거부된다(진입 불가). `chmod 555 dir`는 진입과 목록 조회는 되지만 `touch dir/a.txt`처럼 **파일 생성/삭제**는 w가 없어 거부된다.
- **root 계정 경고**: root는 이 권한 검사를 대부분 건너뛰므로 `444` 파일에도 쓸 수 있다. 권한 실습은 일반 사용자 계정에서 한다.
- **root 계정은 권한 검사를 대부분 무시합니다.** `chmod 444` 파일도 root는 쓸 수 있어서, 권한 실습은 일반 사용자 계정에서 해야 정확히 재현됩니다.

---

## 3. Docker 핵심 개념

### 이미지 vs 컨테이너
- **이미지**: 읽기 전용 템플릿 (레이어의 묶음). `docker images`
- **컨테이너**: 이미지를 실행한 프로세스 + 쓰기 가능한 얇은 레이어. `docker ps`
- 클래스와 인스턴스 관계와 비슷합니다. 하나의 이미지로 컨테이너를 여러 개 띄울 수 있습니다.
- 컨테이너를 지우면 그 안에서 쓴 데이터도 사라집니다(볼륨 제외).
- **빌드 캐시**: 같은 Dockerfile을 다시 빌드하면 바뀌지 않은 레이어는 `CACHED`로 재사용됩니다. `COPY`/`ADD`하는 파일 내용이나 지시어가 바뀌면 그 레이어부터 아래가 캐시 무효화되어 다시 만들어집니다. 처음부터 다시 빌드하려면 `docker build --no-cache`를 씁니다.
- **이미지를 다시 빌드해도 이미 실행 중인 컨테이너는 바뀌지 않습니다.** 컨테이너는 만들어질 때의 이미지를 계속 쓰므로, 새 이미지를 반영하려면 `docker rm -f`로 지우고 `docker run`으로 다시 만들어야 합니다(Compose는 `docker compose up -d --build`). 예: `site/index.html`을 고쳐 `my-web:1.0`을 재빌드해도 떠 있는 `my-web` 컨테이너는 옛 내용을 계속 보여 줍니다.

### 자주 쓰는 명령
| 명령 | 의미 |
|---|---|
| `docker run` | 이미지 pull(없으면) + 컨테이너 생성 + 실행 |
| `-d` | 백그라운드 실행 |
| `-it` | 대화형 터미널 (`-i` 입력 유지, `-t` TTY) |
| `--name` | 컨테이너 이름 지정 |
| `--rm` | 종료 시 자동 삭제 |
| `docker ps -a` | 종료된 컨테이너 포함 목록 |
| `docker logs <name>` | 표준 출력 로그 |
| `docker stats --no-stream` | CPU/메모리 스냅샷 |
| `docker rm -f` | 강제 삭제 |

### attach vs exec
- `exec`: 실행 중인 컨테이너 안에 **새 프로세스**를 띄움. 여러 개 가능하고, `exit`해도 컨테이너는 유지.
- `attach`: 컨테이너의 **메인 프로세스(PID 1)** 입출력에 연결. 메인 프로세스가 종료되면 컨테이너도 종료될 수 있음. 보통 디버깅에는 `exec`을 씁니다.

### Dockerfile
| 지시어 | 역할 |
|---|---|
| `FROM` | 베이스 이미지 |
| `LABEL` | 메타데이터 |
| `ENV` | 환경 변수 (빌드 + 실행 시 모두 유효) |
| `COPY` | 호스트 파일을 이미지로 복사 |
| `RUN` | 빌드 중 명령 실행 (레이어 생성) |
| `CMD` | 컨테이너 기본 실행 명령 |
| `HEALTHCHECK` | 상태 점검 |

- 지시어마다 레이어가 생기고 **캐시**됩니다. 자주 바뀌는 `COPY`는 아래쪽에 둡니다.
- `RUN apt-get update && apt-get install ... && rm -rf /var/lib/apt/lists/*`처럼 한 줄로 묶으면 이미지 크기가 줄어듭니다.

### 포트 매핑 `-p 호스트:컨테이너`
- `-p 8080:80` → 내 PC의 8080으로 들어온 요청을 컨테이너 80으로 전달
- 컨테이너 포트는 **앱이 실제로 listen하는 포트**여야 합니다(nginx=80).
- 호스트 포트는 컨테이너끼리 겹칠 수 없습니다. 같은 이미지를 여러 개 띄우려면 8080, 8081처럼 다르게 줍니다.

**왜 포트 포워딩이 필요한가: 네트워크 네임스페이스**
- 컨테이너는 리눅스 **네트워크 네임스페이스**로 호스트와 네트워크가 격리됩니다. 컨테이너마다 자기만의 네트워크 인터페이스, IP(예: `172.17.0.x`), 포트 공간, 라우팅 테이블을 가집니다.
- 그래서 컨테이너 안의 `80` 포트는 컨테이너 네임스페이스 안에서만 열려 있고, 호스트의 `localhost`에서는 보이지 않습니다. 컨테이너끼리도 각자 80을 써도 충돌하지 않습니다.
- `-p 8080:80`은 **호스트 네임스페이스의 8080 포트로 들어온 트래픽을 컨테이너 네임스페이스의 80 포트로 전달**(포워딩)하는 규칙을 만듭니다. 이 규칙이 없으면 밖에서 컨테이너에 접속할 수 없습니다.
- **네트워크 드라이버 한 줄 비교**: `bridge`(기본)는 호스트 안의 가상 네트워크로 컨테이너마다 IP를 받고 `-p`로 밖에 연다, `host`는 컨테이너가 호스트 네트워크를 그대로 써서 포트 매핑이 필요 없지만 격리가 없다, `overlay`는 여러 Docker 호스트의 컨테이너를 하나의 네트워크로 묶는다(Swarm 등).
- **포트 범위**: 호스트 포트는 보통 `1024~49151`(등록 포트) 중에서 고른다. `1~1023`은 관리자 권한이 필요하고, 충돌하면 `8081`, `8090`처럼 다른 번호로 바꾼다.
- 같은 사용자 정의 네트워크(예: Compose 네트워크)에 속한 컨테이너끼리는 포워딩 없이 서비스 이름으로 직접 통신합니다(`ping redis`).

| 구분 | 호스트 포트 | 컨테이너 포트 | 접속 주소 |
|---|---|---|---|
| my-web-8080 | 8080 | 80 | `http://localhost:8080` |
| my-web-8081 | 8081 | 80 | `http://localhost:8081` |
| bind-test | 8082 | 80 | `http://localhost:8082` |
| compose (환경 변수) | `${APP_PORT:-8080}` | 80 | `http://localhost:8090` (APP_PORT=8090) |

### 바인드 마운트 vs 볼륨
| | 바인드 마운트 | 볼륨 |
|---|---|---|
| 문법 | `-v $(pwd)/site:/path` | `-v mydata:/path` |
| 저장 위치 | 호스트의 지정 경로 | Docker가 관리 |
| 용도 | 개발 중 코드 즉시 반영 | DB 등 영속 데이터 |
| 특징 | 호스트 파일 수정이 재시작 없이 반영 | 컨테이너 삭제 후에도 유지 |

- 볼륨은 `docker volume rm`으로 지우기 전까지 남습니다.
- **권장**: 개발 중 코드/정적 파일을 편집하며 바로 확인할 때는 **바인드 마운트**(호스트 파일 수정이 즉시 반영, 단 호스트 경로/권한에 의존). 운영이나 DB처럼 **데이터를 보존**해야 할 때는 **볼륨**(Docker가 위치와 권한을 관리, `docker volume`으로 목록/삭제, 백업은 볼륨을 마운트한 임시 컨테이너로 `tar`).
- **볼륨 백업/복원** (임시 컨테이너로 tar):
  - 백업: `docker run --rm -v mydata:/data -v $(pwd):/backup ubuntu tar czf /backup/mydata.tgz -C /data .`
  - 복원: `docker run --rm -v mydata:/data -v $(pwd):/backup ubuntu tar xzf /backup/mydata.tgz -C /data`
- WSL2에서는 바인드 마운트 경로를 `/mnt/c`가 아닌 WSL 파일시스템(`~/...`)에 두는 편이 I/O가 빠릅니다.

---

## 4. Git / GitHub

- **설정 범위**: `--system` < `--global`(`~/.gitconfig`) < `--local`(저장소별). 좁은 범위가 우선합니다.
- `user.name` / `user.email`은 **커밋마다 기록**되어 공개 저장소에 노출됩니다. 이메일을 숨기려면 GitHub noreply 주소를 씁니다.
- `core.autocrlf input`: 커밋 시 CRLF를 LF로 변환 (Windows와 WSL을 오갈 때 `\r` 문제 예방)
- **기본 흐름**: `git add` → `git commit` → `git push`
- **SSH 인증**: 개인키(`id_ed25519`)는 내 PC에만, 공개키(`.pub`)만 GitHub에 등록. `ssh -T git@github.com`으로 확인.
- 커밋 메시지 관례: `chore:`, `feat:`, `fix:`, `docs:` 접두사
- `.gitignore`: `.venv/`, `.env`, `__pycache__/` 같은 파일은 커밋하지 않기

---

## 5. WSL2 + Docker Desktop

- 프로젝트는 **WSL 리눅스 파일시스템(`~/...`)**에 둡니다. `/mnt/c`는 I/O가 느리고 권한 동작이 다릅니다.
- Docker Desktop의 *WSL Integration*을 켜야 WSL 배포판에서 `docker`가 동작합니다. 안 켜면 `permission denied`나 `command not found`가 납니다.
- `localhost:8080`은 WSL2와 Windows 브라우저 양쪽에서 접속 가능합니다(포트 포워딩).
- 설정을 바꾼 뒤에는 `wsl --shutdown` 후 다시 들어오면 확실히 적용됩니다.
- **일반 사용자 계정을 권장**합니다. root로만 쓰면 권한 실습이 왜곡되고 실수의 피해가 큽니다.

---

## 6. 보안 체크

- 토큰, 비밀번호, **개인키**, 인증 코드는 로그·스크린샷·README·커밋에 넣지 않기
- 공개해도 되는 것: SSH **공개키**(`.pub`)
- 이미 커밋했다면 파일을 지워도 **히스토리에 남습니다**. 키는 즉시 폐기·재발급합니다.
- 점검: `git log --oneline`, `grep -ri "password\|token\|secret" . --include="*.md"`
- `curl ... | sh` 설치 방식은 스크립트를 확인하지 않고 실행하므로, 공식 출처인지 확인합니다.

---

## 7. 용어 빠른 참조

| 용어 | 뜻 |
|---|---|
| Registry | 이미지 저장소 (Docker Hub 등) |
| Tag | 이미지 버전 이름 (`nginx:alpine`, `my-web:1.0`) |
| Layer | 이미지를 이루는 변경 단위 |
| PID 1 | 컨테이너의 메인 프로세스 |
| Daemon | 백그라운드에서 도커를 관리하는 서버 프로세스 |
| Idempotent | 여러 번 실행해도 결과가 같은 작업 |
| Network namespace | 컨테이너별로 격리된 네트워크 공간(인터페이스, IP, 포트, 라우팅) |

---

## 8. 재현 절차 요약 (명령어 순서)

| 단계 | 명령 | 확인 |
|---|---|---|
| 1. 작업 디렉토리 | `mkdir -p ~/projects/codyssey-pre-dgree/mission_01/practice/webapp/site` 후 `cd` | `pwd`, `ls -la` |
| 2. 권한 실습 | `chmod 444 sample.txt` → 쓰기 시도 → `chmod 644 sample.txt` | `ls -l` 전/후 |
| 3. Docker 점검 | `docker --version`, `docker info`, `docker run hello-world` | 버전/메시지 출력 |
| 4. 이미지 빌드 | `echo "<h1>Hello from my custom image</h1>" > site/index.html`, Dockerfile 작성, `docker build -t my-web:1.0 .` | `docker images` |
| 5. 포트 매핑 | `docker run -d -p 8080:80 --name my-web-8080 my-web:1.0`, 8081도 동일 | `curl http://localhost:8080`, `:8081` |
| 6. 바인드 마운트 | `docker run -d -p 8082:80 -v $(pwd)/site:/usr/share/nginx/html --name bind-test nginx:alpine` → 파일 수정 | `curl http://localhost:8082` 전/후 |
| 7. 볼륨 | `docker volume create mydata` → 쓰기 → `docker rm -f` → 새 컨테이너 연결 | `cat /data/hello.txt` |
| 8. Git/SSH | `git config --global ...`, `ssh-keygen`, 공개키 등록 | `ssh -T git@github.com`, `git remote -v` |
| 9. Compose | `docker compose up -d --build` → `ps` → `logs` → `down` | `curl`, `ping redis` |
| 10. 정리 | `docker rm -f <컨테이너>`, `docker volume rm mydata` | `docker ps -a` |

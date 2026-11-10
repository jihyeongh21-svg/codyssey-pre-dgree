# 코디세이 연수 과정

Codyssey 올인원 1기 입학 연수(Pre-course) 미션 수행 기록 저장소입니다. 미션별 폴더에 실습 파일, 실행 로그, 스크린샷, 개념 정리를 함께 보관합니다.

## 미션 목록

| 미션 | 주제 | 상태 | 문서 |
|---|---|---|---|
| [mission_01](./mission_01) | 개발자용 '작업실' 꾸미기 (터미널, 권한, Docker, Git/GitHub, Compose) | 완료 | [수행 기록](./mission_01/README.md) · [개념 정리](./mission_01/CONCEPTS.md) |
| [mission_02](./mission_02) | (준비 중) | 진행 예정 | - |

## 저장소 구조

```text
codyssey-pre-dgree/
├── README.md                # 이 문서 (저장소 전체 안내)
├── .gitignore
├── mission_01/
│   ├── README.md            # 수행 기록 (명령 + 출력 + 스크린샷)
│   ├── CONCEPTS.md          # 개념 정리
│   ├── assets/              # README가 참조하는 스크린샷
│   └── practice/            # 실습 산출물
│       ├── sample.txt       # 터미널/권한 실습 대상
│       ├── webapp/          # Dockerfile(nginx:alpine) + site/index.html
│       └── compose/         # basic/, multi/ (Docker Compose)
└── mission_02/              # 다음 미션
```

**폴더 규칙**
- 미션 폴더 이름은 `mission_NN` 형식(두 자리 숫자)으로 통일합니다.
- 미션 폴더마다 `README.md`(수행 기록), `assets/`(스크린샷), `practice/`(실습 파일)를 두어 문서, 증거, 실습 파일을 분리합니다.
- 개념 정리는 필요한 미션에만 `CONCEPTS.md`로 둡니다.

## 실행 환경

| 항목 | 값 |
|---|---|
| OS | Windows 11 + WSL2 (Ubuntu 24.04) |
| 터미널 | VS Code 통합 터미널 (WSL 연결) |
| 컨테이너 | Docker Desktop (WSL2 backend), Docker Compose v2 |
| 버전 관리 | Git, GitHub (SSH 인증) |

프로젝트는 WSL 리눅스 파일시스템(`~/projects`)에 두고 작업합니다. `/mnt/c` 경로는 I/O가 느리고 권한이 제대로 반영되지 않기 때문입니다.

## 빠른 시작

```bash
# 1) 저장소 받기 (SSH 키가 GitHub에 등록되어 있어야 함)
cd ~/projects
git clone git@github.com:jihyeongh21-svg/codyssey-pre-dgree.git
cd codyssey-pre-dgree

# 2) mission_01 웹 이미지 빌드와 실행
cd mission_01/practice/webapp
docker build -t my-web:1.0 .
docker run -d -p 8080:80 --name my-web my-web:1.0
curl http://localhost:8080          # <h1>Hello from my custom image</h1>
docker rm -f my-web

# 3) Docker Compose (멀티 컨테이너)
cd ../compose/multi
docker compose up -d --build
docker compose exec web ping -c 2 redis
docker compose down
```

사전 조건: Docker Desktop 실행 중이며 WSL Integration이 켜져 있어야 합니다. 자세한 절차와 문제 해결은 [mission_01 수행 기록](./mission_01/README.md)의 트러블슈팅을 참고하세요.

## 보안

토큰, 비밀번호, 개인키, 인증 코드는 저장소와 스크린샷에 포함하지 않습니다. `.env`, `.venv/`, 개인키는 `.gitignore`로 제외합니다.

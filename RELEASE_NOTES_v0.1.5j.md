# TCRP Friend v0.1.5j Release Notes

## English

### Why this update

Friend's kernel 5 platform list had fallen out of sync with the DSM targets supported by MSHELL. That could leave newer supported platforms on the generic kernel fallback, while epyc7003ntb remained accepted through an older hardcoded list. A generic fallback can select the wrong kernel for a loader.

### What changes for users

Friend now reads the shared offline platform policy. It recognizes the six supported kernel 5 platforms: epyc7002, epyc7003, icelaked, v1000nk, r1000nk, and geminilakenk. epyc7003ntb is rejected.

When older loader configuration has no matching resolver metadata, Friend selects a kernel only when the policy contains a reviewed mapping for that platform and DSM build. If no mapping exists, boot preparation stops with an error instead of guessing. Update Friend to v0.1.5j to receive this policy and behavior.

## 한국어

### 업데이트 이유

Friend의 커널 5 플랫폼 목록이 MSHELL의 DSM 지원 대상과 달라져 있었습니다. 그 결과 새 지원 플랫폼이 일반 커널 대체 경로로 들어갈 수 있었고, 오래된 하드코딩 목록에서는 epyc7003ntb도 계속 허용될 수 있었습니다. 일반 대체 경로는 로더에 맞지 않는 커널을 선택할 위험이 있습니다.

### 사용자에게 달라지는 점

Friend가 공통 오프라인 플랫폼 정책을 읽습니다. 지원 커널 5 플랫폼은 epyc7002, epyc7003, icelaked, v1000nk, r1000nk, geminilakenk의 6개이며, epyc7003ntb는 거부됩니다.

resolver 정보가 없는 구형 로더 설정은 해당 플랫폼과 DSM 빌드에 대해 정책에 검토된 커널 매핑이 있을 때만 그 커널을 선택합니다. 매핑이 없으면 임의의 커널을 추정하지 않고 오류와 함께 부팅 준비를 중단합니다. 이 정책과 동작을 적용하려면 Friend를 v0.1.5j로 업데이트하십시오.

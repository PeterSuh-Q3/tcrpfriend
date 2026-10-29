# TCRP Friend v0.1.5i Release Notes

## English

### Why this update

MSHELL can now record the kernel version selected for an exact DSM target. Friend previously relied on its legacy platform-to-kernel mapping, which could disagree with that selection and choose a kernel that did not match the model and DSM build being started.

### What changes for users

When the recorded resolver platform and DSM build match the loader being booted, Friend uses the resolver-selected kernel version. This keeps Friend aligned with the DSM target selected during the MSHELL build.

Older configurations, or configurations whose platform and DSM build do not match, continue to use Friend's existing kernel mapping. Upgrade Friend to v0.1.5i to use the resolver-selected version when matching metadata is available.

## 한국어

### 업데이트 이유

MSHELL은 이제 선택한 DSM 대상에 맞는 커널 버전을 설정 파일에 기록할 수 있습니다. 기존 Friend는 플랫폼별 기존 커널 매핑에 의존했기 때문에, MSHELL이 선택한 모델·DSM 빌드와 다른 커널 버전을 선택할 수 있었습니다.

### 사용자에게 달라지는 점

기록된 resolver 플랫폼과 DSM 빌드가 현재 부팅하는 로더와 일치하면 Friend가 resolver에서 선택한 커널 버전을 사용합니다. 따라서 Friend의 커널 선택이 MSHELL 빌드에서 선택한 DSM 대상과 일치합니다.

기존 설정처럼 resolver 정보가 없거나 플랫폼·DSM 빌드가 일치하지 않는 경우에는 Friend의 기존 커널 매핑을 계속 사용합니다. 일치하는 정보가 있을 때 resolver의 커널 버전을 적용하려면 Friend를 v0.1.5i로 업데이트하십시오.

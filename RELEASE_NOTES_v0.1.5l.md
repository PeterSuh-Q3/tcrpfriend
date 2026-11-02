# TCRP Friend v0.1.5l Release Notes

## English

### Why this update

A new `user_config.json` can contain one blank `ipsettings` entry with `primary: true`. Friend previously counted that placeholder as a static-IP configuration. During boot it could report an invalid static-IP entry and stop the DHCP services even though no static address had been requested.

### What changes for users

Friend now treats an entry with empty `ipset`, `ipiface`, `ipaddr`, and `ipgw` values as an unconfigured placeholder. If no other IP entry is configured, boot continues through the normal DHCP path without a static-IP error. An empty DNS or proxy setting does not turn the placeholder into a static-IP request.

Configured static-IP entries continue to work as before, including when they appear alongside a blank placeholder. Incomplete entries containing actual configuration values still receive a warning instead of being silently accepted.

## 한국어

### 업데이트 이유

새 `user_config.json`에는 `primary: true`가 지정된 빈 `ipsettings` 항목이 하나 들어 있을 수 있습니다. 기존 Friend는 이 기본 항목까지 고정 IP 설정으로 세어, 실제로 고정 IP를 요청하지 않았는데도 부팅 중 설정 오류를 표시하고 DHCP 서비스를 중지할 수 있었습니다.

### 사용자에게 달라지는 점

이제 `ipset`, `ipiface`, `ipaddr`, `ipgw`가 모두 빈 항목은 설정되지 않은 기본 자리표시자로 처리합니다. 다른 IP 항목도 설정되지 않았다면 고정 IP 오류 없이 일반 DHCP 경로로 부팅합니다. DNS나 프록시 설정이 비어 있는 것만으로 고정 IP 요청으로 판단하지 않습니다.

빈 기본 항목 옆에 실제 고정 IP 설정이 있으면 기존처럼 적용합니다. 반면 값이 일부 입력된 불완전한 항목에는 계속 경고를 표시해 잘못된 설정을 조용히 통과시키지 않습니다.

# FRIEND Intel Arc 부팅 호환성 조사 및 파일럿 설계

상태: 설계 단계. 원인 확정, 빌드 또는 실기 검증은 아직 수행하지 않았다.

## 목표와 범위

Core Ultra 7 155H의 Meteor Lake Arc 내장 GPU 장착 노트북에서 FRIEND 커널을 부팅해 `boot.sh`에 도달한다. 기존 GPU와 A380 장착 시스템도 회귀 없이 FRIEND에 진입해야 한다. FRIEND에서 GPU 가속이나 Arc KMS 구현은 목표가 아니다. DSM 진입 후 Arc 가속 및 GuC 문제는 별도의 검증 대상이다. 기존 정상 이미지를 덮어쓰지 않는 후보 이미지로 시험한다.

## 관찰과 확인된 소스

* 155H 실기는 FRIEND 커널 진입 이후 `boot.sh` 이전에 KP가 보고되었다. 패닉 로그는 제공할 수 없으므로 원인과 발생 함수는 미확정이다.
* A380 시스템은 FRIEND 화면에 PCI `8086:56a5`가 표시됐다. 이후 DSM에서 i915의 `dg2_guc_70.bin: fetch failed -ENODEV`가 보고됐다. 파일 존재만 확인되었으며 펌웨어 내용, 정확한 커널과 요청 경로는 확인되지 않았다. DSM 포트 미응답을 KP로 확정할 수도 없다. PCI 표시만으로 GPU 드라이버 바인딩은 증명되지 않는다.
* 조사 기준은 tcrpfriend main `75120ba8a2c684e94b152d2d158a5f1b8d88b74d`이다. 보고 당시 이미지의 실제 FRIEND 커널과 이 소스의 동일성은 미확인이다.
* `buildroot/configs/tcrpfriend_defconfig`는 Buildroot의 latest kernel 선택과 저장된 버전 문자열 `6.6.79`, `board/tcrpfriend/kernel_defconfig`를 지정한다. 실제 버전은 선택한 Buildroot revision 및 생성된 `.config`에서 확정해야 한다. `tcrpfriend_defconfig.k6`의 별도 경로도 확인한다.
* `kernel_defconfig`는 `CONFIG_DRM=y`, `CONFIG_FB_EFI=y`, `CONFIG_FRAMEBUFFER_CONSOLE=y`를 명시하지만 i915 및 xe 활성화 설정은 명시하지 않는다. 실제 olddefconfig 결과와 이미지 모듈 목록을 확인하기 전 i915 포함 여부를 단정하지 않는다. EFI framebuffer는 GPU 전용 드라이버와 별개다.
* Buildroot 펌웨어 선택과 rootfs overlay에서 Intel GPU 펌웨어를 명시적으로 찾지 못했다. 이것이 155H KP의 원인이라는 증거는 아니다. `root/tools/ramdisk-patch.sh`의 `firmware.tgz`는 DSM 램디스크용이므로 FRIEND rootfs 펌웨어로 취급하지 않는다. 실제 적용되는 패치 경로 및 최종 이미지 내용도 확인한다.
* `.github/workflows/buildroot.yml`은 이동하는 Buildroot 브랜치 `2023.11.x`와 redpill-load `master`를 사용하고 빌드 결과로 bzImage와 initrd만 보관한다. 재현 가능한 커널 버전, 최종 설정, 펌웨어 및 원본 해시가 남지 않는 것이 조사상의 결함이다. workflow의 overlay 복사와 redpill-load config 복사 순서도 최종 rootfs에서 확인한다.

## 설계 원칙

FRIEND의 일은 DSM 커널로 안전하게 전달하는 것이다. Arc용 i915/xe 및 대용량 GPU 펌웨어를 기본 탑재하거나 `force_probe`, GuC 강제 설정을 무조건 적용하지 않는다. 드라이버 미포함 상태에서도 EFI framebuffer를 이용한 사용자 공간 진입이 가능한지 먼저 시험한다. GPU 미바인딩이 모든 KP를 막는다는 보장은 없다. DSM의 i915, 펌웨어 또는 quad DRM 자산은 이 시험에서 바꾸지 않는다.

## 구현 및 빌드 계획

1. **기준 이미지 확보:** 현재 배포된 FRIEND bzImage/initrd와 각각 SHA-256, 배포 버전, 가능하면 빌드에 사용된 커밋·Buildroot revision을 기록한다. 파일이 없으면 기준 미확정으로 표시하고 소스에서 기준 후보를 만든다. 기존 파일은 보존한다.
2. **재현 가능한 기준 빌드:** Buildroot는 검토한 정확한 커밋, redpill-load도 정확한 커밋으로 고정한다. 사용하는 defconfig와 Linux 실제 소스 버전, toolchain, 원본 해시 및 빌드 명령을 manifest에 기록한다. `make` 후 Buildroot `.config`와 Linux의 최종 `.config`, `System.map`, bzImage, initrd, 설치 모듈 목록과 펌웨어 파일 목록·해시를 별도 아티팩트로 보존한다. 커널 버전 문자열만 신뢰하지 않는다.
3. **정적 검사:** 최종 `.config`의 `DRM_I915`, `DRM_XE`, EFI framebuffer/console, PCI, ACPI, IOMMU 및 로그 설정을 확인한다. `modules.builtin`, `modules.alias`, initrd의 실제 i915/xe 모듈과 i915 firmware 파일 및 symlink를 확인한다. 내장 드라이버와 모듈의 차이, 자동적재 경로를 따로 기록한다.
4. **최소 안전 후보:** 확정된 기준과 별도 설정 fragment를 사용해 i915/xe가 실제로 빌드·자동 로딩되는 경우에만 FRIEND 단계에서 비활성화한 후보를 만든다. 기본적으로 꺼져 있었다면 이 변경은 무효이므로 새로운 원인 증거 없이 GPU 펌웨어를 추가해 해결했다고 주장하지 않는다. EFI 콘솔과 부팅·네트워크 경로는 유지한다. 커널 명령행 blacklist는 모듈에만 적용될 수 있으므로 내장 드라이버에 대한 대체물로 간주하지 않는다.
5. **대조 후보:** 최소 후보가 실패하면 커널 자체/EFI/ACPI/PCI 초기화 가능성을 분리할 수 있도록, 검토된 호환 LTS 커널을 같은 Buildroot 설정에서 별도 후보로 만든다. 커널 변경과 GPU 펌웨어 변경은 한 이미지에 섞지 않는다. 특정 커널이 문제를 해결한다고 미리 가정하지 않는다.
6. **선택적 GPU 후보:** FRIEND 자체에서 KMS가 실제 요구될 때만 별도 실험으로 해당 커널의 i915 지원 범위와 필수 firmware 버전을 확인하고, 최소 펌웨어와 드라이버를 짝지어 빌드한다. 이 후보의 결과를 DSM i915 지원으로 일반화하지 않는다.

## 로그 없이 가능한 검증과 합격 기준

* 빌드 산출물의 압축 무결성, 최종 설정, 펌웨어/모듈 목록, 커널·initrd 해시와 재현 manifest를 자동 검사한다. 기준/후보는 명확히 다른 이름으로 둔다.
* 155H에서 기준과 후보를 각각 콜드 부팅한다. 최소 3회 반복해 FRIEND 콘솔과 `boot.sh` 화면 도달 여부를 기록한다. 화면 도달이 실패하면 강제 전원 종료 전 관찰 가능한 증상과 경과 시간만 기록하며 원인을 확정하지 않는다.
* 기존 호환 장비 및 A380 장착/미장착 구성도 같은 이미지로 시험한다. A380의 단순 PCI 열거, FRIEND 도달, DSM 웹 접속은 각각 별개 결과로 기록한다. 설치된 DSM 데이터나 기존 로더를 손상시키지 않는 독립 부팅 매체를 사용한다.
* FRIEND 통과와 DSM 구동은 별도 합격 항목이다. A380의 DSM GuC/가속은 FRIEND 통과만으로 성공 처리하지 않는다. 시리얼 로그를 필수 조건으로 요구하지 않되, 로그 부재 시 KP 원인 및 장기 안정성은 미확인으로 남긴다.
* 모든 대상에서 FRIEND 진입과 기존 장비 회귀 검증 후에만 배포 후보로 승격한다. 어느 하나라도 실패하면 기존 이미지를 유지한다.

## DSM A380 후속 조사

DSM에서 사용한 정확한 플랫폼/커널, i915 모듈 출처와 빌드 설정, initrd 및 실제 root의 DG2 GuC/HuC/GSC 펌웨어 버전·해시와 로딩 순서를 별도로 대조한다. `-ENODEV`의 발생 경로를 해당 i915 소스에서 확인하기 전 파일 누락이나 버전 불일치로 단정하지 않는다. DSM GPU 지원의 변경은 별도 설계와 실기 검증을 거친다.

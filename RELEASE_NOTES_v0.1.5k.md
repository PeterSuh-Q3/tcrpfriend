# TCRP Friend v0.1.5k Release Notes

## English

### Why this update

When an MSHELL automatic rebuild selected a mode requiring BMI2 but the xTCRP environment did not expose that CPU feature, the same deterministic failure was retried three times. On virtual machines this can happen when the VM CPU type hides features supported by the host; on older physical CPUs BMI2 may genuinely be unavailable. The failure did not explain how to proceed.

### What changes for users

Friend now stops immediately when the resolver reports `CPU_FEATURE_MISSING`. If the host CPU supports BMI2, expose it to the VM with a host or passthrough CPU type and retry. If the physical CPU does not support BMI2, explicitly choose a resolver-listed module/method mode without that requirement. For SA6400 with DSM 7.4.1, `custom-modules/PML` is available; it may provide fewer bundled modules or addons, so Friend does not switch modes automatically.

After this compatibility rejection, Friend clears the auto-rebuild marker and restores the normal DSM boot entry. The next reboot therefore returns to the existing DSM loader while the user corrects the CPU exposure or build-mode selection.

## 한국어

### 업데이트 이유

MSHELL 자동 리빌드에서 BMI2가 필요한 모드를 선택했지만 xTCRP 환경에서 해당 CPU 기능이 보이지 않으면, 같은 실패를 세 번 반복했습니다. 가상 머신에서는 호스트가 지원하는 기능을 VM CPU 유형이 숨길 수 있고, 오래된 실기 CPU는 BMI2를 실제로 지원하지 않을 수 있습니다. 기존 오류 화면에는 다음 조치도 명확히 안내되지 않았습니다.

### 사용자에게 달라지는 점

resolver가 `CPU_FEATURE_MISSING`을 반환하면 Friend가 재시도 없이 즉시 중단하고 조치 방법을 안내합니다. 호스트 CPU가 BMI2를 지원하는 VM이라면 CPU 유형을 host 또는 passthrough로 설정한 뒤 다시 시도하십시오. 실기 CPU가 BMI2를 지원하지 않는다면 해당 요구사항이 없는 resolver 승인 모듈/방식 조합을 직접 선택해야 합니다. SA6400 DSM 7.4.1에는 `custom-modules/PML`이 있으며, 포함되는 모듈이나 애드온이 줄어들 수 있으므로 Friend가 모드를 자동으로 바꾸지는 않습니다.

CPU 호환성 오류가 발생하면 자동 리빌드 표식을 지우고 GRUB 기본 항목을 일반 DSM 부팅으로 복원합니다. 따라서 다음 재부팅은 기존 DSM 로더로 돌아가며, CPU 기능 노출 또는 빌드 모드를 조정한 뒤 다시 리빌드를 요청할 수 있습니다.

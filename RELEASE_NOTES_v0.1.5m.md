# TCRP Friend v0.1.5m Release Notes

## English

### Why this update

Friend's DSM kernel update check used the selected module pack to decide whether to run `kpatch`. That missed prebuilt kernels used alongside `all-modules`, so a DSM kernel update could cause Friend to patch and replace a custom or detour kernel that was already prepared for use.

### What changes for users

Friend now checks the embedded build marker in `zImage-dsm` for the `PeterSuh-Q3@MSHELL` custom kernel and `dsm-kernel-compat@debian12` detour kernel. When either marker is present, Friend skips its kernel `kpatch` step regardless of the selected module pack, including `all-modules`.

DSM ramdisk update handling remains separate and continues to run when needed. Kernels without either marker keep the existing update behavior.

## 한국어

### 업데이트 이유

기존 Friend는 선택된 모듈팩을 기준으로 DSM 커널 업데이트 시 `kpatch` 실행 여부를 판단했습니다. 이 방식은 `all-modules`와 함께 사용하는 사전 빌드 커널을 구분하지 못해, DSM 커널 업데이트 중 이미 준비된 커스텀 또는 detour 커널을 다시 패치해 덮어쓸 수 있었습니다.

### 사용자에게 달라지는 점

이제 `zImage-dsm` 안의 빌드 표식을 확인해 `PeterSuh-Q3@MSHELL` 커스텀 커널과 `dsm-kernel-compat@debian12` detour 커널을 식별합니다. 두 표식 중 하나가 있으면 선택된 모듈팩과 관계없이, `all-modules`에서도 Friend의 커널 `kpatch`를 건너뜁니다.

DSM 램디스크 업데이트 처리는 별도로 유지되어 필요할 때 계속 실행됩니다. 두 표식이 없는 커널은 기존 업데이트 동작을 따릅니다.

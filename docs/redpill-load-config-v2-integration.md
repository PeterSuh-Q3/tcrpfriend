# FRIEND and redpill-load config V2 integration design

## Status and scope

This document defines the required FRIEND changes after the redpill-load V2
ramdisk patch-family branch is promoted to `master`. It is a design only; it
does not change the current boot behavior.

FRIEND does not download redpill-load config during normal boot. A FRIEND
image embeds it at `/root/config`, and `boot.sh` consumes
`/root/config/<platform>/<DSM-version>/config.json` when it repatches an
initrd. Therefore a boot.sh-only update cannot introduce a new config family.
A newly built `initrd-friend` is required.

## Trigger clarification

`smallfixnumber` is output metadata written after a successful ramdisk patch;
it is not the direct patch trigger. The current triggers are:

- the stock loader partition `rd.gz` hash differs from the stored `rdhash`;
- an initial configuration has `general.smallfixnumber = null`.

DSM 7.4.1 U0 normally has neither condition after a completed build, so this
path is not expected to run immediately. A DSM update, reinstall, initial
build, or another stock ramdisk replacement can activate it later.

## Compatibility issue to solve

V2 config files use both of these fields:

```json
{
  "patches": {
    "ramdisk": [],
    "ramdisk_sets": ["linuxrc-fresh-install-skip-disk-ready-wait-7.3.0-7.4.1"]
  }
}
```

The current FRIEND `boot.sh` reads only `patches.ramdisk`. If V2 config is
embedded without a parser update, the patch set is silently ignored and no
V2 ramdisk text patches are applied. This must be treated as a compatibility
failure, not as an empty valid patch list.

## Build-time config acquisition

Every workflow that produces or repacks `initrd-friend` must use one shared
config acquisition step.

1. Accept `redpill-load-ref` as a workflow input. Its default is `master`.
   Allow an explicit branch, tag, or commit only for validation or release work.
2. Clone and resolve that ref to an immutable commit SHA before copying files.
3. Delete only the staging image's existing `/root/config` directory, then
   copy the newly resolved `redpill-load/config` tree into its place. Do not
   overlay with `cp -rf`, because deleted legacy paths can otherwise remain
   in an image rebuilt from an older release asset.
4. Store `/root/config/.mshell-redpill-load-revision.json` with the requested
   ref, resolved commit SHA, and config format marker. It is diagnostic data,
   not a runtime update mechanism.
5. Fail the workflow if the copied tree lacks `config/_common/ramdisk/patch-sets.json`
   or the target platform/version `config.json` files expected by the build.

The normal full Buildroot workflows have fresh runners, but release-asset
repack workflows unpack an old `initrd-friend` first. Step 3 is mandatory for
the latter and should also be used by the full workflows for one invariant.

## release-tags.yml responsibilities

`release-tags.yml` is the primary release-asset migration path. It is not a
metadata-only release workflow: it downloads the baseline `v0.0.0i`
`initrd-friend`, unpacks it, overlays the current FRIEND root files and
redpill-load config, repacks `initrd-friend`, then uploads that image to the
published release.

For V2 it must:

1. Resolve `redpill-load-ref` before unpacking or copying. On release events
   the default is the then-current `master`; manual dispatch must expose the
   same input for V2 validation before promotion.
2. Replace `/opt/updaterootfs/temprd/root/config` as a whole before copying
   the resolved config. The current `cp -rf .../config .../root/` overlay is
   insufficient because a baseline image can retain paths removed by V2.
3. Write the resolved ref and commit provenance file into the replacement
   config directory before repacking.
4. Validate the embedded config after copying: check the set catalog, the
   selected platform/version config, and every patch path resolved by the new
   boot.sh resolver.
5. Inspect the final repacked `initrd-friend` in a separate temporary tree
   before publishing. Confirm that its embedded provenance SHA matches the
   clone used by the job and that removed legacy patch directories are absent.
6. Abort before the release upload if any config or resolver validation fails.
   A release asset with a new boot.sh and an old or partial config tree is not
   an acceptable fallback.

The full Buildroot workflows (`buildroot.yml` and `buildrootamd.yml`) need the
same ref resolution, clean replacement, and provenance policy. They create a
fresh root filesystem, whereas `release-tags.yml` mutates an unpacked baseline;
the latter is therefore the higher-risk path and must be validated first.

## boot.sh V2 patch resolver

Add a dedicated `resolve_ramdisk_patches()` helper, called by `patchramdisk()`
before any patch command runs.

Inputs:

- target config: `/root/config/<platform>/<DSM-version>/config.json`;
- set catalog: `/root/config/_common/ramdisk/patch-sets.json`;
- legacy list: `.patches.ramdisk`;
- V2 set list: `.patches.ramdisk_sets`.

Required behavior:

1. Validate both JSON files with `jq -e` and report the chosen config and
   provenance SHA in `friendlog.log`.
2. Expand `ramdisk_sets` in declared order. Each set must exist and resolve to
   an ordered array of patch paths.
3. Append legacy `ramdisk` entries after expanded sets, matching redpill-load
   ordering. This keeps legacy configurations compatible.
4. Resolve `@@@COMMON@@@` only to `/root/config/_common`; reject paths outside
   `/root/config` after normalization.
5. De-duplicate identical resolved paths while preserving the first position.
   A duplicate is a configuration error in V2 validation mode.
6. Verify every resolved patch file exists and is readable before modifying
   the extracted ramdisk.
7. If `ramdisk_sets` exists but the running boot.sh lacks a valid resolver,
   fail explicitly. Never reduce this case to an empty patch list.

## Patch application safety

The current command uses `patch ... || true`, which can hide an unapplied V2
patch. For V2-selected config, first run `patch --dry-run` with the intended
options for every resolved patch. On a dry-run or apply failure, write the
patch name and reject output to `friendlog.log`, leave `initrd-dsm` unchanged,
and stop the handoff. Legacy-only config can retain the current compatibility
mode until its own source samples have been checked.

## Deployment rules

- `down.sh` and boot.sh self-update must not claim to refresh V2 config; they
  download only scripts.
- A config schema or provenance change requires a new `initrd-friend` asset
  and a loader rebuild or FRIEND asset update that installs that image.
- Existing loaders retain their embedded config until their `initrd-friend` is
  replaced, even after redpill-load `master` changes.
- DSM 6.2.4 remains excluded until a matching original ramdisk sample passes
  dry-run validation. Future DSM versions must be admitted only after the
  same verification.

## Acceptance matrix

1. Legacy DSM config with only `patches.ramdisk`: patch order remains unchanged.
2. V2 DSM 7.0.1 to 7.2.2 config: resolves the legacy fresh-install family.
3. V2 DSM 7.3.0 to 7.4.1 config: resolves the modern fresh-install family.
4. Missing set name or missing patch path: patchramdisk fails before modifying
   the extracted ramdisk and records the cause.
5. Repacked FRIEND image: old `/root/config` files are absent and provenance
   SHA matches the requested redpill-load commit.
6. boot.sh-only update on an older FRIEND image: reports embedded config
   provenance and does not imply that a new V2 config was downloaded.

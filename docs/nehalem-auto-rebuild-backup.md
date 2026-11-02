# Deferred Nehalem auto-rebuild integration

The complete `boot.sh` Nehalem report/retry implementation, together with its
`VERSION` and history changes, is preserved in commit
`d6f7d3e4b766b87e1f25e332d5b77d03065759e8` (`Track Nehalem reports in
auto-rebuild`). Its parent is
`af471441f5201a8e3a203b6d20cb5e27a14049bc`.

The implementation was removed at the user's request on 2026-11-02. This is a
source rollback only; it does not rebuild or replace a running Friend image.
Do not reapply it until the user explicitly requests it.

To review the saved change without modifying the working tree:

```sh
git show d6f7d3e -- \
  buildroot/board/tcrpfriend/rootfs-overlay/root/boot.sh \
  buildroot/board/tcrpfriend/rootfs-overlay/root/VERSION
```

When reapplication is requested, inspect the current auto-rebuild flow first,
then generate the saved patch for these two files and check that it applies:

```sh
git diff d6f7d3e^ d6f7d3e -- \
  buildroot/board/tcrpfriend/rootfs-overlay/root/boot.sh \
  buildroot/board/tcrpfriend/rootfs-overlay/root/VERSION | git apply --check
```

Only after review and a successful check, run the same command with
`git apply` in place of `git apply --check`. Do not overwrite later changes or
assume the old version number remains appropriate. The saved `boot.sh` had
SHA-256 `be5e33b8d5e476f7ac8854c3af32f895c92d2c85f176e579a802fedf4b3a274f`.

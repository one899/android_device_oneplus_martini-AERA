# android_device_oneplus_martini-AERA

AERA Recovery device tree for the **OnePlus 9RT** (`martini` / MT2110 / MT2111 / OP5154L1).
Use with [AERA-Recovery/android_manifest](https://github.com/AERA-Recovery/android_manifest) (`aera-16.0`).

## Device facts (verified on a live MT2110)

| item | value |
|---|---|
| SoC / platform | Qualcomm **SM8350 / lahaina**, Adreno 660 |
| codename | `martini` (device id `OP5154L1`) |
| boot partition | `boot_a` / `boot_b` = **201,326,592 B** (192 MiB) |
| boot header | **v3**, header_size 1580, pagesize 4096, **empty cmdline** |
| no recovery partition | recovery is flashed to `boot_a`/`boot_b` |
| dtbo | `dtbo_a`/`dtbo_b` = 25,165,824 B (not part of the boot image) |
| vendor_boot | `vendor_boot_a` = 201,326,592 B |
| super | 13,000,003,584 B, dynamic partitions (`qti_dynamic_partitions`) |
| slots | A/B, virtual A/B (`ro.build.ab_update=true`) |
| kernel | OnePlus SM8350 5.4.295 (EEVDF-optimised), `Image` (uncompressed arm64) |
| stock ramdisk | gzip, 21,749,216 B |

## Build

The build needs a full AOSP 16 tree, so it runs on a **self-hosted runner**
(see [`docs/BUILD.md`](docs/BUILD.md)). Kernel comes from the kernel repo CI:

- `one899/android_kernel_oneplus_sm8350_9rt_295bpf` @ `perf/eevdf-optimized`

Workflow: [`.github/workflows/build-recovery.yml`](.github/workflows/build-recovery.yml)
(`workflow_dispatch` → downloads the latest kernel CI artifact, extracts `Image`,
syncs AERA, builds `recoveryimage`, uploads the boot-format image).

## Before the first build

1. Put the vendor blobs into `prebuilt/`:

   ```
   adb push scripts/extract-prebuilts.sh /data/local/tmp/
   adb shell su -c "sh /data/local/tmp/extract-prebuilts.sh"
   adb pull /sdcard/aera_prebuilt ./prebuilt_pull
   ```

   then copy `prebuilt_pull/bin`, `lib64`, `hw`, `egl`, `firmware`, `vintf` into
   `prebuilt/` (`systemmanifest.xml` / `vendormanifest.xml` from `vintf/`).

2. `prebuilt/Image` is injected by the workflow (do not commit it).

## Notes / risks

- The 9RT launched on Android 11 (shipping API 30) while AERA targets AOSP 16;
  FBEv2/v2+inlinecrypt + wrappedkey metadata encryption is what the stock fstab uses.
- Assertions/VINTF checks are disabled (`AERA_NO_TREBLE_COMPATIBILITY_CHECK`) —
  expectation is a ported ColorOS 17 ROM, not stock ColorOS 11.
- `bootctrl` uses `android.hardware.boot@1.2` (the stock recovery init starts `boot-hal-1-2`).
- Unlocked bootloader ⇒ AVB warning is normal. Never flash `vbmeta` from this tree.

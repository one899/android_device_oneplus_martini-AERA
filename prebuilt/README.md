# prebuilt/

构建前必须放入：

| 文件 | 来源 |
|---|---|
| `Image` | `one899/android_kernel_oneplus_sm8350_9rt_295bpf` @ `perf/eevdf-optimized` 的构建产物（`out/arch/arm64/boot/Image`） |
| `systemmanifest.xml` | 设备 `/system/etc/vintf/manifest.xml` |
| `vendormanifest.xml` | 设备 `/vendor/etc/vintf/manifest.xml` |

其余 vendor blob 由 `scripts/extract-prebuilts.sh` 从设备抽取。

# 构建说明（self-hosted runner）

AERA 是 AOSP 16 全量树，首次 `repo sync` + 编译约 40–60 GB、1.5–4 小时，必须用自建 runner。

## 1. runner 环境

要求：Linux x64（WSL2 也可以），**磁盘 ≥120 GB**，内存 ≥8 GB（建议 16 GB）。

把大容量盘挂进来，例如 Windows 的 F: 在 WSL 里是 `/mnt/f`，工作流默认用：

```
/mnt/f/aera/AERA_16.0
```

如需改路径，改工作流里的 `AERA_TREE`。

## 2. 安装 runner

GitHub → 你的仓库 → **Settings → Actions → Runners → New self-hosted runner**
（仓库：`one899/android_device_oneplus_martini-AERA`）

```bash
mkdir -p ~/actions-runner && cd ~/actions-runner
curl -o actions-runner-linux-x64.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-linux-x64-2.329.0.tar.gz
tar xzf actions-runner-linux-x64.tar.gz
./config.sh --url https://github.com/one899/android_device_oneplus_martini-AERA \
            --token <TOKEN> --labels self-hosted,linux,aera
sudo ./svc.sh install && sudo ./svc.sh start
```

标签必须是 `self-hosted,linux,aera`（工作流的 `runs-on` 用它们）。

## 3. 代理

runner 里的 `repo sync` / `gh` 需要能访问 GitHub：

```bash
# Clash 开"允许局域网连接"，WSL 里用 Windows 主机 IP
export http_proxy=http://172.22.64.1:7890
export https_proxy=http://172.22.64.1:7890
```

（`ip route show default | awk '{print $3}'` 查主机 IP。）
建议把这两行加到 runner 服务的环境或 `~/.bashrc`。

## 4. 首次构建前：抽取 vendor blob

恢复环境要 FBE 解密（keymaster/gatekeeper/qseecom）、显示（gralloc/EGL）和固件，这些必须来自本机 ROM：

```bash
adb push scripts/extract-prebuilts.sh /data/local/tmp/
adb shell su -c "sh /data/local/tmp/extract-prebuilts.sh"
adb pull /sdcard/aera_prebuilt ./
# 把 bin/ lib64/ hw/ egl/ firmware/ 拷进 prebuilt/
# vintf/system_manifest.xml  -> prebuilt/systemmanifest.xml
# vintf/vendor_manifest.xml  -> prebuilt/vendormanifest.xml
```

脚本没找到的文件会在输出里显示 `[ok]`；缺项需手工补（不同 ColorOS 版本路径可能不同，
`/vendor`、`/odm`、`odm_dlkm` 都试一下）。

## 5. 触发构建

GitHub → Actions → **Build AERA Recovery (martini / OnePlus 9RT)** → Run workflow

- `kernel_run_id` 留空 = 自动取 `perf/eevdf-optimized` 最近一次成功的内核构建
- 勾 `full_sync` 会重做 `repo init`

产物：`AERA-martini-recovery` artifact，内含

- `AERA-R1.0-martini-recovery.img`（boot header v3，刷 `boot_a`/`boot_b`）
- `header.txt`（构建后自动打印的头信息，用于核对）

## 6. 本地校验（不刷机）

```bash
python3 - <<'PY'
import struct
d=open('AERA-R1.0-martini-recovery.img','rb').read()
print('size', len(d), 'magic', d[:8])
print('header_version', struct.unpack('<I', d[40:44])[0])
print('header_size', struct.unpack('<I', d[20:24])[0])
print('kernel', struct.unpack('<I', d[8:12])[0], 'ramdisk', struct.unpack('<I', d[12:16])[0])
PY
```

期望：`size <= 201326592`、`header_version=3`、`header_size=1580`、kernel≈45 MB、ramdisk≈30–60 MB。

## 7. 刷写（本轮不做，仅供参考）

```bash
fastboot flash boot_a AERA-R1.0-martini-recovery.img
fastboot flash boot_b AERA-R1.0-martini-recovery.img
fastboot reboot recovery
# 回滚：刷回原厂 boot
```

## 8. 已知待调项

- `AERA_MAX_BRIGHTNESS` / `AERA_DEFAULT_BRIGHTNESS` 需按实机 `panel0-backlight` 的
  `max_brightness` 校准（当前 2047/800 是按同类机器估的）
- 触摸事件设备、（如需要）wifi 模块列表
- `os_version`：stock 头里是非标准值 `0x18000194`，当前构建用默认 0；若 bootloader 拒绝启动，
  改为用 stock boot 镜像做基底重打包

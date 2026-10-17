#!/bin/bash
# 在已 root 的设备上运行：把 AERA recovery 需要的 vendor blob 抽到 /sdcard/aera_prebuilt
# 用法: adb push extract-prebuilts.sh /data/local/tmp/ && adb shell su -c "sh /data/local/tmp/extract-prebuilts.sh"
set -u
OUT=/sdcard/aera_prebuilt
rm -rf "$OUT"; mkdir -p "$OUT"

copy() { # $1=src $2=dest_rel
  [ -f "$1" ] || return 0
  d="$OUT/$2"; mkdir -p "$(dirname "$d")"; cp -f "$1" "$d" 2>/dev/null && echo "  [ok] $2"
}

# ---- keymaster / gatekeeper / qseecom（FBE 解密核心）
for f in android.hardware.keymaster@4.1-service-qti android.hardware.gatekeeper@1.0-service-qti \
         qseecomd android.hardware.boot@1.2-service; do
  copy /vendor/bin/$f bin/$f
done
for f in vendor.qti.hardware.cryptoeng@1.0-service vendor.qti.hardware.vibrator@1.2-service qrtr-ns; do
  copy /vendor/bin/$f bin/$f
done
for f in libqtikeymaster4.so libkeymasterdeviceutils.so libkeymasterprovision.so libkeymasterutils.so \
         libQSEEComAPI.so libdiag.so libdrm.so libdrmfs.so libdrmtime.so libdrmutils.so \
         librpmb.so libsecureui.so libsecureui_svcsock.so libspl.so libssd.so libtime_genoff.so \
         libidl.so libqmi_cci.so libqmi_common_so.so libqmi_csi.so libqmi_encdec.so libqmiservices.so \
         libqservice.so libperipheral_client.so libspcom.so libGPreqcancel.so libGPreqcancel_svc.so \
         libStDrvInt.so libops.so liboemnvbk_img_helper.so libjson.so libmdmdetect.so libqisl.so \
         libdsutils.so libcld80211.so libqcbor.so libkeymaster_messages.so; do
  copy /vendor/lib64/$f lib64/$f
done
for f in android.hardware.gatekeeper@1.0-impl-qti.so; do
  copy /vendor/lib64/hw/$f hw/$f
done

# ---- boot control
copy /vendor/lib64/hw/libboot_control_qti.so hw/libboot_control_qti.so
copy /vendor/lib64/libboot_control_qti.so lib64/libboot_control_qti.so
copy /vendor/lib64/hw/android.hardware.boot@1.0-impl-1.1-qti.so hw/android.hardware.boot@1.0-impl-1.1-qti.so

# ---- 显示 / gralloc / EGL（lahaina = SM8350）
for f in gralloc.lahaina.so; do copy /vendor/lib64/hw/$f hw/$f; done
for f in libgralloc.qti.so libgralloccore.so libgralloctypes.so libgrallocutils.so \
         libdisplayconfig.qti.so libqdMetaData.so libqdutils.so libnativewindow.so libui.so \
         libadreno_utils.so libgsl.so libllvm-glnext.so; do
  copy /vendor/lib64/$f lib64/$f
done
for f in eglSubDriverAndroid.so libEGL_adreno.so libGLESv2_adreno.so; do
  copy /vendor/lib64/egl/$f egl/$f
done
for f in android.hardware.graphics.mapper@3.0-impl-qti-display.so android.hardware.graphics.mapper@4.0-impl-qti-display.so; do
  copy /vendor/lib64/hw/$f hw/$f
done
for f in android.hardware.graphics.mapper@2.0.so android.hardware.graphics.mapper@2.1.so \
         android.hardware.graphics.mapper@3.0.so android.hardware.graphics.mapper@4.0.so \
         android.hardware.graphics.allocator@2.0.so android.hardware.graphics.allocator@3.0.so \
         android.hardware.graphics.allocator@4.0.so android.hardware.graphics.common@1.0.so \
         android.hardware.graphics.common@1.1.so android.hardware.graphics.common@1.2.so \
         android.hardware.common-V2-ndk.so android.hardware.graphics.common-V3-ndk.so \
         android.hardware.graphics.allocator-V1-ndk.so vendor.display.color@1.0.so \
         vendor.display.config@1.0.so vendor.display.config@2.0.so \
         vendor.qti.hardware.display.allocator@3.0.so vendor.qti.hardware.display.allocator@4.0.so \
         vendor.qti.hardware.display.mapper@2.0.so vendor.qti.hardware.display.mapper@3.0.so \
         vendor.qti.hardware.display.mapper@4.0.so vendor.qti.hardware.display.mapperextensions@1.0.so \
         vendor.qti.hardware.display.mapperextensions@1.1.so; do
  copy /vendor/lib64/$f lib64/$f
done
copy /vendor/bin/hw/vendor.qti.hardware.display.allocator-service bin/vendor.qti.hardware.display.allocator-service

# ---- oplus 依赖
for f in vendor.oplus.hardware.cryptoeng@1.0.so vendor.oplus.hardware.commondcs@1.0.so; do
  copy /vendor/lib64/$f lib64/$f
done

# ---- 固件
for f in cryptoeng.mdt cryptoeng.b00 cryptoeng.b01 cryptoeng.b02 cryptoeng.b03 cryptoeng.b04 \
         cryptoeng.b05 cryptoeng.b06 cryptoeng.b07; do
  copy /vendor/firmware/$f firmware/$f
done
for pat in a660_gmu.bin a660_sqe.fw; do copy /vendor/firmware/$pat firmware/$pat; done
for f in ipa_fws.mdt ipa_fws.b00 ipa_fws.b01 ipa_fws.b02 ipa_fws.b03 ipa_fws.b04 ipa_uc.elf; do
  copy /vendor/firmware/$f firmware/$f
done

# ---- VINTF manifests
copy /system/etc/vintf/manifest.xml vintf/system_manifest.xml
copy /vendor/etc/vintf/manifest.xml vintf/vendor_manifest.xml
for f in android.hardware.boot@1.2.xml android.hardware.graphics.mapper-impl-qti-display.xml \
         vendor.qti.hardware.display.allocator-service.xml; do
  copy /vendor/etc/vintf/manifest/$f vintf/manifest/$f
done

# ---- 拿不到的（oplus 专有路径）多试几个位置
try_paths() { # $1=name $2=dest
  for p in /vendor/lib64/$1 /odm/lib64/$1 /vendor/lib/$1 /odm/lib/$1; do copy "$p" "$2"; done
}
try_paths vendor.oplus.hardware.cryptoeng@1.0.so lib64/vendor.oplus.hardware.cryptoeng@1.0.so

echo "--- 完成，输出在 $OUT"
find "$OUT" -type f | wc -l
du -sh "$OUT"
echo "拉回: adb pull $OUT <本地目录>"

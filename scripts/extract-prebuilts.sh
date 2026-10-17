#!/bin/bash
# AERA recovery 所需 vendor blob 抽取（在已 root 的 9RT 上运行）
#   adb push scripts/extract-prebuilts.sh /data/local/tmp/
#   adb shell su -c "sh /data/local/tmp/extract-prebuilts.sh"
set -u
OUT=/sdcard/aera_prebuilt
rm -rf "$OUT"; mkdir -p "$OUT"

copy() { # $1=src $2=dest_rel
  [ -f "$1" ] || return 0
  d="$OUT/$2"; mkdir -p "$(dirname "$d")"
  cp -f "$1" "$d" 2>/dev/null && echo "  [ok] $2" || true
}

# 在多个分区的常见位置里找同名文件
find_and_copy() { # $1=name $2=dest_rel
  local n="$1" d="$2" p found=0
  for p in /vendor/bin/hw/"$n" /vendor/bin/"$n" /odm/bin/hw/"$n" /odm/bin/"$n" \
           /vendor/lib64/"$n" /odm/lib64/"$n" /vendor/lib64/hw/"$n" /odm/lib64/hw/"$n" \
           /vendor/lib/"$n" /odm/lib/"$n"; do
    if [ -f "$p" ]; then copy "$p" "$d"; found=1; break; fi
  done
  [ $found -eq 0 ] && echo "  [缺] $n"
}

echo "== HAL 服务"
find_and_copy android.hardware.keymaster@4.1-service-qti     bin/android.hardware.keymaster@4.1-service-qti
find_and_copy android.hardware.gatekeeper@1.0-service-qti    bin/android.hardware.gatekeeper@1.0-service-qti
find_and_copy qseecomd                                       bin/qseecomd
find_and_copy qrtr-ns                                        bin/qrtr-ns
find_and_copy vendor.qti.hardware.cryptoeng@1.0-service      bin/vendor.qti.hardware.cryptoeng@1.0-service
find_and_copy vendor.qti.hardware.vibrator@1.2-service       bin/vendor.qti.hardware.vibrator@1.2-service
find_and_copy vendor.qti.hardware.display.allocator-service  bin/vendor.qti.hardware.display.allocator-service

echo "== keymaster / gatekeeper / FBE 依赖库"
for f in libqtikeymaster4.so libkeymasterdeviceutils.so libkeymasterprovision.so \
         libkeymasterutils.so libQSEEComAPI.so libdiag.so libdrm.so libdrmfs.so \
         libdrmtime.so libdrmutils.so librpmb.so libsecureui.so libsecureui_svcsock.so \
         libspl.so libssd.so libtime_genoff.so libidl.so libqmi_cci.so libqmi_common_so.so \
         libqmi_csi.so libqmi_encdec.so libqmiservices.so libqservice.so \
         libperipheral_client.so libspcom.so libGPreqcancel.so libGPreqcancel_svc.so \
         libStDrvInt.so libops.so liboemnvbk_img_helper.so libjson.so libmdmdetect.so \
         libqisl.so libdsutils.so libcld80211.so libqcbor.so libkeymaster_messages.so \
         libsoc_helper.so; do
  find_and_copy "$f" "lib64/$f"
done
find_and_copy android.hardware.gatekeeper@1.0-impl-qti.so hw/android.hardware.gatekeeper@1.0-impl-qti.so
find_and_copy libboot_control_qti.so lib64/libboot_control_qti.so
[ -f /vendor/lib64/hw/libboot_control_qti.so ] && copy /vendor/lib64/hw/libboot_control_qti.so hw/libboot_control_qti.so
[ -f /vendor/lib64/hw/android.hardware.boot@1.0-impl-1.1-qti.so ] && \
  copy /vendor/lib64/hw/android.hardware.boot@1.0-impl-1.1-qti.so hw/android.hardware.boot@1.0-impl-1.1-qti.so

echo "== 振动（可选）"
for f in libaacvibrator.so vendor.qti.hardware.vibrator.impl.so; do
  find_and_copy "$f" "lib64/$f"
done

echo "== 显示 / gralloc / EGL"
find_and_copy gralloc.lahaina.so hw/gralloc.lahaina.so
for f in libgralloc.qti.so libgralloccore.so libgralloctypes.so libgrallocutils.so \
         libdisplayconfig.qti.so libqdMetaData.so libqdutils.so libnativewindow.so libui.so \
         libadreno_utils.so libgsl.so libllvm-glnext.so; do
  find_and_copy "$f" "lib64/$f"
done
for f in eglSubDriverAndroid.so libEGL_adreno.so libGLESv2_adreno.so; do
  [ -f /vendor/lib64/egl/$f ] && copy /vendor/lib64/egl/$f "egl/$f"
done
for f in android.hardware.graphics.mapper@3.0-impl-qti-display.so \
         android.hardware.graphics.mapper@4.0-impl-qti-display.so; do
  [ -f /vendor/lib64/hw/$f ] && copy /vendor/lib64/hw/$f "hw/$f"
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
         vendor.qti.hardware.display.mapper@4.0.so \
         vendor.qti.hardware.display.mapperextensions@1.0.so \
         vendor.qti.hardware.display.mapperextensions@1.1.so \
         vendor.oplus.hardware.cryptoeng@1.0.so vendor.oplus.hardware.commondcs@1.0.so; do
  find_and_copy "$f" "lib64/$f"
done

echo "== 内核模块（只取 recovery 需要的）"
mkdir -p "$OUT/modules"
for f in msm_drm.ko aw8697.ko; do
  for p in /vendor/lib/modules/"$f" /vendor/lib/modules/5.4-gki/"$f"; do
    [ -f "$p" ] && cp -f "$p" "$OUT/modules/$f" && echo "  [ok] modules/$f" && break
  done
done
for f in modules.dep modules.alias modules.softdep modules.load; do
  for p in /vendor/lib/modules/"$f" /vendor/lib/modules/5.4-gki/"$f"; do
    [ -f "$p" ] && cp -f "$p" "$OUT/modules/$f" && echo "  [ok] modules/$f" && break
  done
done

echo "== 固件"
for f in cryptoeng.mdt cryptoeng.b00 cryptoeng.b01 cryptoeng.b02 cryptoeng.b03 \
         cryptoeng.b04 cryptoeng.b05 cryptoeng.b06 cryptoeng.b07 \
         a660_gmu.bin a660_sqe.fw ipa_fws.mdt ipa_fws.b00 ipa_fws.b01 ipa_fws.b02 \
         ipa_fws.b03 ipa_fws.b04 ipa_fws.elf ipa_uc.elf; do
  [ -f /vendor/firmware/$f ] && copy /vendor/firmware/$f "firmware/$f"
done

echo "== VINTF"
mkdir -p "$OUT/vintf/manifest"
copy /system/etc/vintf/manifest.xml vintf/system_manifest.xml
copy /vendor/etc/vintf/manifest.xml vintf/vendor_manifest.xml
for f in android.hardware.boot@1.1.xml android.hardware.boot@1.2.xml \
         android.hardware.health@2.1.xml \
         android.hardware.graphics.mapper-impl-qti-display.xml \
         vendor.qti.hardware.display.allocator-service.xml \
         vendor.qti.hardware.vibrator.service.xml; do
  for p in /vendor/etc/vintf/manifest/"$f" /odm/etc/vintf/manifest/"$f"; do
    [ -f "$p" ] && cp -f "$p" "$OUT/vintf/manifest/$f" && echo "  [ok] vintf/manifest/$f"
  done
done
for f in /vendor/etc/vintf/manifest/*.xml; do
  [ -f "$f" ] && cp -f "$f" "$OUT/vintf/manifest/" 2>/dev/null
done

echo "== 杂项配置"
copy /vendor/etc/gpfspath_oem_config.xml etc/gpfspath_oem_config.xml
copy /vendor/etc/task_profiles.json etc/task_profiles.json
copy /vendor/etc/aac_richtap.config etc/aac_richtap.config

echo "--- 完成: $(find "$OUT" -type f | wc -l) 个文件, $(du -sh "$OUT" | cut -f1)"
echo "拉回: adb pull $OUT <本地目录>"

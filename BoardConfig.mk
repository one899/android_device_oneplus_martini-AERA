#
# AERA Recovery - OnePlus 9RT (martini / MT2110 / SM8350 lahaina)
#

DEVICE_PATH := device/oneplus/martini

BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_PLUGIN_VALIDATION := soong-libaosprecovery_defaults soong-libguitwrp_defaults soong-libminuitwrp_defaults soong-vold_defaults

# ---------------------------------------------------------------- architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a77

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55

# ------------------------------------------------------------------- platform
TARGET_BOARD_PLATFORM := lahaina
TARGET_BOARD_PLATFORM_GPU := qcom-adreno660
QCOM_BOARD_PLATFORMS += lahaina
TARGET_BOOTLOADER_BOARD_NAME := lahaina
TARGET_NO_BOOTLOADER := true
TARGET_USES_UEFI := true
TARGET_USES_HARDWARE_QCOM_BOOTCTRL := true

# --------------------------------------------------------------------- kernel
# OnePlus 9RT uses boot header v3: kernel + ramdisk live in /boot (no dtb here).
# Kernel comes from the EEVDF-optimised OnePlus SM8350 5.4.295 build.
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
BOARD_KERNEL_IMAGE_NAME := Image
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image
TARGET_NO_KERNEL := false

BOARD_BOOT_HEADER_VERSION := 3
BOARD_KERNEL_PAGESIZE := 4096
BOARD_HEADER_SIZE := 1580
BOARD_KERNEL_CMDLINE :=
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_KERNEL_PAGESIZE)

# ----------------------------------------------------------------- partitions
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS := \
    boot \
    dtbo \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    system \
    system_ext \
    product \
    vendor \
    vendor_dlkm \
    odm

BOARD_AVB_ENABLE := true
BOARD_FLASH_BLOCK_SIZE := 131072

# boot_a / boot_b are 192 MiB; recovery is flashed there (no recovery partition).
BOARD_BOOTIMAGE_PARTITION_SIZE := 201326592
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 201326592
BOARD_DTBOIMG_PARTITION_SIZE := 25165824

BOARD_SUPER_PARTITION_SIZE := 13000003584
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 12999983104
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    system \
    system_ext \
    product \
    vendor \
    vendor_dlkm \
    odm

BOARD_USES_METADATA_PARTITION := true
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_USES_QCOM_FBE_DECRYPTION := true

# ------------------------------------------------------------------- recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_QCOM_RTC_FIX := true
TARGET_RECOVERY_WIPE := $(DEVICE_PATH)/recovery.wipe
TARGET_RECOVERY_DEVICE_MODULES += libion
RECOVERY_LIBRARY_SOURCE_FILES += $(TARGET_OUT_SHARED_LIBRARIES)/libion.so
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop

AERA_INCLUDE_CRYPTO := true
AERA_INCLUDE_CRYPTO_FBE := true
AERA_INCLUDE_FBE_METADATA_DECRYPT := true
AERA_USE_FSCRYPT_POLICY := 2
AERA_SKIP_ADDITIONAL_FSTAB := true
AERA_NO_BIND_SYSTEM := true
AERA_INCLUDE_FASTBOOTD := true
AERA_INCLUDE_LPTOOLS := true
AERA_INCLUDE_LPDUMP := true
AERA_INCLUDE_REPACKTOOLS := true
AERA_INCLUDE_RESETPROP := true
AERA_INCLUDE_LIBRESETPROP := true
AERA_INCLUDE_LOGCAT := true
AERA_ENABLE_ALL_PARTITION_TOOLS := true
AERA_USE_TOOLBOX := true
AERA_USE_GREEN_LED := 0
AERA_THEME := portrait_hdpi
AERA_FRAMERATE := 60

# Panel: /sys/class/backlight/panel0-backlight (same node as stock recovery)
AERA_BRIGHTNESS_PATH := "/sys/class/backlight/panel0-backlight/brightness"
AERA_MAX_BRIGHTNESS := 2047
AERA_DEFAULT_BRIGHTNESS := 800
AERA_NO_SCREEN_BLANK := true

AERA_DEFAULT_LANGUAGE := en
AERA_EXTRA_LANGUAGES := true
AERA_HAS_EDL_MODE := true
AERA_USE_SERIALNO_PROPERTY_FOR_DEVICE_ID := true
AERA_DEVICE_VERSION := OnePlus_9RT
AERA_UI_ADAPTIVE_RESOLUTION := true
AERA_EXCLUDE_APEX := true
AERA_LOAD_VENDOR_MODULES := "aera_post_decrypt_stage_only.ko"
AERA_LOAD_VENDOR_MODULES_EXCLUDE_GKI := true
AERA_POST_DECRYPT_MODULES := "aera_post_decrypt_stage_only.ko"

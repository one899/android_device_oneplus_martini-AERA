LOCAL_PATH := device/oneplus/martini

# OnePlus 9RT shipped with Android 11.
BOARD_SHIPPING_API_LEVEL := 30
PRODUCT_SHIPPING_API_LEVEL := 30

PRODUCT_USE_DYNAMIC_PARTITIONS := true

PRODUCT_VENDOR_PROPERTIES += \
    ro.hardware.egl=adreno \
    ro.hardware.gralloc=lahaina

PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl \
    android.hardware.boot@1.2-service \
    bootctrl.lahaina \
    libion \
    qcom_decrypt \
    qcom_decrypt_fbe

RECOVERY_LIBRARY_SOURCE_FILES += \
    $(TARGET_OUT_SHARED_LIBRARIES)/libion.so

PRODUCT_PACKAGES += \
    lpflash \
    lpmake \
    lpunpack

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/systemmanifest.xml:$(TARGET_COPY_OUT_RECOVERY)/root/system/manifest.xml \
    $(LOCAL_PATH)/prebuilt/vendormanifest.xml:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/manifest.xml

PRODUCT_SOONG_NAMESPACES += $(LOCAL_PATH)

$(call inherit-product, $(LOCAL_PATH)/aera_martini.mk)

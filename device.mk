LOCAL_PATH := device/oneplus/martini

# OnePlus 9RT shipped with Android 11.
BOARD_SHIPPING_API_LEVEL := 30
PRODUCT_SHIPPING_API_LEVEL := 30

PRODUCT_USE_DYNAMIC_PARTITIONS := true

PRODUCT_VENDOR_PROPERTIES += \
    ro.hardware.egl=adreno \
    ro.hardware.gralloc=lahaina

# The HIDL boot HAL (vendor.boot-hal-1-1), keymaster and gatekeeper are shipped
# prebuilt from the ROM under recovery/root, so nothing is built from
# device/qcom (aera-16.0 has no qcom_decrypt / bootctrl packages any more).
PRODUCT_PACKAGES += \
    libion

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
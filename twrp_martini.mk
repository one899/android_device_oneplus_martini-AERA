$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)
$(call inherit-product, vendor/twrp/config/common.mk)
$(call inherit-product, device/oneplus/martini/device.mk)

PRODUCT_DEVICE := martini
PRODUCT_NAME := twrp_martini
PRODUCT_BRAND := OnePlus
PRODUCT_MODEL := OnePlus 9RT
PRODUCT_MANUFACTURER := OnePlus
PRODUCT_RELEASE_NAME := martini
PRODUCT_GMS_CLIENTID_BASE := android-oneplus

AERA_STATUS_ICONS_ALIGN := center

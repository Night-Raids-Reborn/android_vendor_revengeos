# Copyright (C) 2019 RevengeOS
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include vendor/revengeos/config/fingerprint.mk
include vendor/revengeos/config/version.mk

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/revengeos/overlay
DEVICE_PACKAGE_OVERLAYS += \
    vendor/revengeos/overlay/common

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# Backup Tool
ifeq ($(AB_OTA_UPDATER),true)
PRODUCT_COPY_FILES += \
    vendor/revengeos/prebuilt/common/bin/backuptool_ab.sh:system/bin/backuptool_ab.sh \
    vendor/revengeos/prebuilt/common/bin/backuptool_ab.functions:system/bin/backuptool_ab.functions \
    vendor/revengeos/prebuilt/common/bin/backuptool_postinstall.sh:system/bin/backuptool_postinstall.sh
endif

PRODUCT_COPY_FILES += \
    vendor/revengeos/prebuilt/common/bin/backuptool.sh:$(TARGET_COPY_OUT_SYSTEM)/install/bin/backuptool.sh \
    vendor/revengeos/prebuilt/common/bin/backuptool.functions:$(TARGET_COPY_OUT_SYSTEM)/install/bin/backuptool.functions \
    vendor/revengeos/prebuilt/common/bin/50-cm.sh:system/addon.d/50-cm.sh

# Copy all custom init rc files
$(foreach f,$(wildcard vendor/revengeos/prebuilt/common/etc/init/*.rc),\
	$(eval PRODUCT_COPY_FILES += $(f):$(TARGET_COPY_OUT_SYSTEM)/etc/init/$(notdir $f)))

# Face Unlock
TARGET_FACE_UNLOCK_SUPPORTED ?= true
ifeq ($(TARGET_FACE_UNLOCK_SUPPORTED),true)
PRODUCT_PACKAGES += \
    FaceUnlockService
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.face_unlock_service.enabled=$(TARGET_FACE_UNLOCK_SUPPORTED)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.biometrics.face.xml
endif

# system mount
PRODUCT_COPY_FILES += \
    vendor/revengeos/prebuilt/common/bin/system-mount.sh:$(TARGET_COPY_OUT_SYSTEM)/install/bin/system-mount.sh

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Packages
include vendor/revengeos/config/packages.mk

# Props
include vendor/revengeos/config/props.mk

# RevengeUI
include vendor/revengeui/config.mk

# Sensitive Phone Numbers list
PRODUCT_COPY_FILES += \
    vendor/revengeos/prebuilt/common/etc/sensitive_pn.xml:system/etc/sensitive_pn.xml

# Priv-app permissions
ifeq ($(REVENGEOS_BUILDTYPE),OFFICIAL)
PRODUCT_COPY_FILES += \
    vendor/revengeos/config/permissions/com.revengeos.ota.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/com.revengeos.ota.xml
endif

PRODUCT_COPY_FILES += \
    vendor/revengeos/config/permissions/com.android.screenshot.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/com.android.screenshot.xml \
    vendor/revengeos/config/permissions/privapp-permissions-livedisplay-system_ext.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-livedisplay-system_ext.xml \
    vendor/revengeos/config/permissions/privapp-permissions-revengeos-system.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-revengeos-system.xml \
    vendor/revengeos/config/permissions/privapp-permissions-revengeos-product.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-revengeos-product.xml

# Hidden API whitelist
PRODUCT_COPY_FILES += \
    vendor/revengeos/config/sysconfig/revengeos-hiddenapi-package-whitelist.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/revengeos-hiddenapi-package-whitelist.xml

# Spoof fingerprint for Google Play Services and SafetyNet
ifeq ($(PRODUCT_OVERRIDE_GMS_FINGERPRINT),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.build.gms_fingerprint=google/walleye/walleye:8.1.0/OPM1.171019.011/4448085:user/release-keys
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.build.gms_fingerprint=$(PRODUCT_OVERRIDE_GMS_FINGERPRINT)
endif

# Include Lawnchair
ifeq ($(USE_LAWNCHAIR), true)
$(call inherit-product, vendor/lawnchair/lawnchair.mk)
endif

# Gapps
ifeq ($(WITH_GAPPS), true)
$(call inherit-product, vendor/gapps/config.mk)
endif

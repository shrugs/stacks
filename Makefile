# export ARCHS=armv7
export TARGET=iphone:clang
export THEOS_DEVICE_IP=192.168.1.90

include theos/makefiles/common.mk

TWEAK_NAME = stacks
stacks_FILES = Tweak.xm
stacks_FRAMEWORKS = UIKit CoreGraphics Quartzcore Foundation
stacks_PRIVATE_FRAMEWORKS = Preferences

SUBPROJECTS = stackssettings
THEOS_BUILD_DIR = debs

include theos/makefiles/aggregate.mk
include $(THEOS_MAKE_PATH)/tweak.mk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BaseBadges
$(TWEAK_NAME)_FILES = $(wildcard *.xm *.m)
$(TWEAK_NAME)_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
#	install.exec "rm -f /var/mobile/Library/Preferences/org.midey.basebadges.plist ; killall -9 SpringBoard"

SUBPROJECTS += basebadgesprefs

include $(THEOS_MAKE_PATH)/aggregate.mk

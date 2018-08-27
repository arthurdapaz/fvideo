ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FVideo
FVideo_FILES = Tweak.xm $(wildcard incs/MBFileDownloader/*.m)
FVideo_FRAMEWORKS = UIKit AudioToolbox Photos
FVideo_LIBRARIES = substrate
FVideo_CFLAGS = -fobjc-arc
FVideo_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Facebook"


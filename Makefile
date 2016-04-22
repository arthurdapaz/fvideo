ARCHS = armv7 arm64
TARGET = iphone:clang:8.1:8.1
CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

include $(THEOS)/makefiles/bundle.mk

TWEAK_NAME = FVideo
FVideo_FILES = Tweak.xm $(wildcard incs/TWRDownloadManager/*.m) $(wildcard incs/JGProgressHUD/*.m)
FVideo_FRAMEWORKS = UIKit AudioToolbox Foundation CFNetwork CoreLocation CoreVideo CoreGraphics QuartzCore CoreImage MobileCoreServices CoreMedia Photos
FVideo_LIBRARIES = substrate
FVideo_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"


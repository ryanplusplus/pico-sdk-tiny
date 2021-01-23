export GNUMAKEFLAGS := --no-print-directory

ifeq ($(DEBUG),Y)
CMAKE_FLAGS := -DCMAKE_BUILD_TYPE=Debug
BUILD_TYPE := debug
else
BUILD_TYPE := release
endif

.PHONY: all
all: build/$(BUILD_TYPE)/Makefile
	@+cmake --build build/$(BUILD_TYPE)

build/$(BUILD_TYPE)/Makefile:
	@+cmake $(CMAKE_FLAGS) -B build/$(BUILD_TYPE) .

.PHONY: clean
clean:
	@rm -rf build

%:
	@+cmake --build build/$(BUILD_TYPE) --target $@

.PHONY: upload
upload: all
	tools/openocd/build/bin/openocd -f tools/upload-$(BUILD_TYPE).cfg

.PHONY: erase
erase:
	tools/openocd/build/bin/openocd -f tools/erase.cfg

.PHONY: debug-deps
debug-deps: tools/openocd/build/bin/openocd all

tools/openocd/build/bin/openocd:
	@git clone https://github.com/raspberrypi/openocd.git --recursive --branch rp2040 --depth=1 tools/openocd
	@(cd tools/openocd; ./bootstrap && ./configure --prefix=`pwd`/build && $(MAKE) && $(MAKE) install)

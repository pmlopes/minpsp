TARGET = JelloTest
OBJS = main.o

CFLAGS = -O3 -G0 -Wall
CXXFLAGS = $(CFLAGS) -fno-exceptions -fno-rtti
ASFLAGS = $(CFLAGS)

INCDIR = $(PSPPATH)/include
LIBS = -lJello -lglut -lGLU -lGL -lpspvfpu -lpspge -lpspsdk -lpspctrl -lpspumd -lpsprtc -lpsppower -lpspgum -lpspgu -lm -lstdc++


EXTRA_TARGETS = EBOOT.PBP
PSP_EBOOT_TITLE = Soft Body Test

PSPSDK=$(shell psp-config --pspsdk-path)
include $(PSPSDK)/lib/build.mak


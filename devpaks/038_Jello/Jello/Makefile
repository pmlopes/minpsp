TARGET_LIB = libJello.a
OBJS = AABB.o Body.o ClosedShape.o PointMass.o PressureBody.o SpringBody.o Vector2.o Vector3.o VectorTools.o World.o

PSPSDK = $(shell psp-config --pspsdk-path)
PSPPATH = $(shell psp-config --psp-prefix)

INCDIR = $(PSPPATH)/include
CFLAGS = -O3 -G0 -W -Wall
CXXFLAGS = $(CFLAGS) -fno-exceptions -fno-rtti
ASFLAGS = $(CFLAGS)

include $(PSPSDK)/lib/build.mak

install: $(TARGET_LIB)
	mkdir -p $(PSPPATH)/include/Jello $(PSPPATH)/lib
	cp *.h $(PSPPATH)/include/Jello
	cp libJello.a $(PSPPATH)/lib

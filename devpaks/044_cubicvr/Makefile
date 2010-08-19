TARGET_LIB = libcubicvr.a
CUBICVR_OBJS = ../cubicvr/src/Gamepad.o			\
		../cubicvr/src/Envelope.o		\
		../cubicvr/src/Face.o			\
		../cubicvr/src/IFFReader.o		\
		../cubicvr/src/lodepng.o		\
		../cubicvr/src/Matrix.o			\
		../cubicvr/src/Motion.o			\
		../cubicvr/src/RGB.o			\
		../cubicvr/src/RGBA.o 			\
		../cubicvr/src/Timer.o			\
		../cubicvr/src/Transform.o		\
		../cubicvr/src/psp/TGALoader.o		\
		../cubicvr/src/Vector.o			\
		../cubicvr/src/XYZ.o			\
		../cubicvr/src/XYZRGB.o			\
		../cubicvr/src/SectorMap.o		\
		../cubicvr/src/BITSET.o			\
		../cubicvr/src/math/MATRIX4X4.o		\
		../cubicvr/src/math/PLANE.o		\
		../cubicvr/src/math/VECTOR3D.o		\
		../cubicvr/src/Resource.o		\
		../cubicvr/src/ResourcePool.o		\
		../cubicvr/src/ResourceManager.o	\
		../cubicvr/src/Logger.o			\
		../cubicvr/src/StringUtil.o		\
		../cubicvr/src/tinyxml/tinystr.o	\
		../cubicvr/src/tinyxml/tinyxml.o	\
		../cubicvr/src/tinyxml/tinyxmlparser.o	\
		../cubicvr/src/tinyxml/tinyxmlerror.o
 
CUBICVR_GL_OBJS = ../cubicvr/src/Camera.o		\
		../cubicvr/src/GLExt.o			\
		../cubicvr/src/Texture.o		\
		../cubicvr/src/Light.o			\
		../cubicvr/src/Material.o		\
		../cubicvr/src/Object.o			\
		../cubicvr/src/objectLWO.o		\
		../cubicvr/src/UV.o			\
		../cubicvr/src/UVMapper.o		\
		../cubicvr/src/SceneObject.o		\
		../cubicvr/src/ObjectController.o	\
		../cubicvr/src/Scene.o			\
		../cubicvr/src/sceneLWS.o		\
		../cubicvr/src/Shader.o			\
		../cubicvr/src/CollisionMap.o		\
		../cubicvr/src/datatree/DataTree.o	\
		../cubicvr/src/FRUSTUM.o
 
CUBICVR_DYNAMICS_OBJS = ../cubicvr/src/RigidScene.o		\
		../cubicvr/src/SceneObjects/RigidSceneObject.o	\
		../cubicvr/src/SceneObjects/Landscape.o		\
		../cubicvr/src/SceneObjects/Vehicle.o		\
		../cubicvr/src/SceneObjects//RigidBox.o		\
		../cubicvr/src/SceneObjects/RigidSphere.o	\
		../cubicvr/src/SoftScene.o			\
		../cubicvr/src/SceneObjects/SoftSceneObject.o
 
# Particle.o ParticleEmitter.o ParticleSystem.o systemfont.o   CollisionMap.o Bone.o 
# not used: Bitmap.o Font.o
 
OBJS = $(CUBICVR_OBJS) $(CUBICVR_GL_OBJS) $(CUBICVR_DYNAMICS_OBJS)
 
PSPSDK=$(shell psp-config --pspsdk-path)
INCDIR = $(PSPSDK)/../include/bullet ../cubicvr/include .
CFLAGS = -O2 -G0 -Wall
CXXFLAGS = $(CFLAGS) -fexceptions -DARCH_PSP -pipe -Wno-unknown-pragmas -fomit-frame-pointer -ffast-math
ASFLAGS = $(CFLAGS)
 
LIBDIR =
LDFLAGS =
 
include $(PSPSDK)/lib/build.mak
 
install: $(TARGET_LIB)
	mkdir -p ../../target/psp/lib
	mkdir -p ../../target/psp/include
	cp $(TARGET_LIB) ../../target/psp/lib
	cp -R ../cubicvr/include/CubicVR  ../../target/psp/include
	rm -Rf `find ../../target/psp/include | grep .svn`
	mkdir -p ../../target/psp/sdk/samples
	cp -R samples ../../target/psp/sdk/samples/cubicvr
	rm -Rf `find ../../target/psp/sdk/samples/cubicvr | grep .svn`

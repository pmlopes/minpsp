/*
Copyright (c) 2007 Walaber

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#ifndef Body_H
#define Body_H

#include <vector>

#include "Vector2.h"
#include "Vector3.h"
#include "AABB.h"
#include "Bitmask.h"
#include "PointMass.h"
#include "ClosedShape.h"

#include "Renderer.h"

/**
* contains base functionality for all bodies in the JelloPhysics world.  all bodies are
* made up of a ClosedShape geometry, and a list of PointMass objects equal to the number of vertices in the
* ClosedShape geometry.  The vertices are considered to be connected by lines in order, which creates the collision
* volume for this body.  Individual implementations of Body handle forcing the body to keep it's shape through
* various methods.
*/
class Body
{
public:

	ClosedShape *mBaseShape;
    Vector2 *mGlobalShape;
	std::vector<PointMass*> mPointMasses;
	int mPointMassesC;
    Vector2 mScale;
	Vector2 mDerivedPos;
	Vector2 mDerivedVel;
	float mDerivedAngle;
	float mDerivedOmega;
	float mLastAngle;

	AABB *mAABB;
	int mMaterial;
	bool mIsStatic;
	bool mKinematic;

	int mShapeCount;

	Bitmask *mBitMaskX ;
	Bitmask *mBitMaskY ;;

	float PI;

	int Type;


	/**
	* default constructor.
	*/
	Body();
	/**
	* Default destructor
	*/
	virtual ~Body();

	/**
	* create a body, and set its shape and position immediately
    *\param shape closed shape for this body
    *\param massPerPoint mass for each PointMass to be created
    *\param position global position of the body
    *\param angleInRadians global angle of the body
    *\param scale local scale of the body
    *\param kinematic whether this body is kinematically controlled
	*/
	Body(ClosedShape *shape, float massPerPoint, Vector2 position, float angleInRadians, Vector2 scale, bool kinematic);
	/**
	* create a body, and set its shape and position immediately - with individual masses for each PointMass.
	*\param shape closed shape for this body
    *\param pointMasses list of masses for each PointMass
    *\param position global position of the body
    *\param angleInRadians global angle of the body
    *\param scale local scale of the body
    *\param kinematic whether this body is kinematically controlled
	*/
	Body(ClosedShape *shape, std::vector<float> pointMasses, Vector2 position, float angleInRadians, Vector2 scale, bool kinematic);
	/**
	* set the mass for each PointMass in this body.
	*/
	void setMassAll(float mass);
	/**
	* set the mass for each PointMass individually.
	*\param index index of the PointMass
	*\param mass new mass
	*/
	void setMassIndividual(unsigned int index, float mass);
	/**
	* set the mass for all point masses from a list.
	*\param masses list of masses
	*/
	void setMassFromList(std::vector<float> masses);
	/**
	* Material for this body.  Used for physical interaction and collision notification.
	*/
	int Material();
	/**
	* Set the position and angle of the body manually.
	*\param pos new position
	*\param angleInRadians global angle
	*\param scale scale of the body
	*/
	virtual void setPositionAngle(Vector2 pos, float angleInRadians, Vector2 scale);
	/**
	* set the shape of this body to a new ClosedShape object.  This function 
    * will remove any existing PointMass objects, and replace them with new ones IF
    * the new shape has a different vertex count than the previous one.  In this case
    * the mass for each newly added point mass will be set zero.  Otherwise the shape is just
    * updated, not affecting the existing PointMasses.
	*/
	void setShape(ClosedShape *shape);
	/**
	* update the AABB for this body, including padding for velocity given a timestep.
    * This function is called by the World object on Update(), so the user should not need this in most cases.
	*\param elapsed elapsed delta time
	*\param forceUpdate
	*/
	void updateAABB(float elapsed, bool forceUpdate);
	/**
	* For moving a body kinematically.  sets the position in global space.  via shape-matching, the
    * body will eventually move to this location.
	*\param pos new position
	*/
	virtual void setKinematicPosition(Vector2 pos);
	/**
	* For moving a body kinematically.  sets the angle in global space.  via shape-matching, the
    * body will eventually rotate to this angle.
	*param angleInRadians angle in radians
	*/
	virtual void setKinematicAngle(float angleInRadians);
	/**
	* For changing a body kinematically.  via shape matching, the body will eventually
    * change to the given scale.
	*\param scale new scale
	*/
	virtual void setKinematicScale(Vector2 &scale);
	/**
	* Derive the global position and angle of this body, based on the average of all the points.
    * This updates the DerivedPosision, DerivedAngle, and DerivedVelocity properties.
    * This is called by the World object each Update(), so usually a user does not need to call this.  Instead
    * you can juse access the DerivedPosition, DerivedAngle, DerivedVelocity, and DerivedOmega properties.
	*\param elaspsed elapsed delta time
	*/
	void derivePositionAndAngle(float elaspsed);
	/**
	* Derived position of the body in global space, based on location of all PointMasses.
	*/
	Vector2 DerivedPosition();
	/**
	* Derived global angle of the body in global space, based on location of all PointMasses.
	*/
	float DerivedAngle();
	/**
	* Derived global velocity of the body in global space, based on velocity of all PointMasses.
	*/
	Vector2 DerivedVelocity();
	/**
	* Derived rotational velocity of the body in global space, based on changes in DerivedAngle.
	*/
	float DerivedOmega();

	/**
	* this function should add all internal forces to the Force member variable of each PointMass in the body.
    * these should be forces that try to maintain the shape of the body.
	*/
	virtual void accumulateInternalForces() { }
	/**
	* this function should add all external forces to the Force member variable of each PointMass in the body.
    * these are external forces acting on the PointMasses, such as gravity, etc.
	*/
	virtual void accumulateExternalForces() { }
	/**
	* ...
	*/
	void integrate(float elapsed);
	/**
	* ...
	*/
	void dampenVelocity(float damp);
	/**
	* get the Axis-aligned bounding box for this body.  used for broad-phase collision checks.
	*\return AABB for this body
	*/
	AABB *getAABB();
	/**
	* collision detection.  detect if a global point is inside this body.
	*\param pt point in global space
	*\return true = point is inside body, false = it is not.
	*/
	bool contains(Vector2 pt);
	/**
	* collision detection - given a global point, find the point on this body that is closest to the global point,
    * and if it is an edge, information about the edge it resides on.
	*\param pt global point
	*\param hitPt returned point on the body in global space
	*\param normal returned normal on the body in global space
	*\param pointA returned ptA on the edge
	*\param pointB returned ptB on the edge
	*\param edgeD returned ptB on the edge
	*return distance
	*/
	float getClosestPoint(Vector2 pt, Vector2 &hitPt, Vector2 &normal, int &pointA, int &pointB, float &edgeD);
	/**
	* find the distance from a global point in space, to the closest point on a given edge of the body.
	*\param pt global point
	*\param edgeNum edge to check against.  0 = edge from pt[0] to pt[1], etc.
	*\param hitPt returned point on edge in global space
	*\param normal returned normal on edge in global space
	*\param edgeD returned distance along edge from ptA to ptB [0][1]
	*\return distance
	*/
	float getClosestPointOnEdge(Vector2 pt,int edgeNum,  Vector2 &hitPt,  Vector2 &normal,  float &edgeD);
	/**
	*  find the squared distance from a global point in space, to the closest point on a given edge of the body.
	*\param pt global point
	*\param edgeNum edge to check against.  0 = edge from pt[0] to pt[1], etc.
	*\param hitPt returned point on edge in global space
	*\param normal returned normal on edge in global space
	*\param edgeD returned distance along edge from ptA to ptB [0][1]
	*\return distance
	*/
	float getClosestPointOnEdgeSquared(Vector2 pt,int edgeNum, Vector2 &hitPt, Vector2 &normal, float &edgeD);
	/**
	* Find the closest PointMass in this body, givena global point.
	*\param pos global point
	*\param dist returned distance
	*\return index of thr PointMass
	*/
	int getClosestPointMass(Vector2 pos, float &dist);
	/**
	* Number of PointMasses in the body
	*/
	int PointMassCount();
	/**
	* Get a specific PointMass from this body.
	*\param index index
	*\return PointMass
	*/
	PointMass *getPointMass(int index);
	/**
	* Helper function to add a global force acting on this body as a whole.
	*\param pt location of force, in global space
	*\param force direction and intensity of force, in global space
	*/
	void addGlobalForce(Vector2 pt, Vector2 force);
	/**
	* Gets whether this is a static body.  setting static greatly improves performance on static bodies.
	*/
	bool IsStatic();
	/**
	* whether this body is kinematically controlled.  kinematic control requires shape-matching forces to work properly.
	*/
	bool IsKinematic();
	/**
	* Debug draw
	*/
	virtual void DrawMe();

	float myacosf(float x)
   {
		   float result;
		__asm__ volatile (
			"mtv     %1, S000\n"
			"vcst.s  S001, VFPU_PI_2\n"
			"vasin.s S000, S000\n"
			"vocp.s  S000, S000\n"
			"vmul.s  S000, S000, S001\n"
			"mfv     %0, S000\n"
			: "=r"(result) : "r"(x));
		return result;
   }

	float myasinf(float x)
   {
	       float result;
		__asm__ volatile (
			"mtv     %1, S000\n"
			"vcst.s  S001, VFPU_PI_2\n"
			"vasin.s S000, S000\n"
			"vmul.s  S000, S000, S001\n"
			"mfv     %0, S000\n"
			: "=r"(result) : "r"(x));
		return result;
   } 

	static float mysqrtf(float val)
	{
	   float ret;

	   __asm__ volatile (
		  "mtv %1, S000\n"
		  "vsqrt.s S001, S000\n"
		  "mfv %0, S001\n"
		  : "=r"(ret) : "r"(val));

	   return ret;
	} 



};

/**
* Body collision information
*/
class BodyCollisionInfo
{
public:

	/**
	* Default constructor
	*/
	BodyCollisionInfo()
	{
	}

	/**
	* Default deconstructor
	*/
	~BodyCollisionInfo()
	{
	}

	/**
	* clear all informations
	*/
	void Clear()
	{
		bodyApm = bodyBpmA = bodyBpmB = -1;
		hitPt = Vector2::ZERO;
		edgeD = 0;
		normal = Vector2::ZERO;
		penetration = 0;
	}
   
	Body *bodyA;
    int bodyApm;
    Body *bodyB;
    int bodyBpmA;
    int bodyBpmB;
    Vector2 hitPt;
    float edgeD;
    Vector2 normal;
    float penetration;
};

#endif


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


#ifndef World_H
#define World_H

#include <vector>
#include "Vector2.h"
#include "Vector3.h"
#include "VectorTools.h"
#include "AABB.h"
#include "PointMass.h" 
#include "Bitmask.h"
#include "ClosedShape.h"
#include "Body.h"
#include "CollisionFilter.h"

/**
* World - this class represents the physics world, and keeps track of all Bodies in it, coordinating integration, collision, etc.
*/
class World
{
public:

	/**
	* represents data about collision between 2 materials.
	*/
	struct MaterialPair
    {
		/// Whether these 2 materials should collide with each other or not.
        bool Collide;
		/// Amount of "bounce" when collision occurs. value range [0,1]. 0 == no bounce, 1 == 100% bounce
        float Elasticity;
		/// Amount of friction.  Value range [0,1].  0 == no friction, 1 == 100% friction, will stop on contact.
        float Friction;
		///Collision filter
        CollisionFilter collisionFilter;
    };

	std::vector<Body*> mBodies;
    AABB *mWorldLimits;
    Vector2 mWorldSize;
    Vector2 mWorldGridStep;

    float mPenetrationThreshold;
    int mPenetrationCount;

    /// material chart.
    MaterialPair mMaterialPairs[1000][1000];
    MaterialPair mDefaultMatPair;
    int mMaterialCount;

    float mDamping ;

    std::vector<BodyCollisionInfo> mCollisionList;

	/**
	* Creates the World object, and sets world limits to default (-20,-20) to (20,20).
	*/
	World();

	/**
	* get Velocity Damping
	*\return damping
	*/
	float VelocityDamping();
	/**
	* Set World limits
	*\param min minimum point
	*\param max maximum point
	*/
	void setWorldLimits(Vector2 min, Vector2 max);

	/**
	* Add a new material to the world.  all previous material data is kept intact.
	*\return materials count
	*/
	int addMaterial();
	/**
	* Get amount of materials
	*\return materials ammount
	*/
	int MaterialCount();
	/**
	* Set collision filter between 2 materials
	*\param a material ID A
	*\param b material ID B
	*\param filter new CollisionFilter
	*/
	void setMaterialPairFilterCallback(int a, int b, CollisionFilter filter);
	/**
	* Enable or Disable collision between 2 materials.
	*\param a material ID A
	*\param b material ID B
	*\param collide true = collide, false = ignore collision
	*/
	void setMaterialPairCollide(int a, int b, bool collide);
	/**
	* Set the collision response variables for a pair of materials.
	*\param a material ID A
	*\param b material ID B
	*\param friction [0][1] 0 = no friction, 1 = 100% friction
	*\param elasticity "bounce" [0][1] 0 = no bounce (plastic), 1 = 100% bounce (super ball)
	*/
	void setMaterialPairData(int a, int b, float friction, float elasticity);

	/**
	* Add a Body to the world.
	*\param b new Body
	*/
	void addBody(Body *b);
	/**
	* Remove a body from the world.  call this outside of an update to remove the body.
	*\param b body to remove
	*/
	void removeBody(Body *b);
	/**
	* Get a body at a specific index.
	*\param index index of the body
	*\return Body
	*/
	Body *getBody(unsigned int index);

	/**
	* Find the closest PointMass in the world to a given point.
	*\param pt global point
	*\param bodyID index of the body that contains the PointMass
	*\param pmID index of the PointMass
	*/
	void getClosestPointMass(Vector2 pt, int &bodyID, int &pmID);
	/**
	* Given a global point, get a body (if any) that contains this point.
    * Useful for picking objects with a cursor, etc.
	*\param pt global point
	*\return Body
	*/
	Body *getBodyContaining(Vector2 &pt);

	/**
	* Update the world by a specific timestep.
	*\param elapsed elapsed delta time
	*/
	void update(float elapsed);
	/**
	* Update body bitmask
	*\param body body
	*/
	void updateBodyBitmask(Body *body);

	/**
	* Collision check
	*\param bA first body
	*\param bB seconf body
	*\param infoList list with informations about the collision
	*/
	void bodyCollide(Body *bA, Body *bB, std::vector<BodyCollisionInfo> &infoList);
	/**
	* Handle collision
	*/
	void _handleCollisions();

	/**
	* This threshold allows objects to be crushed completely flat without snapping through to the other side of objects.
    * It should be set to a value that is slightly over half the average depth of an object for best results.  Defaults to 0.5.
	*\return treshold
	*/
	float PenetrationThreshold();
	/**
	* This threshold allows objects to be crushed completely flat without snapping through to the other side of objects.
    * It should be set to a value that is slightly over half the average depth of an object for best results.  Defaults to 0.5.
	*\param treshold new treshold
	*/
	void PenetrationTreshold(float treshold);
	/**
	* How many collisions exceeded the Penetration Threshold last update.  if this is a high number, you can assume that
    * the simulation has "broken" (one or more objects have penetrated inside each other).
	*\return penetration count
	*/
	int PenetrationCount();


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

#endif


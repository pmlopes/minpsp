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

#ifndef SpringBody_H
#define SpringBody_H

#include <vector>
#include "Vector2.h"
#include "Vector3.h"
#include "VectorTools.h"
#include "AABB.h"
#include "PointMass.h" 
#include "Bitmask.h"
#include "InternalSpring.h"
#include "ClosedShape.h"
#include "Body.h"

/**
* The simplest type of Body, that tries to maintain its shape through shape-matching (global springs that
* try to keep the original shape), and internal springs for support.  Shape matching forces can be
* enabled / disabled at will.
*/
class SpringBody : public Body
{
public:

	std::vector<InternalSpring*> mSprings;

    // shape-matching spring constants.
    bool mShapeMatchingOn;
    float mEdgeSpringK;
    float mEdgeSpringDamp;
    float mShapeSpringK;
    float mShapeSpringDamp;
	int dragPoint;

	//some addon
	std::vector<int> mIndexList;
	int *mIndices;
	int mIndicesCount;

	Vector2 dragForce;

	/**
	* Create a Springbody with shape matching set to OFF.
	*\param shape ClosedShape shape for this body
    *\param massPerPoint mass per PointMass.
    *\param edgeSpringK spring constant for edges.
    *\param edgeSpringDamp spring damping for edges
    *\param pos global position of the body
    *\param angleinRadians global angle of the body
    *\param scale scale
    *\param kinematic kinematic control boolean
	*/
	SpringBody(ClosedShape *shape, float massPerPoint, float edgeSpringK, float edgeSpringDamp, Vector2 pos, float angleinRadians, Vector2 scale, bool kinematic);
	/**
	* Create a SpringBody with shape matching turned ON.
	*\param shape ClosedShape shape for this body
    *\param massPerPoint mass per PointMass.
	*\param shapeSpringK shape-matching spring constant
	*\param shapeSpringDamp shape-matching spring damping
    *\param edgeSpringK spring constant for edges.
    *\param edgeSpringDamp spring damping for edges
    *\param pos global position of the body
    *\param angleinRadians global angle of the body
    *\param scale scale
    *\param kinematic kinematic control boolean
	*/
	SpringBody(ClosedShape *shape, float massPerPoint, float shapeSpringK, float shapeSpringDamp, float edgeSpringK, float edgeSpringDamp, Vector2 pos, float angleinRadians, Vector2 scale, bool kinematic);
	/**
	* Default deconstructor
	*/
	virtual ~SpringBody();

	/**
	* Add an internal spring to this body.
	*\param pointA point mass on 1st end of the spring
	*\param pointB point mass on 2nd end of the spring
	*\param springK spring constant
	*\param damping spring damping
	*/
	void addInternalSpring(int pointA, int pointB, float springK, float damping);
	/**
	* build default springs
	*/
	void _buildDefaultSprings();
	/**
	* Clear all springs from the body.
	*/
	void clearAllSprings();

	/**
	* Set shape-matching on/off.
	*\param onoff on/off
	*/
	void setShapeMatching(bool onoff);
	/**
	* Set shape-matching spring constants.
	*\param springK spring constant
	*\param damping spring damping
	*/
	void setShapeMatchingConstants(float springK, float damping);

	/**
	* Change the spring constants for the springs around the shape itself (edge springs)
	*\param edgeSpringK spring constant
	*\param edgeSpringDamp spring damping
	*/
	void setEdgeSpringConstants(float edgeSpringK, float edgeSpringDamp);
	/**
	* Adjusting spring values
	*\param springID spring index
	*\param springK spring constant
	*\param springDamp spring damping
	*/
	void setSpringConstants(int springID, float springK, float springDamp);

	/**
	* Get spring constant
	*\param springID spring index
	*\return spring constant
	*/
	float getSpringK(int springID);
	/**
	* Get spring damping
	*\param springID spring index
	*\return spring damping
	*/
	float getSpringDamping(int springID);

	/**
	* Acumulating internal spring forces
	*/
	virtual void accumulateInternalForces();
	/**
	* Acumulating external forces
	*/
	virtual void accumulateExternalForces();

	/**
	* helper function for visualization - add an indexed triangle to this primitive.
	*\param A 
	*\param B
	*\param C
	*/
	void addTriangle(int A, int B, int C);
	/**
	* finalize triangles
	*/
	void finalizeTriangles();

	/**
	* helper function for dragging body
	*\param force force for drag
	*\param pm index of PointMass that you want to drag
	*/
	void setDragForce(Vector2 force, int pm);

	/**
	* Debug render
	*/
	virtual void DrawMe();

};

#endif



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

----------------------------------------------------------------------------
Portions of this Pressure class are based on the excellent tutorial
"How to Implement Pressure Soft Body Model" by Maciej Matyka
http://panoramix.ift.uni.wroc.pl/~maq/eng/index.php

*/

#ifndef PressureBody_H
#define PressureBody_H

#include <vector>
#include "Vector2.h"
#include "Vector3.h"
#include "AABB.h"
#include "PointMass.h" 
#include "Bitmask.h"
#include "InternalSpring.h"
#include "ClosedShape.h"
#include "Body.h"
#include "SpringBody.h"

//rendering
//#include "Renderer.h"

/**
* a subclass of SpringBody, with the added element of pressurized gas inside the body.  The amount
* of pressure can be adjusted at will to inflate / deflate the object.  The object will not deflate
* much smaller than the original size of the Shape if shape matching is enabled.
*/
class PressureBody : public SpringBody
{
public:

	float mVolume;
    float mGasAmount;
    Vector2 *mNormalList;
    float *mEdgeLengthList;
	unsigned int mCount;
	
	/**
	* Default constructor, with shape-matching ON.
	*\param s ClosedShape for this body
    *\param massPerPoint mass per PointMass
    *\param gasPressure amount of gas inside the body
    *\param shapeSpringK shape-matching spring constant
    *\param shapeSpringDamp shape-matching spring damping
    *\param edgeSpringK spring constant for edges
    *\param edgeSpringDamp spring damping for edges
    *\param pos global position
    *\param angleInRadians global angle
    *\param scale scale
    *\param kinematic kinematic control boolean
	*/
	PressureBody(ClosedShape *s, float massPerPoint, float gasPressure, float shapeSpringK, float shapeSpringDamp, float edgeSpringK, float edgeSpringDamp, Vector2 pos, float angleInRadians, Vector2 scale, bool kinematic);
	/**
	* Default deconstructor
	*/
	~PressureBody();

	/**
	* Amount of gas inside the body.
	*\return amount of gas
	*/
	float GasPressure();
	/**
	* Set amount of gass in the body
	*\param gasPressure new pressure
	*/
	void GasPressure(float gasPressure);
	/**
	* Gets the last calculated volume for the body.
	*/
	float Volume();
	/**
	* Accumulate internal forces
	*/
	virtual void accumulateInternalForces();
	/**
	* Accumulate external forces
	*/
	virtual void accumulateExternalForces();
	/**
	* Debug render
	*/
	virtual void DrawMe();

};

#endif
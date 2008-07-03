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

#ifndef CollisionFilter_H
#define CollisionFilter_H

#include "Vector2.h"
#include "Body.h"

/**
* CollisionFilter class
* If you want to custom allowing/ignoring collision just make new class that inherits this one
* and reimplement collisionFilter() function
*/
class CollisionFilter
{
public:

	/**
	* Collision Filter type. return TRUE to allow collision, FALSE to ignore collision.
	*\param bodyA The colliding body
    *\param bodyApm Point mass that has collided
    *\param bodyB Body that bodyA collided with
    *\param bodyBpm1 PointMass 1 on the edge that was collided with
    *\param bodyBpm2 PointMass 2 on the edge that was collided with
    *\param hitPt Location of collision in global space
    *\param normalVel Velocity along normal of collision.
    *\return TRUE = accept collision, FALSE = ignore collision
	*/
	virtual bool collisionFilter( Body *bodyA, int bodyApm, Body *bodyB, int bodyBpm1, int bodyBpm2, Vector2 hitPt, float normalVel )
	{
		return true;
	}
};


#endif
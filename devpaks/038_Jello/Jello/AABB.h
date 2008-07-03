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

#ifndef AABB_H
#define AABB_H

#include "Vector2.h"

/**
*	class represents a 2D axis-aligned bounding box, for collision detection, etc.
*/
class AABB
{
	
public:
	
	enum PointValidity { Invalid = 0, Valid = 1 };

	//members
	/**
	* Minimum point of this bounding box.
	*/
	Vector2 Min;

	/**
	* Maximum point of this bounding box.
	*/
	Vector2 Max;

	/**
	* Property that indicated whether or not this bounding box is valid.
	*/
	PointValidity Validity;

	//constructor
	/**
	* Basic constructor.  creates a bounding box that is invalid (describes no space)
	*/
	AABB();

	/**
	* create a boundingbox with the given min and max points.
	*/
	AABB(Vector2 minPt, Vector2 maxPt);

	/**
	* Destructor
	*/
	~AABB();

	//methods
	/**
	* Resets a bounding box to invalid.
	*/
	void clear();
	
	/**
	* ... TODO
	*/
	void expandToInclude(Vector2 pt);

	/**
	* is containing point
	*/
	bool contains(Vector2 pt);

	/**
	* Test for intersection with another Body.
	*/
	bool intersects( AABB *box);

};


#endif
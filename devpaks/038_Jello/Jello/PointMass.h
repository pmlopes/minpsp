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


#ifndef PointMass_H
#define PointMass_H

#include "Vector2.h"

/**
* the most important class in JelloPhysics, all bodies in the world are made up of PointMasses, connected to form
* shapes.  Each PointMass can have its own mass, allowing for objects with different center-of-gravity.
*/
class PointMass
{
public:
	
	/**
	* Mass of thie PointMass.
	*/
	float Mass;

	/**
	* Global position of the PointMass.
	*/
	Vector2 Position;

	/**
	* Global velocity of the PointMass.
	*/
	Vector2 Velocity;

	/**
	* Force accumulation variable.  reset to Zero after each call to integrate().
	*/
	Vector2 Force;

	/**
	* Constructor
	*/
	PointMass();

	/**
	* Destructor
	*/
	~PointMass();

	/**
	* Constructor
	*/
	PointMass(float mass, Vector2 pos);

	/**
	* integrate Force >> Velocity >> Position, and reset force to zero.
	* this is usually called by the World.update() method, the user should not need to call it directly.
	*/
	void integrateForce(float elapsed);

};

#endif
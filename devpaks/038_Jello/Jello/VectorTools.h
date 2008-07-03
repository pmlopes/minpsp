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


#ifndef VECTOR_TOOLS_H
#define VECTOR_TOOLS_H

#include "Vector2.h"
#include "Vector3.h"
#include "math.h"

/**
* Some helpful vector tools.
*/
class VectorTools
{
public:

	/**
	* 
	*/
	~VectorTools();

	/**
	* rotate a vector by a given angle (in radians).
	*\param vec vector
	*\param angleRadians angle in radians 
	*\return rotated vector
	*/
	static Vector2 rotateVector(Vector2 vec, float angleRadians);
	/**
	* rotate a vector by a given angle (reference type version)
	*\param vecIn vector to rotate
	*\param angleRadians angle in radians
	*\param vecOut rotated vector
	*/
	static void rotateVector(Vector2 vecIn, float angleRadians, Vector2 &vecOut);
	/**
	* rotate a given vector by a given angle (reference type version)
	*\param vecInOut vector to rotate
	*\param angleRadians angle in radians
	*\param empty put 0 here...
	*/
	static void rotateVector(Vector2 &vecInOut, float angleRadians, int empty);

	/**
	* reflect a vector about a normal.  Normal must be a unit vector.
	*\param V vector
	*\param N normal
	*\return reflected vector
	*/
	static Vector2 reflectVector(Vector2 V, Vector2 N);
	/**
	* reflect a vector about a normal.  Normal must be a unit vector.  (reference type version)
	*\param V vector
	*\param N normal
	*\param vOut reflected vector
	*/
	static void reflectVector(Vector2 V, Vector2 N, Vector2 &vOut);

	/**
	* get a vector perpendicular to this vector.
	*\param vec vector
	*\return perpendicular vector
	*/
	static Vector2 getPerpendicular(Vector2 vec);
	/**
	* get a vector perpendicular to this vector (reference type).
	*\param vIn vector
	*\param vOut perpendicular vector
	*/
	static void getPerpendicular(Vector2 vIn, Vector2 &vOut);

	/**
	* make this vector perpendicular to itself
	*\param v vector
	*/
	static void makePerpendicular(Vector2 &v);

	/**
	* is rotating from A to B Counter-clockwise?
	*\param A vector
	*\param B vector
	*\return true = CCW or opposite (180 degrees), false = CW
	*/
	static bool isCCW(Vector2 A, Vector2 B);

	/**
	* turn a Vector2 into a Vector3 (sets Z component to zero)
	*\param vec input Vector2
	*\return result Vector3
	*/
	static Vector3 vec3FromVec2(Vector2 vec);
	/**
	* turn a Vector2 into a Vector3
	*\param vec input Vector2
	*\param Z Z component
	*\return result Vector3
	*/
	static Vector3 vec3FromVec2(Vector2 vec, float Z);

	/**
	* see if 2 line segments intersect. (line AB collides with line CD)
    *\param ptA first point on line AB
	*\param ptB second point on line AB
	*\param ptC first point on line CD
	*\param ptD second point on line CD
	*\param hitPt resulting point of intersection
	*\param Ua distance along AB to intersection [0,1]
	*\param Ub distance long CD to intersection [0,1]
	*\return true / false
	*/
	static bool lineIntersect(Vector2 ptA, Vector2 ptB, Vector2 ptC, Vector2 ptD, Vector2 &hitPt, float &Ua, float &Ub);
	/**
	* see if 2 line segments intersect. (line AB collides with line CD)
    *\param ptA first point on line AB
	*\param ptB second point on line AB
	*\param ptC first point on line CD
	*\param ptD second point on line CD
	*\param hitPt resulting point of intersection
	*\return true / false
	*/
	static bool lineIntersect(Vector2 ptA, Vector2 ptB, Vector2 ptC, Vector2 ptD, Vector2 &hitPt);

	/**
	* calculate a spring force, given position, velocity, spring constant, and damping factor.
	*\param posA position of point A on spring
    *\param velA velocity of point A on spring
    *\param posB position of point B on spring
    *\param velB velocity of point B on spring
    *\param springD rest distance of the springs
    *\param springK spring constant
    *\param damping coefficient for damping
    *\return spring force Vector
	*/
	static Vector2 calculateSpringForce(Vector2 posA, Vector2 velA, Vector2 posB, Vector2 velB, float springD, float springK, float damping);
	/**
	* calculate a spring force, given position, velocity, spring constant, and damping factor.
	*\param posA position of point A on spring
    *\param velA velocity of point A on spring
    *\param posB position of point B on spring
    *\param velB velocity of point B on spring
    *\param springD rest distance of the springs
    *\param springK spring constant
    *\param damping coefficient for damping
	*\param forceOut rsulting force Vector2
	*/
	static void calculateSpringForce(Vector2 posA, Vector2 velA, Vector2 posB, Vector2 velB, float springD, float springK, float damping, Vector2 &forceOut);

	/**
	* Helper fuction  - change from degree to radian
	*\param degrees degrees
	*\return radian value
	*/
	static float ToRadians(float degrees);

	/*
	static float mysinf(float val)
   {
	   float ret;

	   val *= 0.6366197f; // convert to deg/90

	   __asm__ volatile (
		  "mtv %1, S000\n"
		  "vsin.s S001, S000\n"
		  "mfv %0, S001\n"
		  : "=r"(ret) : "r"(val));

	   return ret;
   } 

	static float mycosf(float val)
   {
	   float ret;

	   val *= 0.6366197f; // convert to deg/90

	   __asm__ volatile (
		  "mtv %1, S000\n"
		  "vcos.s S001, S000\n"
		  "mfv %0, S001\n"
		  : "=r"(ret) : "r"(val));

	   return ret;
   } */
	static float mysinf(float rad)
    {
		float result;
		__asm__ volatile (
			"mtv     %1, S000\n"
			"vcst.s  S001, VFPU_2_PI\n"
			"vmul.s  S000, S000, S001\n"
			"vsin.s  S000, S000\n"
			"mfv     %0, S000\n"
			: "=r"(result) : "r"(rad));
		return result;
	}

	static float mycosf(float rad)
    {
	 float result;
		__asm__ volatile (
			"mtv     %1, S000\n"
			"vcst.s  S001, VFPU_2_PI\n"
			"vmul.s  S000, S000, S001\n"
			"vcos.s  S000, S000\n"
			"mfv     %0, S000\n"
			: "=r"(result) : "r"(rad));
		return result;
	}


};

#endif
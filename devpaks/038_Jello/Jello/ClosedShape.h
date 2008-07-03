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

#ifndef ClosedShape_H
#define ClosedShape_H

#include <vector>
#include "Vector2.h"

/**
* class that represents a single polygonal closed shape (can be concave)
*/
class ClosedShape
{
public:

	/**
	* Vertices that make up this collision geometry.  shape connects vertices in order, closing the last vertex to the first.
	*/
	std::vector<Vector2> mLocalVertices;

	/**
	* default constructor.
	*/
	ClosedShape();

	/**
	*	default destructor
	*/
	~ClosedShape();

	/**
	*	construct from an existing list of vertices.
	*/
	ClosedShape(std::vector<Vector2> verts);

	/**
	*	start adding vertices to this collision.  will erase any existing verts.
	*/
	void begin();

	/**
	*	add a vertex to this collision.
	*/
	int addVertex(Vector2 vert);

	/**
	*	finish adding vertices to this collision, and convert them into local space (be default).
	*/
	void finish(bool recenter);

	/**
	*	finish adding vertices to this collision, and convert them into local space (be default).
	*/
	void finish();

	/**
	*	access to the vertice list.
	*/
	std::vector<Vector2> Vertices();

	/**
	* Get a new list of vertices, transformed by the given position, angle, and scale.
	* transformation is applied in the following order:  scale -> rotation -> position.
	*/
	std::vector<Vector2> transformVertices(Vector2 worldPos, float angleInRadians, Vector2 localScale);

	/**
	* Get a new list of vertices, transformed by the given position, angle, and scale.
	* transformation is applied in the following order:  scale -> rotation -> position.
	*/
	void transformVertices(Vector2 worldPos, float angleInRadians, Vector2 localScale, Vector2 *outList);

};


#endif
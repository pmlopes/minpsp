#include "AABB.h"

AABB::~AABB()
{

}

AABB::AABB()
{
	Min = Max = Vector2::ZERO;
	Validity = AABB::Invalid;
}

AABB::AABB(Vector2 minPt, Vector2 maxPt)
{
	Min = minPt;
	Max = maxPt;
	Validity = AABB::Valid;
}

void AABB::clear()
{
	Min.X = Max.X = Min.Y = Max.Y = 0.0f;
	Validity = AABB::Invalid;
}

void AABB::expandToInclude(Vector2 pt)
{
	if (Validity == AABB::Valid)
	{
		if (pt.X < Min.X) { Min.X = pt.X; }
		else if (pt.X > Max.X) { Max.X = pt.X; }

		if (pt.Y < Min.Y) { Min.Y = pt.Y; }
		else if (pt.Y > Max.Y) { Max.Y = pt.Y; }
    }
    else
    {
		Min = Max = pt;
		Validity = AABB::Valid;
    }
}

bool AABB::contains(Vector2 pt)
{
	if (Validity == AABB::Invalid) { return false; }

	return ((pt.X >= Min.X) && (pt.X <= Max.X) && (pt.Y >= Min.Y) && (pt.Y <= Max.Y));
}

bool AABB::intersects( AABB *box)
{
	bool overlapX = ((Min.X <= box->Max.X) && (Max.X >= box->Min.X));
	bool overlapY = ((Min.Y <= box->Max.Y) && (Max.Y >= box->Min.Y));

	return (overlapX && overlapY);
}


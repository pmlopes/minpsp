#include "ClosedShape.h"
#include "VectorTools.h"

ClosedShape::ClosedShape()
{

}

ClosedShape::~ClosedShape()
{
	mLocalVertices.clear();
}

ClosedShape::ClosedShape(std::vector<Vector2> verts)
{
	mLocalVertices.clear();
	for(unsigned int i = 0; i < verts.size();i++)
	{
		mLocalVertices.push_back(verts[i]);
	}
}

void ClosedShape::begin()
{
	mLocalVertices.clear();
}

int ClosedShape::addVertex(Vector2 vert)
{
	mLocalVertices.push_back(vert);
	return mLocalVertices.size();
}

void ClosedShape::finish(bool recenter)
{
	if(recenter == true)
	{
		Vector2 center(0.0f,0.0f);

		int temp = mLocalVertices.size();

		for(int i=0;i< temp;i++)
		{
			center += mLocalVertices[i];
		}

		center /= temp;
		
		for(int i=0;i< temp;i++)
		{
			mLocalVertices[i] -= center;
		}
	}
}

void ClosedShape::finish()
{
	finish(true);
}

std::vector<Vector2> ClosedShape::Vertices()
{
	return mLocalVertices;
}

std::vector<Vector2> ClosedShape::transformVertices(Vector2 worldPos, float angleInRadians, Vector2 localScale)
{
	std::vector<Vector2> ret(mLocalVertices);

	Vector2 v;

	int temp = ret.size();

	for (int i = 0; i < temp; i++)
	{
		// rotate the point, and then translate.
		v.X = ret[i].X * localScale.X;
		v.Y = ret[i].Y * localScale.Y;

		VectorTools::rotateVector(v, angleInRadians, v);

		v.X += worldPos.X;
		v.Y += worldPos.Y;
		ret[i] = v;
	}

	return ret;
}

void ClosedShape::transformVertices(Vector2 worldPos, float angleInRadians, Vector2 localScale, Vector2 *outList)
{
	int temp = mLocalVertices.size();

	for (int i = 0; i < temp; i++)
    {
        // rotate the point, and then translate.
        Vector2 v;

        v.X = mLocalVertices[i].X * localScale.X;
        v.Y = mLocalVertices[i].Y * localScale.Y;
        
		VectorTools::rotateVector(v, angleInRadians,0);
        
		v.X += worldPos.X;
        v.Y += worldPos.Y;
        
		outList[i].X = v.X;
        outList[i].Y = v.Y;
    }
}
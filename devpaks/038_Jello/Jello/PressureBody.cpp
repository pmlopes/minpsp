#include "PressureBody.h"

PressureBody::~PressureBody()
{
	delete [] mNormalList;
	delete mEdgeLengthList;
}

PressureBody::PressureBody(ClosedShape *s, float massPerPoint, float gasPressure, float shapeSpringK, float shapeSpringDamp, float edgeSpringK, float edgeSpringDamp, Vector2 pos, float angleInRadians, Vector2 scale, bool kinematic): 
	SpringBody(s, massPerPoint, shapeSpringK, shapeSpringDamp, edgeSpringK, edgeSpringDamp, pos, angleInRadians, scale, kinematic)
{
    mGasAmount = gasPressure;
	mNormalList = new Vector2[mPointMassesC];
    mEdgeLengthList = new float[mPointMassesC];
	mCount = mPointMassesC;
	Type = 3;
}

float PressureBody::GasPressure()
{
    return mGasAmount;
}
void PressureBody::GasPressure(float gasPressure)
{
	mGasAmount = gasPressure;
}

float PressureBody::Volume()
{
   return mVolume;
}

void PressureBody::accumulateInternalForces()
{
	SpringBody::accumulateInternalForces();
	//accumulateInternalForce2();
	
	// internal forces based on pressure equations.  we need 2 loops to do this.  one to find the overall volume of the
    // body, and 1 to apply forces.  we will need the normals for the edges in both loops, so we will cache them and remember them.
    mVolume = 0.0f;

    for (int i = 0; i < mPointMassesC; i++)
    {
        int prev = (i > 0) ? i - 1 : mPointMassesC - 1;
        int next = (i < mPointMassesC - 1) ? i + 1 : 0;

        // currently we are talking about the edge from i --> j.
        // first calculate the volume of the body, and cache normals as we go.
        Vector2 edge1N;
		edge1N.X = mPointMasses[i]->Position.X - mPointMasses[prev]->Position.X;
        edge1N.Y = mPointMasses[i]->Position.Y - mPointMasses[prev]->Position.Y;
		VectorTools::makePerpendicular(edge1N);

        Vector2 edge2N;
        edge2N.X = mPointMasses[next]->Position.X - mPointMasses[i]->Position.X;
        edge2N.Y = mPointMasses[next]->Position.Y - mPointMasses[i]->Position.Y;
		VectorTools::makePerpendicular(edge2N);

        Vector2 norm;
        norm.X = edge1N.X + edge2N.X;
        norm.Y = edge1N.Y + edge2N.Y;

        float nL = mysqrtf(((norm.X * norm.X) + (norm.Y * norm.Y)));
        if (nL > 0.001f)
        {
            norm.X /= nL;
            norm.Y /= nL;
        }

        float edgeL = mysqrtf((edge2N.X * edge2N.X) + (edge2N.Y * edge2N.Y));

        // cache normal and edge length
        mNormalList[i] = norm;
        mEdgeLengthList[i] = edgeL;

        float xdist = fabs(mPointMasses[i]->Position.X - mPointMasses[next]->Position.X);

        float volumeProduct = xdist * fabs(norm.X) * edgeL;

        // add to volume
        mVolume += 0.5f * volumeProduct;
    }

    // now loop through, adding forces!
    float invVolume = 1.0f / mVolume;

    for (int i = 0; i < mPointMassesC; i++)
    {
        int j = (i < mPointMassesC - 1) ? i + 1 : 0;

        float pressureV = (invVolume * mEdgeLengthList[i] * mGasAmount);
        mPointMasses[i]->Force.X += mNormalList[i].X * pressureV;
        mPointMasses[i]->Force.Y += mNormalList[i].Y * pressureV;

        mPointMasses[j]->Force.X += mNormalList[j].X * pressureV;
        mPointMasses[j]->Force.Y += mNormalList[j].Y * pressureV;
    }

}

void PressureBody::accumulateExternalForces()
{
   // base.accumulateExternalForces();

    // gravity!
    for (int i = 0; i < mPointMassesC; i++)
		mPointMasses[i]->Force += Vector2(0, -9.8f * mPointMasses[i]->Mass);
}

void PressureBody::DrawMe()
{
	
	//AABB *aabb = getAABB();
	/*
    float srodekX = ((getAABB()->Max.X - getAABB()->Min.X)/2) + getAABB()->Min.X;
    float srodekY = ((getAABB()->Max.Y - getAABB()->Min.Y)/2) + getAABB()->Min.Y;

	Vector2 *shape = new Vector2[mPointMassesC+2];

    shape[0].X = srodekX;
	shape[0].Y = srodekY;

    for (unsigned int i = 0; i < mPointMassesC; i++)
    {
        shape[i+1] = ((PointMass*)mPointMasses.at(i))->Position;
    }

    shape[mPointMassesC + 1] = mPointMasses[0]->Position;

	Renderer::FillBlobShape(shape,(mPointMassesC+2),0,1,0);*/
	Renderer::RenderGlobalShapeLine(mPointMasses,0,0,0);

	//delete aabb;
	//delete [] shape;
}
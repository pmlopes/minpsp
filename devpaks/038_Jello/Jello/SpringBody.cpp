#include "SpringBody.h"

SpringBody::~SpringBody()
{
	delete [] mIndices;
	mSprings.clear();
	mIndexList.clear();
}


SpringBody::SpringBody(ClosedShape *shape, float massPerPoint, float edgeSpringK, float edgeSpringDamp, Vector2 pos, float angleinRadians, Vector2 scale, bool kinematic)
{
    mShapeMatchingOn = true;
    mEdgeSpringK = edgeSpringK;
    mEdgeSpringDamp = edgeSpringDamp;
    mShapeSpringK = 0.0f;
    mShapeSpringDamp = 0.0f;
	mShapeMatchingOn = false;

	dragPoint = -1;

	setShape(shape);

		for (int i = 0; i < mPointMassesC; i++)
		((PointMass*)mPointMasses[i])->Mass = massPerPoint;

	if(massPerPoint > 0)
		mIsStatic = false;
	else
		mIsStatic  = true;

	mKinematic = kinematic;

	setPositionAngle(pos, angleinRadians, scale);

	// build default springs.
    _buildDefaultSprings();

	Type = 2;
}

SpringBody::SpringBody(ClosedShape *shape, float massPerPoint, float shapeSpringK, float shapeSpringDamp, float edgeSpringK, float edgeSpringDamp, Vector2 pos, float angleinRadians, Vector2 scale, bool kinematic)
{
    //mSprings = new List<InternalSpring>();

    mShapeMatchingOn = true;
    mShapeSpringK = shapeSpringK;
    mShapeSpringDamp = shapeSpringDamp;
    mEdgeSpringK = edgeSpringK;
    mEdgeSpringDamp = edgeSpringDamp;

	dragPoint = -1;

	 setShape(shape);
	 for (int i = 0; i < mPointMassesC; i++)
		((PointMass*)mPointMasses[i])->Mass = massPerPoint;
	 
	if(massPerPoint > 0)
		mIsStatic = false;
	else
		mIsStatic  = true;

    mKinematic = kinematic;

	setPositionAngle(pos, angleinRadians, scale);

    // build default springs.
    _buildDefaultSprings();

	Type = 2;
}

void SpringBody::addInternalSpring(int pointA, int pointB, float springK, float damping)
{
    float dist = (mPointMasses[pointB]->Position - mPointMasses[pointA]->Position).Length();
    InternalSpring *s = new InternalSpring(pointA, pointB, dist, springK, damping);

    mSprings.push_back(s);
}

void SpringBody::_buildDefaultSprings()
{
	for (int i = 0; i < mPointMassesC; i++)
    {
        if (i < (mPointMassesC - 1))
            addInternalSpring(i, i + 1, mEdgeSpringK, mEdgeSpringDamp);
        else
            addInternalSpring(i, 0, mEdgeSpringK, mEdgeSpringDamp);
    }
}

void SpringBody::clearAllSprings()
{
    mSprings.clear();
    _buildDefaultSprings();
}

void SpringBody::setShapeMatching(bool onoff) { mShapeMatchingOn = onoff; }
void SpringBody::setShapeMatchingConstants(float springK, float damping) { mShapeSpringK = springK; mShapeSpringDamp = damping; }

void SpringBody::setEdgeSpringConstants(float edgeSpringK, float edgeSpringDamp)
{
    // we know that the first n springs in the list are the edge springs.
    for (int i = 0; i < mPointMassesC; i++)
    {
        mSprings[i]->springK = edgeSpringK;
        mSprings[i]->damping = edgeSpringDamp;
    }
}

void SpringBody::setSpringConstants(int springID, float springK, float springDamp)
{
    // index is for all internal springs, AFTER the default internal springs.
    int index = mPointMassesC + springID;
    mSprings[index]->springK = springK;
    mSprings[index]->damping = springDamp;
}

float SpringBody::getSpringK(int springID)
{
    int index = mPointMassesC + springID;
    return mSprings[index]->springK;
}

float SpringBody::getSpringDamping(int springID)
{
    int index = mPointMassesC + springID;
    return mSprings[index]->damping;
}

void SpringBody::accumulateInternalForces()
{
    Vector2 force;
	int mSpringsC = mSprings.size();
    for (int i = 0; i < mSpringsC; i++)
    {
        InternalSpring *s = mSprings[i];
		VectorTools::calculateSpringForce(mPointMasses[s->pointMassA]->Position, mPointMasses[s->pointMassA]->Velocity,
            mPointMasses[s->pointMassB]->Position, mPointMasses[s->pointMassB]->Velocity,
            s->springD, s->springK, s->damping,
            force);

        mPointMasses[s->pointMassA]->Force.X += force.X;
        mPointMasses[s->pointMassA]->Force.Y += force.Y;

        mPointMasses[s->pointMassB]->Force.X -= force.X;
        mPointMasses[s->pointMassB]->Force.Y -= force.Y;
    }

    // shape matching forces.
    if (mShapeMatchingOn)
    {
        mBaseShape->transformVertices( mDerivedPos, mDerivedAngle, mScale, mGlobalShape);
        for (int i = 0; i < mPointMassesC; i++)
        {
            if (mShapeSpringK > 0.0f)
            {
				force = VectorTools::calculateSpringForce(mPointMasses[i]->Position, mPointMasses[i]->Velocity,
                    mGlobalShape[i], mPointMasses[i]->Velocity, 0.0f, mShapeSpringK, mShapeSpringDamp);

                mPointMasses[i]->Force.X += force.X;
                mPointMasses[i]->Force.Y += force.Y;
            }
        }
    }
}

void SpringBody::addTriangle(int A, int B, int C)
{
	mIndexList.push_back(A);
    mIndexList.push_back(B);
    mIndexList.push_back(C);
}

void SpringBody::finalizeTriangles()
{
	mIndicesCount = mIndexList.size();
    mIndices = new int[mIndexList.size()];
    for (unsigned int i = 0; i < mIndexList.size(); i++)
        mIndices[i] = mIndexList[i];
}

void SpringBody::accumulateExternalForces()
{
   // base.accumulateExternalForces();

    // gravity!
    for (int i = 0; i < mPointMassesC; i++)
		mPointMasses[i]->Force += Vector2(0, -9.8f * ((PointMass*)mPointMasses.at(i))->Mass);

	if (dragPoint != -1)
		mPointMasses[dragPoint]->Force += dragForce;

    dragPoint = -1;
}

void SpringBody::setDragForce(Vector2 force, int pm)
{
	dragForce = force * 2;
	dragPoint = pm;
}

void SpringBody::DrawMe()
{
	//Renderer::FillSpringShape(mPointMasses, mIndices, mIndicesCount, 1,0,0);
	Renderer::RenderGlobalShapeLine(mPointMasses,0,0,0);

	//Renderer::RenderGlobalShapeLine( &mGlobalShape[0], mPointMassesC, 0, 0, 0 );
}
#include "Body.h"
#include "VectorTools.h"

Body::Body()
{
	mDerivedAngle = 0.0f;
	mDerivedOmega = 0.0f;
	mLastAngle = 0.0f;

	mDerivedVel = Vector2::ZERO;

    mAABB = new AABB();
    mBaseShape = NULL;
    mGlobalShape = NULL;
	mScale = Vector2::One;
    mIsStatic = false;
    mKinematic = false;

	mBitMaskX = new Bitmask();
	mBitMaskY = new Bitmask();

    mMaterial = 0;

	PI = 3.14159f;

	Type = 1;
}

Body::~Body()
{
	delete mBaseShape;
	delete [] mGlobalShape;
	delete mAABB;
	delete mBitMaskX;
	delete mBitMaskY;
	mPointMasses.clear();
}

Body::Body(ClosedShape *shape, float massPerPoint, Vector2 position, float angleInRadians, Vector2 scale, bool kinematic)
{
	mDerivedAngle = 0.0f;
	mDerivedOmega = 0.0f;
	mLastAngle = 0.0f;

	mDerivedVel = Vector2::ZERO;

    mAABB =  new AABB();
    mDerivedPos = position;
    mDerivedAngle = angleInRadians;
    mLastAngle = mDerivedAngle;
    mScale = scale;
    mMaterial = 0;

	mBitMaskX = new Bitmask();
	mBitMaskY = new Bitmask();

	PI = 3.14159f;
	
	if(massPerPoint > 0.0f)
		mIsStatic = false;
	else
		mIsStatic  = true;

    mKinematic = kinematic;

    setShape(shape);
    for (int i = 0; i < mPointMassesC; i++)
		((PointMass*)mPointMasses[i])->Mass = massPerPoint;

    updateAABB(0, true);
	Type = 1;
}

Body::Body(ClosedShape *shape, std::vector<float> pointMasses, Vector2 position, float angleInRadians, Vector2 scale, bool kinematic)
{
	mDerivedAngle = 0.0f;
	mDerivedOmega = 0.0f;
	mLastAngle = 0.0f;

	mDerivedVel = Vector2::ZERO;

    mAABB = new AABB();
    mDerivedPos = position;
    mDerivedAngle = angleInRadians;
    mLastAngle = mDerivedAngle;
    mScale = scale;
    mMaterial = 0;
    mIsStatic = false;
    mKinematic = kinematic;

	mBitMaskX = new Bitmask();
	mBitMaskY = new Bitmask();

	PI = 3.14159f;

    setShape(shape);
    for (int i = 0; i < mPointMassesC; i++)
        ((PointMass*)mPointMasses[i])->Mass = pointMasses[i];

    updateAABB(0, true);
	Type = 1;
}

void Body::setMassAll(float mass)
{
    for (unsigned int i = 0; i < mPointMasses.size(); i++)
       mPointMasses[i]->Mass = mass;

    if (mass == 0.0f) { mIsStatic = true; }
}

void Body::setMassIndividual(unsigned int index, float mass)
{
    if (index < mPointMasses.size())
        mPointMasses[index]->Mass = mass;
}

void Body::setMassFromList(std::vector<float> masses)
{
    if (masses.size() == mPointMasses.size())
    {
        for (unsigned int i = 0; i < mPointMasses.size(); i++)
			mPointMasses[i]->Mass = masses[i];
    }
}

int Body::Material()
{
   return mMaterial;
}

void Body::setPositionAngle(Vector2 pos, float angleInRadians, Vector2 scale)
{
    mBaseShape->transformVertices(pos, angleInRadians, scale, mGlobalShape);
    for (int i = 0; i < mPointMassesC; i++)
        mPointMasses[i]->Position = mGlobalShape[i];

    mDerivedPos = pos;
    mDerivedAngle = angleInRadians;
}

void Body::setShape(ClosedShape *shape)
{
    mBaseShape = shape;

	if (mBaseShape->Vertices().size() != mPointMasses.size())
    {
		mPointMasses.clear();

		mGlobalShape = new Vector2[mBaseShape->Vertices().size()];
		mShapeCount = mBaseShape->Vertices().size();
		//marcin
		mShapeCount+=1;

        mBaseShape->transformVertices(mDerivedPos, mDerivedAngle, mScale, mGlobalShape);

        for (unsigned int i = 0; i < mBaseShape->Vertices().size(); i++)
		{
			mPointMasses.push_back(new PointMass(0.0f, mGlobalShape[i]));
		}

		mPointMassesC = mPointMasses.size();

		//delete [] mGlobalShape;
    }
}

void Body::updateAABB(float elapsed, bool forceUpdate)
{
    if ((!mIsStatic) || (forceUpdate))
    {
        mAABB->clear();
		//int temp = mPointMasses.size();
        for (int i = 0; i < mPointMassesC; i++)
        {
            mAABB->expandToInclude(mPointMasses[i]->Position);

            // expanding for velocity only makes sense for dynamic objects.
            if (!mIsStatic)
            {
                mPointMasses[i]->Position.X += (((PointMass*)mPointMasses.at(i))->Velocity.X * elapsed);
                mPointMasses[i]->Position.Y += (((PointMass*)mPointMasses.at(i))->Velocity.Y * elapsed);
                mAABB->expandToInclude(mPointMasses[i]->Position);
            }
        }
    }
}

void Body::setKinematicPosition(Vector2 pos)
{
    mDerivedPos = pos;
}

void Body::setKinematicAngle(float angleInRadians)
{
    mDerivedAngle = angleInRadians;
}

void Body::setKinematicScale(Vector2 &scale)
{
    mScale = scale;
}

void Body::derivePositionAndAngle(float elaspsed)
{
    // no need it this is a static body, or kinematically controlled.
    if (mIsStatic || mKinematic)
        return;

    // find the geometric center.
    Vector2 center;
    Vector2 vel;

	//int mPointMassesC = mPointMasses.size();

    for (int i = 0; i < mPointMassesC; i++)
    {
        center.X += mPointMasses[i]->Position.X;
        center.Y += mPointMasses[i]->Position.Y;

        vel.X += mPointMasses[i]->Velocity.X;
        vel.Y += mPointMasses[i]->Velocity.Y;
    }

	float temp = 1.0f / mPointMassesC;

    center.X *= temp;
    center.Y *= temp;

    vel.X *= temp;
    vel.Y *= temp;

    mDerivedPos = center;
    mDerivedVel = vel;

    // find the average angle of all of the masses.
    float angle = 0;
    int originalSign = 1;
    float originalAngle = 0.0f;
    for (int i = 0; i < mPointMassesC; i++)
    {
        Vector2 baseNorm;
		baseNorm.X = mBaseShape->Vertices()[i].X;
        baseNorm.Y = mBaseShape->Vertices()[i].Y;
		Vector2::Normalize(baseNorm, baseNorm);

        Vector2 curNorm;
        curNorm.X = mPointMasses[i]->Position.X - mDerivedPos.X;
        curNorm.Y = mPointMasses[i]->Position.Y - mDerivedPos.Y;
		Vector2::Normalize(curNorm, curNorm);

        float dot;
		Vector2::Dot(baseNorm, curNorm, dot);
        if (dot > 1.0f) { dot = 1.0f; }
        if (dot < -1.0f) { dot = -1.0f; }

        float thisAngle = myacosf(dot);
		if (!VectorTools::isCCW(baseNorm, curNorm)) { thisAngle = -thisAngle; }

        if (i == 0)
        {
            originalSign = (thisAngle >= 0.0f) ? 1 : -1;
            originalAngle = thisAngle;
        }
        else
        {
            float diff = (thisAngle - originalAngle);
            int thisSign = (thisAngle >= 0.0f) ? 1 : -1;

			if ((fabs(diff) > PI) && (thisSign != originalSign))
            {
                thisAngle = (thisSign == -1) ? (PI + (PI + thisAngle)) : ((PI - thisAngle) - PI);
            }
        }

        angle += thisAngle;
    }

    angle /= (float)mPointMassesC;
    mDerivedAngle = angle;

    // now calculate the derived Omega, based on change in angle over time.
    float angleChange = (mDerivedAngle - mLastAngle);
    if (fabs(angleChange) >= PI)
    {
        if (angleChange < 0.0f)
            angleChange = angleChange + (PI * 2);
        else
            angleChange = angleChange - (PI * 2);
    }

    mDerivedOmega = angleChange / elaspsed;

    mLastAngle = mDerivedAngle;
}

Vector2 Body::DerivedPosition()
{
   return mDerivedPos;
}

float Body::DerivedAngle()
{
   return mDerivedAngle;
}

Vector2 Body::DerivedVelocity()
{
   return mDerivedVel;
}

float Body::DerivedOmega()
{
     return mDerivedOmega; 
}

void  Body::integrate(float elapsed)
{
    if (mIsStatic) { return; }

    for (int i = 0; i < mPointMassesC; i++)
        mPointMasses[i]->integrateForce(elapsed);
}

void  Body::dampenVelocity(float damp)
{
    if (mIsStatic) { return; }

    for (int i = 0; i < mPointMassesC; i++)
    {
        mPointMasses[i]->Velocity.X *= damp;
        mPointMasses[i]->Velocity.Y *= damp;
    }
}

AABB *Body::getAABB()
{
    return mAABB;
}

bool Body::contains(Vector2 pt)
{
    // basic idea: draw a line from the point to a point known to be outside the body.  count the number of
    // lines in the polygon it intersects.  if that number is odd, we are inside.  if it's even, we are outside.
    // in this implementation we will always use a line that moves off in the positive X direction from the point
    // to simplify things.
    Vector2 endPt;
    endPt.X = mAABB->Max.X + 0.1f;
    endPt.Y = pt.Y;

    // line we are testing against goes from pt -> endPt.
    bool inside = false;
    Vector2 edgeSt = mPointMasses[0]->Position;
    Vector2 edgeEnd;
    //int c = mPointMasses.size();
    for (int i = 0; i < mPointMassesC; i++)
    {
        // the current edge is defined as the line from edgeSt -> edgeEnd.
        if (i < (mPointMassesC - 1))
            edgeEnd = mPointMasses[i + 1]->Position;
        else
            edgeEnd = mPointMasses[0]->Position;

        // perform check now...
        if (((edgeSt.Y <= pt.Y) && (edgeEnd.Y > pt.Y)) || ((edgeSt.Y > pt.Y) && (edgeEnd.Y <= pt.Y)))
        {
            // this line crosses the test line at some point... does it do so within our test range?
            float slope = (edgeEnd.X - edgeSt.X) / (edgeEnd.Y - edgeSt.Y);
            float hitX = edgeSt.X + ((pt.Y - edgeSt.Y) * slope);

            if ((hitX >= pt.X) && (hitX <= endPt.X))
                inside = !inside;
        }
        edgeSt = edgeEnd;
    }

    return inside;
}

float Body::getClosestPoint(Vector2 pt, Vector2 &hitPt, Vector2 &normal, int &pointA, int &pointB, float &edgeD)
{
	hitPt = Vector2::ZERO;
    pointA = -1;
    pointB = -1;
    edgeD = 0.0f;
	normal = Vector2::ZERO;

    float closestD = 1000.0f;

    for (int i = 0; i < mPointMassesC; i++)
    {
        Vector2 tempHit;
        Vector2 tempNorm;
        float tempEdgeD;

        float dist = getClosestPointOnEdge(pt, i, tempHit, tempNorm, tempEdgeD);
        if (dist < closestD)
        {
            closestD = dist;
            pointA = i;
            if (i < (mPointMassesC - 1))
                pointB = i + 1;
            else
                pointB = 0;
            edgeD = tempEdgeD;
            normal = tempNorm;
            hitPt = tempHit;
        }
    }


    // return.
    return closestD;
}

float Body::getClosestPointOnEdge(Vector2 pt,int edgeNum,  Vector2 &hitPt,  Vector2 &normal,  float &edgeD)
{
    hitPt =  Vector2();
    hitPt.X = 0.0f;
    hitPt.Y = 0.0f;

    normal =  Vector2();
    normal.X = 0.0f;
    normal.Y = 0.0f;

    edgeD = 0.0f;
    float dist = 0.0f;

    Vector2 ptA = mPointMasses[edgeNum]->Position;
    Vector2 ptB;

    if (edgeNum < (mPointMassesC - 1))
        ptB = mPointMasses[edgeNum + 1]->Position;
    else
        ptB = mPointMasses[0]->Position;

    Vector2 toP;
    toP.X = pt.X - ptA.X;
    toP.Y = pt.Y - ptA.Y;

    Vector2 E;
    E.X = ptB.X - ptA.X;
    E.Y = ptB.Y - ptA.Y;

    // get the length of the edge, and use that to normalize the vector.
    float edgeLength = mysqrtf(((E.X * E.X) + (E.Y * E.Y)));
    if (edgeLength > 0.00001f)
    {
        E.X /= edgeLength;
        E.Y /= edgeLength;
    }

    // normal
    Vector2 n;
	VectorTools::getPerpendicular(E, n);

    // calculate the distance!
    float x;
	Vector2::Dot( toP,  E,  x);
    if (x <= 0.0f)
    {
        // x is outside the line segment, distance is from pt to ptA.
        //dist = (pt - ptA).Length();
		Vector2::Distance(pt, ptA, dist);
        hitPt = ptA;
        edgeD = 0.0f;
        normal = n;
    }
    else if (x >= edgeLength)
    {
        // x is outside of the line segment, distance is from pt to ptB.
        //dist = (pt - ptB).Length();
		Vector2::Distance(pt, ptB, dist);
        hitPt = ptB;
        edgeD = 1.0f;
        normal = n;
    }
    else
    {
        // point lies somewhere on the line segment.
        Vector3 toP3;
        toP3.X = toP.X;
        toP3.Y = toP.Y;

        Vector3 E3;
        E3.X = E.X;
        E3.Y = E.Y;

        //dist = Math.Abs(Vector3.Cross(toP3, E3).Z);
		Vector3::Cross( toP3,  E3,  E3);
        dist = fabs(E3.Z);
        hitPt.X = ptA.X + (E.X * x);
        hitPt.Y = ptA.Y + (E.Y * x);
        edgeD = x / edgeLength;
        normal = n;
    }

    return dist;
}

float Body::getClosestPointOnEdgeSquared(Vector2 pt,int edgeNum, Vector2 &hitPt, Vector2 &normal, float &edgeD)
{
    hitPt = Vector2();
    hitPt.X = 0.0f;
    hitPt.Y = 0.0f;

    normal =  Vector2();
    normal.X = 0.0f;
    normal.Y = 0.0f;

    edgeD = 0.0f;
    float dist = 0.0f;

    Vector2 ptA = mPointMasses[edgeNum]->Position;
    Vector2 ptB;

    if (edgeNum < (mPointMassesC - 1))
        ptB = mPointMasses[edgeNum + 1]->Position;
    else
        ptB = mPointMasses[0]->Position;

    Vector2 toP;
    toP.X = pt.X - ptA.X;
    toP.Y = pt.Y - ptA.Y;

    Vector2 E;
    E.X = ptB.X - ptA.X;
    E.Y = ptB.Y - ptA.Y;

    // get the length of the edge, and use that to normalize the vector.
    float edgeLength = mysqrtf(((E.X * E.X) + (E.Y * E.Y)));
    if (edgeLength > 0.00001f)
    {
        E.X /= edgeLength;
        E.Y /= edgeLength;
    }

    // normal
    Vector2 n;
	VectorTools::getPerpendicular( E,  n);

    // calculate the distance!
    float x;
	Vector2::Dot(toP, E, x);
    if (x <= 0.0f)
    {
        // x is outside the line segment, distance is from pt to ptA.
        //dist = (pt - ptA).Length();
		Vector2::DistanceSquared(pt, ptA, dist);
        hitPt = ptA;
        edgeD = 0.0f;
        normal = n;
    }
    else if (x >= edgeLength)
    {
        // x is outside of the line segment, distance is from pt to ptB.
        //dist = (pt - ptB).Length();
		Vector2::DistanceSquared( pt, ptB, dist);
        hitPt = ptB;
        edgeD = 1.0f;
        normal = n;
    }
    else
    {
        // point lies somewhere on the line segment.
        Vector3 toP3;
        toP3.X = toP.X;
        toP3.Y = toP.Y;

        Vector3 E3;
        E3.X = E.X;
        E3.Y = E.Y;

        //dist = Math.Abs(Vector3.Cross(toP3, E3).Z);
		Vector3::Cross(toP3, E3,  E3);
        dist = fabs(E3.Z * E3.Z);
        hitPt.X = ptA.X + (E.X * x);
        hitPt.Y = ptA.Y + (E.Y * x);
        edgeD = x / edgeLength;
        normal = n;
    }

    return dist;
}

int Body::getClosestPointMass(Vector2 pos, float &dist)
{
    float closestSQD = 100000.0f;
    int closest = -1;

    for (int i = 0; i < mPointMassesC; i++)
    {
        float thisD = (pos - mPointMasses[i]->Position).LengthSquared();
        if (thisD < closestSQD)
        {
            closestSQD = thisD;
            closest = i;
        }
    }

    dist = mysqrtf(closestSQD);
    return closest;
}

int Body::PointMassCount()
{
    return mPointMassesC;
}

PointMass *Body::getPointMass(int index)
{
    return mPointMasses[index];
}

void Body::addGlobalForce(Vector2 pt, Vector2 force)
{
    Vector2 R = (mDerivedPos - pt);

	float torqueF = Vector3::Cross(VectorTools::vec3FromVec2(R), VectorTools::vec3FromVec2(force)).Z;

    for (int i = 0; i < mPointMassesC; i++)
    {
        Vector2 toPt = mPointMasses[i]->Position - mDerivedPos;
		Vector2 torque = VectorTools::rotateVector(toPt, -(PI / 2));

        mPointMasses[i]->Force += torque * torqueF;

        mPointMasses[i]->Force += force;
    }
}

bool Body::IsStatic()
{
    return mIsStatic;
}

bool Body::IsKinematic()
{
   return mKinematic;
}

 void Body::DrawMe()
{
	Renderer::RenderGlobalShapeLine(mPointMasses,0,0,0);
}

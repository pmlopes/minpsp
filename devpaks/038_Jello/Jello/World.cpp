#include "World.h"

int World::MaterialCount()
{
    return mMaterialCount;
}

float World::VelocityDamping()
{
    return mDamping;
}


World::World()
{
    mMaterialCount = 1;

	mDefaultMatPair.Friction = 0.3f;
    mDefaultMatPair.Elasticity = 0.8f;
    mDefaultMatPair.Collide = true;

    mMaterialPairs[0][0] = mDefaultMatPair;

    Vector2 min1(-20.0f, -20.0f);
    Vector2 max1(20.0f, 20.0f);
    setWorldLimits(min1, max1);

    mPenetrationThreshold = 0.3f;
	mDamping = 0.999f;
}

void World::setWorldLimits(Vector2 min, Vector2 max)
{
    mWorldLimits = new AABB(min, max);
    mWorldSize = max - min;
    mWorldGridStep = mWorldSize / 32.0f;
}

int World::addMaterial()
{
	MaterialPair old[1000][1000];
    mMaterialCount++;

    // replace old data.
    for (int i = 0; i < mMaterialCount; i++)
    {
        for (int j = 0; j < mMaterialCount; j++)
        {
            if ((i < (mMaterialCount - 1)) && (j < (mMaterialCount - 1)))
                mMaterialPairs[i][j] = old[i][j];
            else
                mMaterialPairs[i][j] = mDefaultMatPair;
        }
    }

    return mMaterialCount - 1;
}

void World::setMaterialPairCollide(int a, int b, bool collide)
{
    if ((a >= 0) && (a < mMaterialCount) && (b >= 0) && (b < mMaterialCount))
    {
        mMaterialPairs[a][b].Collide = collide;
        mMaterialPairs[b][a].Collide = collide;
    }
}

void World::setMaterialPairData(int a, int b, float friction, float elasticity)
{
    if ((a >= 0) && (a < mMaterialCount) && (b >= 0) && (b < mMaterialCount))
    {
        mMaterialPairs[a][b].Friction = friction;
        mMaterialPairs[a][b].Elasticity = elasticity;

        mMaterialPairs[b][a].Friction = friction;
        mMaterialPairs[b][a].Elasticity = elasticity;
    }
}


void World::setMaterialPairFilterCallback(int a, int b, CollisionFilter filter)
{
    if ((a >= 0) && (a < mMaterialCount) && (b >= 0) && (b < mMaterialCount))
    {
        mMaterialPairs[a][b].collisionFilter = filter;

        mMaterialPairs[b][a].collisionFilter = filter;
    }
}

void World::addBody(Body *b)
{
	bool found = false;
	for(unsigned int i = 0; i< mBodies.size();i++)
	{
		if(b == mBodies[i])
			found = true;
	}
	
	//add body or not
	if(found == false)
		mBodies.push_back(b);
}

void World::removeBody(Body *b)
{
	bool found = false;
	int index;

	for(unsigned int i = 0; i< mBodies.size();i++)
	{
		if(b == mBodies[i])
		{
			found = true;
			index = i;
		}
	}

	//if found then remove
	if(found == true)
	{
		mBodies.erase(mBodies.begin() + (index - 1)); 
	}
}

Body *World::getBody(unsigned int index)
{
    if (index < mBodies.size())
        return mBodies[index];

    return NULL;
}

void World::getClosestPointMass(Vector2 pt, int &bodyID, int &pmID)
{
    bodyID = -1;
    pmID = -1;

    float closestD = 1000.0;
    for (unsigned int i = 0; i < mBodies.size(); i++)
    {
        float dist = 0;
        int pm = mBodies[i]->getClosestPointMass(pt, dist);
        if (dist < closestD)
        {
            closestD = dist;
            bodyID = i;
            pmID = pm;
        }
    }
}

Body *World::getBodyContaining(Vector2 &pt)
{
    for (unsigned int i = 0; i < mBodies.size(); i++)
    {
        if (mBodies[i]->contains(pt))
            return mBodies[i];
    }
	return NULL;
}

void World::update(float elapsed)
{
    mPenetrationCount = 0;

	float mBodiesC = mBodies.size();

    
    for (int i = 0; i < mBodiesC; i++)
    {
		// first, accumulate all forces acting on PointMasses.
		mBodies[i]->derivePositionAndAngle(elapsed);
        mBodies[i]->accumulateExternalForces();
		mBodies[i]->accumulateInternalForces();

		// now integrate.
		mBodies[i]->integrate(elapsed);

		// update all bounding boxes, and then bitmasks.
		mBodies[i]->updateAABB(elapsed, false);
        updateBodyBitmask(mBodies[i]);


    }

    // now check for collision.
    // inter-body collision!
    for (int i = 0; i < mBodiesC; i++)
    {
        for (int j = i + 1; j < mBodiesC; j++)
        {
            // early out - these bodies materials are set NOT to collide
           if (!mMaterialPairs[mBodies[i]->Material()][mBodies[j]->Material()].Collide == true)
                continue;

            // another early-out - both bodies are static.
            if (mBodies[i]->IsStatic() && mBodies[j]->IsStatic())
                continue;

            // grid-based early out.
           if (((mBodies[i]->mBitMaskX->mask & mBodies[j]->mBitMaskX->mask) == 0) &&
                ((mBodies[i]->mBitMaskY->mask & mBodies[j]->mBitMaskY->mask) == 0))
                continue;

            // early out
           if (!mBodies[i]->getAABB()->intersects(mBodies[j]->getAABB()))
                continue;

            // okay, the AABB's of these 2 are intersecting.  now check for collision of A against B.
            bodyCollide(mBodies[i], mBodies[j], mCollisionList);

            // and the opposite case, B colliding with A
			bodyCollide(mBodies[j], mBodies[i], mCollisionList);
        }
    }

    // now handle all collisions found during the update at once.
	if(mBodiesC > 0)
		_handleCollisions();

    // now dampen velocities.
    for (int i = 0; i < mBodiesC; i++)
       mBodies[i]->dampenVelocity(mDamping);
}

void World::updateBodyBitmask(Body *body)
{
    //AABB *box =  body->getAABB();

    int minX = (int)floor(( body->getAABB()->Min.X - mWorldLimits->Min.X) / mWorldGridStep.X);
    int maxX = (int)floor(( body->getAABB()->Max.X - mWorldLimits->Min.X) / mWorldGridStep.X);

    if (minX < 0) { minX = 0; } else if (minX > 32) { minX = 32; }
    if (maxX < 0) { maxX = 0; } else if (maxX > 32) { maxX = 32; }

    int minY = (int)floor(( body->getAABB()->Min.Y - mWorldLimits->Min.Y) / mWorldGridStep.Y);
    int maxY = (int)floor(( body->getAABB()->Max.Y - mWorldLimits->Min.Y) / mWorldGridStep.Y);

    if (minY < 0) { minY = 0; } else if (minY > 32) { minY = 32; }
    if (maxY < 0) { maxY = 0; } else if (maxY > 32) { maxY = 32; }

    body->mBitMaskX->clear();
    for (int i = minX; i <= maxX; i++)
        body->mBitMaskX->setOn(i);

    body->mBitMaskY->clear();
    for (int i = minY; i <= maxY; i++)
        body->mBitMaskY->setOn(i);

    //Console.WriteLine("Body bitmask: minX{0} maxX{1} minY{2} maxY{3}", minX, maxX, minY, minY, maxY);
}

void World::bodyCollide(Body *bA, Body *bB, std::vector<BodyCollisionInfo> &infoList)
{
    int bApmCount = bA->PointMassCount();
    int bBpmCount = bB->PointMassCount();

    //AABB *boxB = bB->getAABB();

    // check all PointMasses on bodyA for collision against bodyB.  if there is a collision, return detailed info.
    BodyCollisionInfo infoAway;
    BodyCollisionInfo infoSame;
    for (int i = 0; i < bApmCount; i++)
    {
        Vector2 pt = bA->getPointMass(i)->Position;

        // early out - if this point is outside the bounding box for bodyB, skip it!
        if (!bB->getAABB()->contains(pt))
            continue;

        // early out - if this point is not inside bodyB, skip it!
        if (!bB->contains(pt))
            continue;

        int prevPt = (i > 0) ? i - 1 : bApmCount - 1;
        int nextPt = (i < bApmCount - 1) ? i + 1 : 0;

        Vector2 prev = bA->getPointMass(prevPt)->Position;
        Vector2 next = bA->getPointMass(nextPt)->Position;

        // now get the normal for this point. (NOT A UNIT VECTOR)
        Vector2 fromPrev;
        fromPrev.X = pt.X - prev.X;
        fromPrev.Y = pt.Y - prev.Y;

        Vector2 toNext;
        toNext.X = next.X - pt.X;
        toNext.Y = next.Y - pt.Y;

        Vector2 ptNorm;
        ptNorm.X = fromPrev.X + toNext.X;
        ptNorm.Y = fromPrev.Y + toNext.Y;
		VectorTools::makePerpendicular( ptNorm);

        // this point is inside the other body.  now check if the edges on either side intersect with and edges on bodyB.          
        float closestAway = 100000.0f;
        float closestSame = 100000.0f;

        infoAway.Clear();
        infoAway.bodyA = bA;
        infoAway.bodyApm = i;
        infoAway.bodyB = bB;

        infoSame.Clear();
        infoSame.bodyA = bA;
        infoSame.bodyApm = i;
        infoSame.bodyB = bB;

        bool found = false;

        int b1 = 0;
        int b2 = 1;
        for (int j = 0; j < bBpmCount; j++)
        {
            Vector2 hitPt;
            Vector2 norm;
            float edgeD;

            b1 = j;

            if (j < bBpmCount - 1)
                b2 = j + 1;
            else
                b2 = 0;

            Vector2 b2P = bB->getPointMass(b2)->Position;
            Vector2 b1P = bB->getPointMass(b1)->Position;
            Vector2 edgeNorm;
            edgeNorm.X = b2P.X - b1P.X;
            edgeNorm.Y = b2P.Y - b1P.Y;
			VectorTools::makePerpendicular( edgeNorm);

            // test against this edge.
            float dist = bB->getClosestPointOnEdgeSquared(pt, j, hitPt, norm, edgeD);

            // only perform the check if the normal for this edge is facing AWAY from the point normal.
            float dot;
			Vector2::Dot(ptNorm, edgeNorm, dot);
            if (dot <= 0)
            {
                if (dist < closestAway)
                {
                    closestAway = dist;
                    infoAway.bodyBpmA = b1;
                    infoAway.bodyBpmB = b2;
                    infoAway.edgeD = edgeD;
                    infoAway.hitPt = hitPt;
                    infoAway.normal = norm;
                    infoAway.penetration = dist;
                    found = true;
                }
            }
            else
            {
                if (dist < closestSame)
                {
                    closestSame = dist;
                    infoSame.bodyBpmA = b1;
                    infoSame.bodyBpmB = b2;
                    infoSame.edgeD = edgeD;
                    infoSame.hitPt = hitPt;
                    infoSame.normal = norm;
                    infoSame.penetration = dist;
                }
            }
        }

        // we've checked all edges on BodyB.  add the collision info to the stack.
        if ((found) && (closestAway > mPenetrationThreshold) && (closestSame < closestAway))
        {
            infoSame.penetration = mysqrtf(infoSame.penetration);
            infoList.push_back(infoSame);
        }
        else
        {
            infoAway.penetration = mysqrtf(infoAway.penetration);
            infoList.push_back(infoAway);
        }
    }
}

void World::_handleCollisions()
{
    // handle all collisions!
    for (unsigned int i = 0; i < mCollisionList.size(); i++)
    {
        // velocity changes as a result of collision.
        Vector2 bVel;
        bVel.X = (mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmA)->Velocity.X + mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmB)->Velocity.X) * 0.5f;
        bVel.Y = (mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmA)->Velocity.Y + mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmB)->Velocity.Y) * 0.5f;

        Vector2 relVel;
        relVel.X = mCollisionList[i].bodyA->getPointMass(mCollisionList[i].bodyApm)->Velocity.X - bVel.X;
        relVel.Y = mCollisionList[i].bodyA->getPointMass(mCollisionList[i].bodyApm)->Velocity.Y - bVel.Y;

        float relDot;
		Vector2::Dot( relVel,  mCollisionList[i].normal,  relDot);

        // collision filter!
		if (!mMaterialPairs[mCollisionList[i].bodyA->Material()][mCollisionList[i].bodyB->Material()].collisionFilter.collisionFilter(mCollisionList[i].bodyA, mCollisionList[i].bodyApm, mCollisionList[i].bodyB, mCollisionList[i].bodyBpmA, mCollisionList[i].bodyBpmB, mCollisionList[i].hitPt, relDot))
            continue;

        if (mCollisionList[i].penetration > mPenetrationThreshold)
        {
            //Console.WriteLine("penetration above Penetration Threshold!!  penetration={0}  threshold={1} difference={2}",
            //    info.penetration, mPenetrationThreshold, info.penetration-mPenetrationThreshold);

            mPenetrationCount++;
            continue;
        }

        float b1inf = 1.0f - mCollisionList[i].edgeD;
        float b2inf = mCollisionList[i].edgeD;

        float b2MassSum = (((mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmA)->Mass == 0)) || ((mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmB)->Mass == 0))) ? 0 : (mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmA)->Mass + mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmB)->Mass);

        float massSum = mCollisionList[i].bodyA->getPointMass(mCollisionList[i].bodyApm)->Mass + b2MassSum;

        float Amove;
        float Bmove;
        if (mCollisionList[i].bodyA->getPointMass(mCollisionList[i].bodyApm)->Mass == 0)
        {
            Amove = 0;
            Bmove = (mCollisionList[i].penetration) + 0.001f;
        }
        else if (b2MassSum == 0)
        {
            Amove = (mCollisionList[i].penetration) + 0.001f;
            Bmove = 0;
        }
        else
        {
            Amove = (mCollisionList[i].penetration * (b2MassSum / massSum));
            Bmove = (mCollisionList[i].penetration * (mCollisionList[i].bodyA->getPointMass(mCollisionList[i].bodyApm)->Mass / massSum));
        }

        float B1move = Bmove * b1inf;
        float B2move = Bmove * b2inf;

        float AinvMass = (mCollisionList[i].bodyA->getPointMass(mCollisionList[i].bodyApm)->Mass == 0) ? 0 : 1 / mCollisionList[i].bodyA->getPointMass(mCollisionList[i].bodyApm)->Mass;
        float BinvMass = (b2MassSum == 0) ? 0 : 1 / b2MassSum;

        float jDenom = AinvMass + BinvMass;
        Vector2 numV;
        float elas = 1 + mMaterialPairs[mCollisionList[i].bodyA->Material()][mCollisionList[i].bodyB->Material()].Elasticity;
        numV.X = relVel.X * elas;
        numV.Y = relVel.Y * elas;

        float jNumerator;
		Vector2::Dot(numV, mCollisionList[i].normal, jNumerator);
        jNumerator = -jNumerator;

        float j = jNumerator / jDenom;

        if (mCollisionList[i].bodyA->getPointMass(mCollisionList[i].bodyApm)->Mass != 0)
        {
            mCollisionList[i].bodyA->getPointMass(mCollisionList[i].bodyApm)->Position.X += mCollisionList[i].normal.X * Amove;
            mCollisionList[i].bodyA->getPointMass(mCollisionList[i].bodyApm)->Position.Y += mCollisionList[i].normal.Y * Amove;
        }

        if ((mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmA)->Mass != 0))
        {
            mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmA)->Position.X -= mCollisionList[i].normal.X * B1move;
            mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmA)->Position.Y -= mCollisionList[i].normal.Y * B1move;
        }

        if ((mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmB)->Mass != 0))
        {
            mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmB)->Position.X -= mCollisionList[i].normal.X * B2move;
            mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmB)->Position.Y -= mCollisionList[i].normal.Y * B2move;
        }

        Vector2 tangent;
		VectorTools::getPerpendicular(mCollisionList[i].normal, tangent);
        float friction = mMaterialPairs[mCollisionList[i].bodyA->Material()][mCollisionList[i].bodyB->Material()].Friction;
        float fNumerator;
		Vector2::Dot(relVel, tangent, fNumerator);
        fNumerator *= friction;
        float f = fNumerator / jDenom;

        // adjust velocity if relative velocity is moving toward each other.
        if (relDot < 0)
        {
            if (mCollisionList[i].bodyA->getPointMass(mCollisionList[i].bodyApm)->Mass != 0)
            {
                float one = j / mCollisionList[i].bodyA->getPointMass(mCollisionList[i].bodyApm)->Mass;
                float two = f / mCollisionList[i].bodyA->getPointMass(mCollisionList[i].bodyApm)->Mass;
                mCollisionList[i].bodyA->getPointMass(mCollisionList[i].bodyApm)->Velocity.X += (mCollisionList[i].normal.X * one) - (tangent.X * two);
                mCollisionList[i].bodyA->getPointMass(mCollisionList[i].bodyApm)->Velocity.Y += (mCollisionList[i].normal.Y * one) - (tangent.Y * two);
            }

            if (b2MassSum  != 0)
            {
                float one = (j / b2MassSum) * b1inf;
                float two = (f / b2MassSum) * b1inf;
                mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmA)->Velocity.X -= (mCollisionList[i].normal.X * one) - (tangent.X * two);
                mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmA)->Velocity.Y -= (mCollisionList[i].normal.Y * one) - (tangent.Y * two);
            }

            if (b2MassSum  != 0)
            {
                float one = (j / b2MassSum) * b2inf;
                float two = (f / b2MassSum) * b2inf;
                mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmB)->Velocity.X -= (mCollisionList[i].normal.X * one) - (tangent.X * two);
                mCollisionList[i].bodyB->getPointMass(mCollisionList[i].bodyBpmB)->Velocity.Y -= (mCollisionList[i].normal.Y * one) - (tangent.Y * two);
            }
        }
    }
	mCollisionList.clear();
}

float World::PenetrationThreshold()
{
  return mPenetrationThreshold;
}

void World::PenetrationTreshold(float treshold)
{
	mPenetrationThreshold = treshold;
}

int World::PenetrationCount()
{
  return mPenetrationCount;
}
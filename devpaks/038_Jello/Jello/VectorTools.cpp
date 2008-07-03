#include "VectorTools.h"

VectorTools::~VectorTools(){}

//rotate
Vector2 VectorTools::rotateVector(Vector2 vec, float angleRadians)
{
    Vector2 ret;
    float c = mycosf(angleRadians);
    float s = mysinf(angleRadians);
    ret.X = (c * vec.X) - (s * vec.Y);
    ret.Y = (c * vec.Y) + (s * vec.X);
    return ret;
}

void VectorTools::rotateVector(Vector2 vecIn, float angleRadians, Vector2 &vecOut)
{
    float c = mycosf(angleRadians);
    float s = mysinf(angleRadians);
    vecOut.X = (c * vecIn.X) - (s * vecIn.Y);
    vecOut.Y = (c * vecIn.Y) + (s * vecIn.X);
}

void VectorTools::rotateVector(Vector2 &vecInOut, float angleRadians, int empty)
{
    float originalX = vecInOut.X;
    float originalY = vecInOut.Y;
    float c = mycosf(angleRadians);
    float s = mysinf(angleRadians);
    vecInOut.X = (c * originalX) - (s * originalY);
    vecInOut.Y = (c * originalY) + (s * originalX);
}

//reflect vector
Vector2 VectorTools::reflectVector(Vector2 V, Vector2 N)
{
	Vector2 ret = V - (N * (2 * Vector2::Dot(V, N)));
    return ret;
}

void VectorTools::reflectVector(Vector2 V, Vector2 N, Vector2 &vOut)
{
    float dot;
	Vector2::Dot(V, N, dot);
    vOut = V - (N * (2 * dot));
}

//getPerpendicular
Vector2 VectorTools::getPerpendicular(Vector2 vec)
{
    return Vector2(-vec.Y, vec.X);
}

void VectorTools::getPerpendicular(Vector2 vIn, Vector2 &vOut)
{
    vOut.X = -vIn.Y;
    vOut.Y = vIn.X;
}

//makePerpendicular
void VectorTools::makePerpendicular(Vector2 &v)
{
    float tempX = v.X;
    v.X = -v.Y;
    v.Y = tempX;
}

//isCCW
bool VectorTools::isCCW(Vector2 A, Vector2 B)
{
    Vector2 perp;
	VectorTools::getPerpendicular(A, perp);
    float dot = 0.0f;

	Vector2::Dot(B, perp, dot);
    return (dot >= 0.0f);
}

//vec3FromVec2
Vector3 VectorTools::vec3FromVec2(Vector2 vec)
{
    return Vector3(vec.X, vec.Y, 0);
}

Vector3 VectorTools::vec3FromVec2(Vector2 vec, float Z)
{
    return Vector3(vec.X, vec.Y, Z);
}

bool VectorTools::lineIntersect(Vector2 ptA, Vector2 ptB, Vector2 ptC, Vector2 ptD, Vector2 &hitPt, float &Ua, float &Ub)
{
	hitPt = Vector2::ZERO;
    Ua = 0.0f;
    Ub = 0.0f;

    float denom = ((ptD.Y - ptC.Y) * (ptB.X - ptA.X)) - ((ptD.X - ptC.X) * (ptB.Y - ptA.Y));

    // if denom == 0, lines are parallel - being a bit generous on this one..
    if (fabs(denom) < 0.000001f)
        return false;

    float UaTop = ((ptD.X - ptC.X) * (ptA.Y - ptC.Y)) - ((ptD.Y - ptC.Y) * (ptA.X - ptC.X));
    float UbTop = ((ptB.X - ptA.X) * (ptA.Y - ptC.Y)) - ((ptB.Y - ptA.Y) * (ptA.X - ptC.X));

    Ua = UaTop / denom;
    Ub = UbTop / denom;

    if ((Ua >= 0.0f) && (Ua <= 1.0f) && (Ub >= 0.0f) && (Ub <= 1.0f))
    {
        // these lines intersect!
        hitPt = ptA + ((ptB - ptA) * Ua);
        return true;
    }

    return false;
}


bool VectorTools::lineIntersect(Vector2 ptA, Vector2 ptB, Vector2 ptC, Vector2 ptD, Vector2 &hitPt)
{
    float Ua;
    float Ub;
    return VectorTools::lineIntersect(ptA, ptB, ptC, ptD, hitPt, Ua, Ub);
}


Vector2 VectorTools::calculateSpringForce(Vector2 posA, Vector2 velA, Vector2 posB, Vector2 velB, float springD, float springK, float damping)
{
    Vector2 BtoA = (posA - posB);
    float dist = BtoA.Length();
    if (dist > 0.0001f)
        BtoA /= dist;
    else
		BtoA = Vector2::ZERO;

    dist = springD - dist;

    Vector2 relVel = velA - velB;
	float totalRelVel = Vector2::Dot(relVel, BtoA);

    return BtoA * ((dist * springK) - (totalRelVel * damping));
}

void VectorTools::calculateSpringForce(Vector2 posA, Vector2 velA, Vector2 posB, Vector2 velB, float springD, float springK, float damping, Vector2 &forceOut)
{
    float BtoAX = (posA.X - posB.X);
    float BtoAY = (posA.Y - posB.Y);

    float dist = sqrt(((BtoAX * BtoAX) + (BtoAY * BtoAY)));
    if (dist > 0.0001f)
    {
        BtoAX /= dist;
        BtoAY /= dist;
    }
    else
    {
        forceOut.X = 0;
        forceOut.Y = 0;
        return;
    }

    dist = springD - dist;

    float relVelX = velA.X - velB.X;
    float relVelY = velA.Y - velB.Y;

    float totalRelVel = (relVelX * BtoAX) + (relVelY * BtoAY);

    forceOut.X = BtoAX * ((dist * springK) - (totalRelVel * damping));
    forceOut.Y = BtoAY * ((dist * springK) - (totalRelVel * damping));
}

float VectorTools::ToRadians(float degrees)
{
    return (float)(degrees * 0.017453292519943295769236907684886);
}
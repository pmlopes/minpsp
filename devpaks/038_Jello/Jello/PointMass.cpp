#include "PointMass.h"

PointMass::PointMass()
{
	Mass = 0.0f;
	Position = Velocity = Force = Vector2::ZERO;
}
PointMass::~PointMass()
{
}

PointMass::PointMass(float mass, Vector2 pos)
{
	Mass = mass;
	Position = pos;
	Velocity = Force = Vector2::ZERO;
}

void PointMass::integrateForce(float elapsed)
{
	if (Mass != 0.0f)
	{
		float elapMass = (elapsed / Mass);

		Velocity.X += (Force.X * elapMass);
		Velocity.Y += (Force.Y * elapMass);

		Position.X += (Velocity.X * elapsed);
		Position.Y += (Velocity.Y * elapsed);
	}

	Force.X = 0.0f;
	Force.Y = 0.0f;
}


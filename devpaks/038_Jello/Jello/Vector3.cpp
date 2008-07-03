#include "Vector3.h"

float Vector3::Length ()
{
    return mysqrtf( (X * X + Y * Y + Z * Z ));
}

float Vector3::SquaredLength ()
{
    return X * X + Y * Y + Z * Z;
}

float Vector3::Distance(const Vector3& rhs)
{
    return (*this - rhs).Length();
}

Vector3 Vector3::Cross(Vector3 vector1, Vector3 vector2)
{
    Cross(vector1, vector2, vector1);
    return vector1;
}

void Vector3::Cross(Vector3 vector1, Vector3 vector2, Vector3 &result)
{
    result = Vector3(vector1.Y * vector2.Z - vector2.Y * vector1.Z,
                         -(vector1.X * vector2.Z - vector2.X * vector1.Z),
                         vector1.X * vector2.Y - vector2.X * vector1.Y);
}
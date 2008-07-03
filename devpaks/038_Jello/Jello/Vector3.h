#ifndef VECTOR3_H
#define VECTOR3_H

//#include "math.h"

class Vector3
{
	public:
		float X, Y, Z;

    public:
        inline Vector3()
        {
			X = 0.0f;
			Y = 0.0f;
			Z = 0.0f;
        }

		~Vector3(){}

        inline Vector3( const float fX, const float fY, const float fZ )
            : X( fX ), Y( fY ), Z( fZ )
        {
        }

        inline explicit Vector3( const float afCoordinate[3] )
            : X( afCoordinate[0] ),
              Y( afCoordinate[1] ),
              Z( afCoordinate[2] )
        {
        }

        inline explicit Vector3( const int afCoordinate[3] )
        {
            X = (float)afCoordinate[0];
            Y = (float)afCoordinate[1];
            Z = (float)afCoordinate[2];
        }

        inline explicit Vector3( float* const r )
            : X( r[0] ), Y( r[1] ), Z( r[2] )
        {
        }

        inline explicit Vector3( const float scaler )
            : X( scaler )
            , Y( scaler )
            , Z( scaler )
        {
        }


        inline Vector3( const Vector3& rkVector )
            : X( rkVector.X ), Y( rkVector.Y ), Z( rkVector.Z )
        {
        }

		/// Pointer accessor for direct copying
		inline float* ptr()
		{
			return &X;
		}
		/// Pointer accessor for direct copying
		inline const float* ptr() const
		{
			return &X;
		}

        /** Assigns the value of the other vector.
            @param
                rkVector The other vector
        */
        inline Vector3& operator = ( const Vector3& rkVector )
        {
            X = rkVector.X;
            Y = rkVector.Y;
            Z = rkVector.Z;

            return *this;
        }

        inline Vector3& operator = ( const float fScaler )
        {
            X = fScaler;
            Y = fScaler;
            Z = fScaler;

            return *this;
        }

        inline bool operator == ( const Vector3& rkVector ) const
        {
            return ( X == rkVector.X && Y == rkVector.Y && Z == rkVector.Z );
        }

        inline bool operator != ( const Vector3& rkVector ) const
        {
            return ( X != rkVector.X || Y != rkVector.Y || Z != rkVector.Z );
        }

        // arithmetic operations
        inline Vector3 operator + ( const Vector3& rkVector ) const
        {
            return Vector3(
                X + rkVector.X,
                Y + rkVector.Y,
                Z + rkVector.Z);
        }

        inline Vector3 operator - ( const Vector3& rkVector ) const
        {
            return Vector3(
                X - rkVector.X,
                Y - rkVector.Y,
                Z - rkVector.Z);
        }

        inline Vector3 operator * ( const float fScalar ) const
        {
            return Vector3(
                X * fScalar,
                Y * fScalar,
                Z * fScalar);
        }

        inline Vector3 operator * ( const Vector3& rhs) const
        {
            return Vector3(
                X * rhs.X,
                Y * rhs.Y,
                Z * rhs.Z);
        }

        inline Vector3 operator / ( const float fScalar ) const
        {
            float fInv = 1 / fScalar;

            return Vector3(
                X * fInv,
                Y * fInv,
                Z * fInv);
        }

        inline Vector3 operator / ( const Vector3& rhs) const
        {
            return Vector3(
                X / rhs.X,
                Y / rhs.Y,
                Z / rhs.Z);
        }

        inline const Vector3& operator + () const
        {
            return *this;
        }

        inline Vector3 operator - () const
        {
            return Vector3(-X, -Y, -Z);
        }

        // overloaded operators to help Vector3
        inline friend Vector3 operator * ( const float fScalar, const Vector3& rkVector )
        {
            return Vector3(
                fScalar * rkVector.X,
                fScalar * rkVector.Y,
                fScalar * rkVector.Z);
        }

        inline friend Vector3 operator / ( const float fScalar, const Vector3& rkVector )
        {
            return Vector3(
                fScalar / rkVector.X,
                fScalar / rkVector.Y,
                fScalar / rkVector.Z);
        }

        inline friend Vector3 operator + (const Vector3& lhs, const float rhs)
        {
            return Vector3(
                lhs.X + rhs,
                lhs.Y + rhs,
                lhs.Z + rhs);
        }

        inline friend Vector3 operator + (const float lhs, const Vector3& rhs)
        {
            return Vector3(
                lhs + rhs.X,
                lhs + rhs.Y,
                lhs + rhs.Z);
        }

        inline friend Vector3 operator - (const Vector3& lhs, const float rhs)
        {
            return Vector3(
                lhs.X - rhs,
                lhs.Y - rhs,
                lhs.Z - rhs);
        }

        inline friend Vector3 operator - (const float lhs, const Vector3& rhs)
        {
            return Vector3(
                lhs - rhs.X,
                lhs - rhs.Y,
                lhs - rhs.Z);
        }

        // arithmetic updates
        inline Vector3& operator += ( const Vector3& rkVector )
        {
            X += rkVector.X;
            Y += rkVector.Y;
            Z += rkVector.Z;

            return *this;
        }

        inline Vector3& operator += ( const float fScalar )
        {
            X += fScalar;
            Y += fScalar;
            Z += fScalar;
            return *this;
        }

        inline Vector3& operator -= ( const Vector3& rkVector )
        {
            X -= rkVector.X;
            Y -= rkVector.Y;
            Z -= rkVector.Z;

            return *this;
        }

        inline Vector3& operator -= ( const float fScalar )
        {
            X -= fScalar;
            Y -= fScalar;
            Z -= fScalar;
            return *this;
        }

        inline Vector3& operator *= ( const float fScalar )
        {
            X *= fScalar;
            Y *= fScalar;
            Z *= fScalar;
            return *this;
        }

        inline Vector3& operator *= ( const Vector3& rkVector )
        {
            X *= rkVector.X;
            Y *= rkVector.Y;
            Z *= rkVector.Z;

            return *this;
        }

        inline Vector3& operator /= ( const float fScalar )
        {
            float fInv = 1 / fScalar;

            X *= fInv;
            Y *= fInv;
            Z *= fInv;

            return *this;
        }

        inline Vector3& operator /= ( const Vector3& rkVector )
        {
            X /= rkVector.X;
            Y /= rkVector.Y;
            Z /= rkVector.Z;

            return *this;
        }

		float Length();
		float SquaredLength();
		float Distance(const Vector3& rhs);
		static Vector3 Cross(Vector3 vector1, Vector3 vector2);
        static void Cross(Vector3 vector1, Vector3 vector2, Vector3 &result);

		static float mysqrtf(float val)
	{
	   float ret;

	   __asm__ volatile (
		  "mtv %1, S000\n"
		  "vsqrt.s S001, S000\n"
		  "mfv %0, S001\n"
		  : "=r"(ret) : "r"(val));

	   return ret;
	} 

};

#endif


#ifndef VECTOR2_H
#define VECTOR2_H

//#include <math.h>
//#include <pspmath.h>
#include "vfpu_ops.h"

class Vector2
{
public:

    float X, Y;
	static float vfpu_vars[4] __attribute__((aligned(64)));

    inline Vector2()
    {
		X = 0.0f;
		Y = 0.0f;
    }

	~Vector2()
	{
	}

    inline Vector2(const float fX, const float fY )
        : X( fX ), Y( fY )
    {
    }

    inline explicit Vector2( const float scaler )
        : X( scaler), Y( scaler )
    {
    }

    inline explicit Vector2( const float afCoordinate[2] )
        : X( afCoordinate[0] ),
          Y( afCoordinate[1] )
    {
    }

    inline explicit Vector2( const int afCoordinate[2] )
    {
        X = (float)afCoordinate[0];
        Y = (float)afCoordinate[1];
    }

    inline explicit Vector2( float* const r )
        : X( r[0] ), Y( r[1] )
    {
    }

    inline Vector2( const Vector2& rkVector )
        : X( rkVector.X ), Y( rkVector.Y )
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
    inline Vector2& operator = ( const Vector2& rkVector )
    {
        X = rkVector.X;
        Y = rkVector.Y;

        return *this;
    }

	inline Vector2& operator = ( const float fScalar)
	{
		X = fScalar;
		Y = fScalar;

		return *this;
	}

    inline bool operator == ( const Vector2& rkVector ) const
    {
        return ( X == rkVector.X && Y == rkVector.Y );
    }

    inline bool operator != ( const Vector2& rkVector ) const
    {
        return ( X != rkVector.X || Y != rkVector.Y  );
    }

    // arithmetic operations
    inline Vector2 operator + ( const Vector2& rkVector ) const
    {
        return Vector2(vfpu_add(X , rkVector.X), vfpu_add(Y , rkVector.Y));
    }

    inline Vector2 operator - ( const Vector2& rkVector ) const
    {
        return Vector2(vfpu_sub(X ,rkVector.X),vfpu_sub(Y , rkVector.Y));
    }

    inline Vector2 operator * ( float fScalar )
    {
        return Vector2(vfpu_mul(X , fScalar),vfpu_mul(Y , fScalar));
    }

    inline Vector2 operator * ( Vector2& rhs)
    {
        return Vector2(vfpu_mul(X , rhs.X),vfpu_mul(Y , rhs.Y));
    }

    inline Vector2 operator / ( float fScalar )
    {
        //float fInv = 1 / fScalar;

        return Vector2(vfpu_div(X , fScalar),vfpu_div( Y , fScalar));
    }

    inline Vector2 operator / ( Vector2& rhs)    {
        return Vector2(vfpu_div(X , rhs.X),vfpu_div(Y , rhs.Y));
    }

    inline const Vector2& operator + () const
    {
        return *this;
    }

    inline Vector2 operator - () const
    {
        return Vector2(-X, -Y);
    }

    // overloaded operators to help Vector2
    inline friend Vector2 operator * ( float fScalar, Vector2& rkVector )
    {
        return Vector2(fScalar * rkVector.X,fScalar * rkVector.Y);
    }

    inline friend Vector2 operator / ( float fScalar, Vector2& rkVector )
    {
		return Vector2(fScalar / rkVector.X,fScalar / rkVector.Y);
    }

    inline friend Vector2 operator + (const Vector2& lhs, const float rhs)
    {
        return Vector2( vfpu_add(lhs.X , rhs), vfpu_add(lhs.Y , rhs));
    }

    inline friend Vector2 operator + (const float lhs, const Vector2& rhs)
    {
        return Vector2(vfpu_add(lhs , rhs.X),vfpu_add(lhs , rhs.Y));
    }

    inline friend Vector2 operator - (const Vector2& lhs, const float rhs)
    {
        return Vector2(vfpu_sub(lhs.X , rhs),vfpu_sub(lhs.Y , rhs));
    }

    inline friend Vector2 operator - (const float lhs, const Vector2& rhs)
    {
        return Vector2(vfpu_sub(lhs , rhs.X),vfpu_sub(lhs , rhs.Y));
    }
    // arithmetic updates
    inline Vector2& operator += ( const Vector2& rkVector )
    {
        X = vfpu_add(X, rkVector.X);
        Y = vfpu_add(Y, rkVector.Y);

        return *this;
    }

    inline Vector2& operator += ( const float fScaler )
    {
        X = vfpu_add(X, fScaler);
        Y = vfpu_add(Y, fScaler);

        return *this;
    }

    inline Vector2& operator -= ( const Vector2& rkVector )
    {
        X = vfpu_sub(X,rkVector.X);
        Y = vfpu_sub(Y,rkVector.Y);

        return *this;
    }

    inline Vector2& operator -= ( const float fScaler )
    {
        X = vfpu_sub(X , fScaler);
        Y = vfpu_sub(Y , fScaler);

        return *this;
    }

    inline Vector2& operator *= ( const float fScalar )
    {
        X = vfpu_mul(X , fScalar);
        Y = vfpu_mul(Y , fScalar);

        return *this;
    }

    inline Vector2& operator *= ( const Vector2& rkVector )
    {
        X = vfpu_mul(X , rkVector.X);
        Y = vfpu_mul(Y , rkVector.Y);

        return *this;
    }

    inline Vector2& operator /= ( const float fScalar )
    {
        X =vfpu_div(X , fScalar);
        Y =vfpu_div(Y , fScalar);

        return *this;
    }

    inline Vector2& operator /= ( const Vector2& rkVector )
    {
        X =vfpu_div(X , rkVector.X);
        Y =vfpu_div(Y , rkVector.Y);

        return *this;
    }

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

	static float vfpu_add(float f1, float f2)
	{
	   vfpu_vars[0] = f1;
	   vfpu_vars[1] = f2;
	   register void *ptr __asm ("a0") = vfpu_vars;
	   __asm__ volatile (
		  cgen_asm(lv_s(0, 0, R_a0, 0))
		  cgen_asm(lv_s(1, 1, R_a0, 0))
		  cgen_asm(vadd_s(124, 0, 1))
		  cgen_asm(sv_q(31, 0 * 4, R_a0, 0))
	   : "=r"(ptr) : "r"(ptr) : "memory");
	   return vfpu_vars[0];
	}

	static float vfpu_sub(float f1, float f2)
	{
	   vfpu_vars[0] = f1;
	   vfpu_vars[1] = f2;
	   register void *ptr __asm ("a0") = vfpu_vars;
	   __asm__ volatile (
		  cgen_asm(lv_s(0, 0, R_a0, 0))
		  cgen_asm(lv_s(1, 1, R_a0, 0))
		  cgen_asm(vsub_s(124, 0, 1))
		  cgen_asm(sv_q(31, 0 * 4, R_a0, 0))
	   : "=r"(ptr) : "r"(ptr) : "memory");
	   return vfpu_vars[0];
	}

	float vfpu_mul(float f1, float f2)
	{
	   vfpu_vars[0] = f1;
	   vfpu_vars[1] = f2;
	   register void *ptr __asm ("a0") = vfpu_vars;
	   __asm__ volatile (
		  cgen_asm(lv_s(0, 0, R_a0, 0))
		  cgen_asm(lv_s(1, 1, R_a0, 0))
		  cgen_asm(vmul_s(124, 0, 1))
		  cgen_asm(sv_q(31, 0 * 4, R_a0, 0))
	   : "=r"(ptr) : "r"(ptr) : "memory");
	   return vfpu_vars[0];
	}

	float vfpu_div(float f1, float f2)
	{
	   vfpu_vars[0] = f1;
	   vfpu_vars[1] = f2;
	   register void *ptr __asm ("a0") = vfpu_vars;
	   __asm__ volatile (
		  cgen_asm(lv_s(0, 0, R_a0, 0))
		  cgen_asm(lv_s(1, 1, R_a0, 0))
		  cgen_asm(vdiv_s(124, 0, 1))
		  cgen_asm(sv_q(31, 0 * 4, R_a0, 0))
	   : "=r"(ptr) : "r"(ptr) : "memory");
	   return vfpu_vars[0];
	}


	

	// special points
    static const Vector2 ZERO;
	static const Vector2 One;
    static const Vector2 UNIT_X;
    static const Vector2 UNIT_Y;
    static const Vector2 NEGATIVE_UNIT_X;
    static const Vector2 NEGATIVE_UNIT_Y;
    static const Vector2 UNIT_SCALE;

	static void DistanceSquared(Vector2 value1, Vector2 value2, float &result);
	static void Distance(Vector2 value1, Vector2 value2, float &result);
	static float Dot(Vector2 value1, Vector2 value2);
    static void Dot(Vector2 value1, Vector2 value2, float &result);
	float Length();
    float LengthSquared();
	static void Normalize( Vector2 value, Vector2 &result);
};

#endif


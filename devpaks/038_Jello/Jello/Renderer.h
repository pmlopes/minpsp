#ifndef Renderer_H
#define Renderer_H

#include "Vector2.h"
#include "PointMass.h"
#include <vector>

#include <GL/gl.h>	// Header File For The OpenGL32 Library
#include <GL/glu.h>	// Header File For The GLu32 Library



/**
* Debug renderer for OpenGL
*/
class Renderer
{
public :


	static void RenderGlobalShapeLine(std::vector<PointMass*> &mPointMasses,float R,float G,float B)
    {
        glColor3f(R, G, B);
        glBegin(GL_LINE_LOOP);

		float temp = mPointMasses.size();

        for (unsigned int i = 0; i < temp; i++)
        {
			glVertex2f(mPointMasses[i]->Position.X, mPointMasses[i]->Position.Y);
        }
		glVertex2f(mPointMasses[0]->Position.X, mPointMasses[0]->Position.Y);


        glEnd();
     }

	
	static void RenderLine(Vector2 start,Vector2 stop,float R,float G,float B)
    {
        glColor3f(R, G, B);
        glBegin(GL_LINE_LOOP);

        glVertex2f(start.X, start.Y);
   		glVertex2f(stop.X, stop.Y);

        glEnd();
     }
	/*
	static void RenderGlobalShapeLine(Vector2 *Vertices,int num,float R,float G,float B)
    {
        glColor3f(R, G, B);
        glBegin(GL_LINE_LOOP);

        for (int i = 0; i < num; i++)
        {
			glVertex2f(Vertices[i].X, Vertices[i].Y);
        }
		glVertex2f(Vertices[0].X, Vertices[0].Y);


        glEnd();

		//delete [] Vertices;
     }

	static void FillBlobShape(Vector2 *vertexArray,int count,float R,float G,float B)
    {
        glColor3f(R, G, B);
        glBegin(GL_TRIANGLE_FAN);

        for(int i = 0;i < count;i++)
        {
			glVertex2f(vertexArray[i].X, vertexArray[i].Y);
        }

        glEnd();
		//delete [] vertexArray;
    }

    static void RenderPoints(std::vector<PointMass*> &mPointMasses,float R,float G,float B)
    {
        glEnable(GL_POINT_SIZE);
        glPointSize(5.0f);


        glColor3f(R, G, B);
        glBegin(GL_POINTS);

        for (unsigned int i = 0; i < mPointMasses.size(); i++)
        {
			glVertex2f(((PointMass*)mPointMasses.at(i))->Position.X, ((PointMass*)mPointMasses.at(i))->Position.Y);
        }

        glEnd();
        glDisable(GL_POINT_SIZE);
    }
	*/
	static void FillSpringShape(std::vector<PointMass*> &mPointMasses, int *mIndices,int mIndicesCount,float R,float G,float B)
    {
        glColor3f(R, G, B);
        for (int i = 0; i < mIndicesCount; i += 3)
        {
            glBegin(GL_TRIANGLES);

            glVertex2f(((PointMass*)mPointMasses.at(mIndices[i]))->Position.X, ((PointMass*)mPointMasses.at(mIndices[i]))->Position.Y);
            glVertex2f(((PointMass*)mPointMasses.at(mIndices[i+1]))->Position.X, ((PointMass*)mPointMasses.at(mIndices[i+1]))->Position.Y);
            glVertex2f(((PointMass*)mPointMasses.at(mIndices[i+2]))->Position.X, ((PointMass*)mPointMasses.at(mIndices[i+2]))->Position.Y);

            glEnd();
        }
    }
};


#endif
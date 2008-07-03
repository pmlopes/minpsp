#include <stdlib.h> // needed in order to have "exit" function @@@
//#include <math.h>

#include <GL/glut.h>    // Header File For The GLUT Library 
#include <GL/gl.h>	// Header File For The OpenGL32 Library
#include <GL/glu.h>	// Header File For The GLu32 Library

#include <vector>

#include <Jello/Vector2.h>
#include <Jello/Vector3.h>
#include <Jello/VectorTools.h>
#include <Jello/AABB.h>
#include <Jello/Bitmask.h>
#include <Jello/PointMass.h>
#include <Jello/InternalSpring.h>
#include <Jello/ClosedShape.h>
#include <Jello/Body.h>
#include <Jello/SpringBody.h>
#include <Jello/PressureBody.h>
#include <Jello/World.h>


extern "C"
{
#  include <pspkernel.h>

  /* Define the module info section */
  PSP_MODULE_INFO(__FILE__, 0, 1, 1);

  /* Define the main thread's attribute value (optional) */
  PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER | THREAD_ATTR_VFPU);
  

  int exitCallback(int arg1, int arg2, void *common)
  {
	sceKernelExitGame () ;
    return 0 ;
  }


  int callbackThread(SceSize args, void *argp)
  {
    int cbid;

    cbid = sceKernelCreateCallback ( "Exit Callback", exitCallback, NULL ) ;
    sceKernelRegisterExitCallback ( cbid ) ;

    sceKernelSleepThreadCB () ;
    return 0 ;
  }


  int setupCallbacks(void)
  {
    int thid = 0;
    thid = sceKernelCreateThread ( "update_thread", callbackThread, 0x11, 0xFA0, 0, 0 ) ;
    if ( thid >= 0 )
    {
      sceKernelStartThread ( thid, 0, 0 ) ;
    }
    return thid;
  }
}

int mousedown = 0;
float xMouse, yMouse;
int window; 

bool mouseD = false;
bool springy = true;
bool pressure = true;

World mWorld;
Body *bod;

std::vector<SpringBody*> springBodies;
std::vector<PressureBody*> pressureBodies;

ClosedShape *ball,*springI,*box;

PressureBody *pb;

SpringBody *leftB,*rightB,*dragBody;

float dragX,dragY;
int dragPoint = -1;

float mysinf(float val)
   {
	   float ret;

	   val *= 0.6366197f; // convert to deg/90

	   __asm__ volatile (
		  "mtv %1, S000\n"
		  "vsin.s S001, S000\n"
		  "mfv %0, S001\n"
		  : "=r"(ret) : "r"(val));

	   return ret;
   } 

	float mycosf(float val)
   {
	   float ret;

	   val *= 0.6366197f; // convert to deg/90

	   __asm__ volatile (
		  "mtv %1, S000\n"
		  "vcos.s S001, S000\n"
		  "mfv %0, S001\n"
		  : "=r"(ret) : "r"(val));

	   return ret;
   } 


/* A general OpenGL initialization function.  Sets all of the initial parameters. */
void InitGL(int Width, int Height)	        // We call this right after our OpenGL window is created.
{
	glClearColor(1.0f, 1.0f, 1.0f, 0.5f);		// This Will Clear The Background Color To Black
	glClearDepth(1.0);				// Enables Clearing Of The Depth Buffer
	glDepthFunc(GL_LESS);				// The Type Of Depth Test To Do
	glEnable(GL_DEPTH_TEST);			// Enables Depth Testing
	glShadeModel(GL_SMOOTH);			// Enables Smooth Color Shading

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();				// Reset The Projection Matrix

	glOrtho(-25,25,-21,21,-2,2);

	glMatrixMode(GL_MODELVIEW);

	ClosedShape *shape1 = new ClosedShape();
	shape1->begin();
	shape1->addVertex(Vector2(-20.0f, -1.0f));
	shape1->addVertex(Vector2(-20.0f, 1.0f));
	shape1->addVertex(Vector2(20.0f, 1.0f));
	shape1->addVertex(Vector2(20.0f, -1.0f));
	shape1->finish();

	bod = new Body(shape1,0.0f,Vector2(0.0f, -19.0f),0.0f,Vector2(1.0f, 1.0f),false);
	mWorld.addBody(bod);

	//ball shape
	ball = new ClosedShape();
	ball->begin();
	for (int i = 0; i < 360; i += 20)
    {
		ball->addVertex(Vector2(mycosf(VectorTools::ToRadians((float)-i)), mysinf(VectorTools::ToRadians((float)-i))));
    }
	ball->finish();
	/*
	//pressure body
	pb = new PressureBody(ball, 1.0f, 40.0f, 10.0f, 1.0f, 300.0f, 20.0f, Vector2(0, -10), 0.0f, Vector2(0.5f,0.5f),false);

	mWorld.addBody(pb);
	pressureBodies.push_back(pb);*/

	//I shape
	
	springI = new ClosedShape();
    springI->begin();
    springI->addVertex(Vector2(-1.5f, 2.0f));
    springI->addVertex(Vector2(-0.5f, 2.0f));
    springI->addVertex(Vector2(0.5f, 2.0f));
    springI->addVertex(Vector2(1.5f, 2.0f));
    springI->addVertex(Vector2(1.5f, 1.0f));
    springI->addVertex(Vector2(0.5f, 1.0f));
    springI->addVertex(Vector2(0.5f, -1.0f));
    springI->addVertex(Vector2(1.5f, -1.0f));
    springI->addVertex(Vector2(1.5f, -2.0f));
    springI->addVertex(Vector2(0.5f, -2.0f));
    springI->addVertex(Vector2(-0.5f, -2.0f));
    springI->addVertex(Vector2(-1.5f, -2.0f));
    springI->addVertex(Vector2(-1.5f, -1.0f));
    springI->addVertex(Vector2(-0.5f, -1.0f));
    springI->addVertex(Vector2(-0.5f, 1.0f));
    springI->addVertex(Vector2(-1.5f, 1.0f));
    springI->finish();



	leftB = new SpringBody(springI, 1.0f, 150.0f, 5.0f, 300.0f, 15.0f, Vector2(-5, -5), 0.0f, Vector2::One,false);
	leftB->addInternalSpring(0, 14, 300.0f, 10.0f);
    leftB->addInternalSpring(1, 14, 300.0f, 10.0f);
    leftB->addInternalSpring(1, 15, 300.0f, 10.0f);
    leftB->addInternalSpring(1, 5, 300.0f, 10.0f);
    leftB->addInternalSpring(2, 14, 300.0f, 10.0f);
    leftB->addInternalSpring(2, 5, 300.0f, 10.0f);
    leftB->addInternalSpring(1, 5, 300.0f, 10.0f);
    leftB->addInternalSpring(14, 5, 300.0f, 10.0f);
    leftB->addInternalSpring(2, 4, 300.0f, 10.0f);
    leftB->addInternalSpring(3, 5, 300.0f, 10.0f);
    leftB->addInternalSpring(14, 6, 300.0f, 10.0f);
    leftB->addInternalSpring(5, 13, 300.0f, 10.0f);
    leftB->addInternalSpring(13, 6, 300.0f, 10.0f);
    leftB->addInternalSpring(12, 10, 300.0f, 10.0f);
    leftB->addInternalSpring(13, 11, 300.0f, 10.0f);
    leftB->addInternalSpring(13, 10, 300.0f, 10.0f);
    leftB->addInternalSpring(13, 9, 300.0f, 10.0f);
    leftB->addInternalSpring(6, 10, 300.0f, 10.0f);
    leftB->addInternalSpring(6, 9, 300.0f, 10.0f);
    leftB->addInternalSpring(6, 8, 300.0f, 10.0f);
    leftB->addInternalSpring(7, 9, 300.0f, 10.0f);

	// polygons!
    leftB->addTriangle(0, 15, 1);
    leftB->addTriangle(1, 15, 14);
    leftB->addTriangle(1, 14, 5);
    leftB->addTriangle(1, 5, 2);
    leftB->addTriangle(2, 5, 4);
    leftB->addTriangle(2, 4, 3);
    leftB->addTriangle(14, 13, 6);
    leftB->addTriangle(14, 6, 5);
    leftB->addTriangle(12, 11, 10);
    leftB->addTriangle(12, 10, 13);
    leftB->addTriangle(13, 10, 9);
    leftB->addTriangle(13, 9, 6);
    leftB->addTriangle(6, 9, 8);
    leftB->addTriangle(6, 8, 7);
    leftB->finalizeTriangles();

	mWorld.addBody(leftB);
	springBodies.push_back(leftB);
   
	rightB = new SpringBody(springI, 1.0f, 150.0f, 5.0f, 300.0f, 15.0f, Vector2(5, -5), 0.0f, Vector2::One,false);
	rightB->addInternalSpring(0, 14, 300.0f, 10.0f);
    rightB->addInternalSpring(1, 14, 300.0f, 10.0f);
    rightB->addInternalSpring(1, 15, 300.0f, 10.0f);
    rightB->addInternalSpring(1, 5, 300.0f, 10.0f);
    rightB->addInternalSpring(2, 14, 300.0f, 10.0f);
    rightB->addInternalSpring(2, 5, 300.0f, 10.0f);
    rightB->addInternalSpring(1, 5, 300.0f, 10.0f);
    rightB->addInternalSpring(14, 5, 300.0f, 10.0f);
    rightB->addInternalSpring(2, 4, 300.0f, 10.0f);
    rightB->addInternalSpring(3, 5, 300.0f, 10.0f);
    rightB->addInternalSpring(14, 6, 300.0f, 10.0f);
    rightB->addInternalSpring(5, 13, 300.0f, 10.0f);
    rightB->addInternalSpring(13, 6, 300.0f, 10.0f);
    rightB->addInternalSpring(12, 10, 300.0f, 10.0f);
    rightB->addInternalSpring(13, 11, 300.0f, 10.0f);
    rightB->addInternalSpring(13, 10, 300.0f, 10.0f);
    rightB->addInternalSpring(13, 9, 300.0f, 10.0f);
    rightB->addInternalSpring(6, 10, 300.0f, 10.0f);
    rightB->addInternalSpring(6, 9, 300.0f, 10.0f);
    rightB->addInternalSpring(6, 8, 300.0f, 10.0f);
    rightB->addInternalSpring(7, 9, 300.0f, 10.0f);
	// polygons!
    rightB->addTriangle(0, 15, 1);
    rightB->addTriangle(1, 15, 14);
    rightB->addTriangle(1, 14, 5);
    rightB->addTriangle(1, 5, 2);
    rightB->addTriangle(2, 5, 4);
    rightB->addTriangle(2, 4, 3);
    rightB->addTriangle(14, 13, 6);
    rightB->addTriangle(14, 6, 5);
    rightB->addTriangle(12, 11, 10);
    rightB->addTriangle(12, 10, 13);
    rightB->addTriangle(13, 10, 9);
    rightB->addTriangle(13, 9, 6);
    rightB->addTriangle(6, 9, 8);
    rightB->addTriangle(6, 8, 7);
    rightB->finalizeTriangles();

	mWorld.addBody(rightB);
	springBodies.push_back(rightB);
}

/* The function called when our window is resized (which shouldn't happen, because we're fullscreen) */
void ReSizeGLScene(int Width, int Height)
{
  if (Height==0)				// Prevent A Divide By Zero If The Window Is Too Small
    Height=1;

  glViewport(0, 0, Width, Height);		// Reset The Current Viewport And Perspective Transformation

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();

  glOrtho(-25,25,-21,21,-2,2);
  glMatrixMode(GL_MODELVIEW);
}

/* The main drawing function. */
void DrawGLScene()
{
	//physic update
	for(int i = 0;i < 5;i++)
		mWorld.update((1.0f/80.0f));


	//dragging
	if (mouseD == true)
    {
        if (dragBody != NULL)
        {
           PointMass *pm = dragBody->getPointMass(dragPoint);
			dragBody->setDragForce(VectorTools::calculateSpringForce(pm->Position, pm->Velocity, Vector2(xMouse,yMouse), Vector2::ZERO, 0.0f, 100.0f, 10.0f), dragPoint);
        }
    }
    else
    {
        dragBody = NULL;
        dragPoint = -1;
    }

	if(mouseD == true)
	{
		if(dragBody == NULL)
		{
			int body;
            mWorld.getClosestPointMass(Vector2(xMouse,yMouse), body, dragPoint);
			if(mWorld.getBody(body)->Type == 2)
				dragBody = (SpringBody*)mWorld.getBody(body);
		}
	}

	//rendering
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();		

	//floor
	bod->DrawMe();

	//pressure
	for(unsigned int i = 0;i < pressureBodies.size();i++)
		pressureBodies[i]->DrawMe();

	//cursor
	for(unsigned int i = 0;i < springBodies.size();i++)
		springBodies[i]->DrawMe();
	  
	  
	//draw pointer
	glColor3f(1,0,0);
	glBegin(GL_QUADS);
		glVertex3f(xMouse-0.2f,yMouse+0.2f,0);
		glVertex3f(xMouse+0.2f,yMouse+0.2f,0);
		glVertex3f(xMouse+0.2f,yMouse-0.2f,0);
		glVertex3f(xMouse-0.2f,yMouse-0.2f,0);
	glEnd();
	
	//draw line from body to cursor
	if(dragBody != NULL)
	{
		Renderer::RenderLine(dragBody->getPointMass(dragPoint)->Position,Vector2(xMouse,yMouse),0,0,1);
	}
 
  glutSwapBuffers();
}

/* The function called whenever a key is pressed. */
// @@@ this function is  modified to use PSP pad
void keyPressed(unsigned char key, int x, int y) 
{
	/*
	KEY_ASCII(1,'d'),		 PSP_CTRL_TRIANGLE = 0x001000 
	KEY_ASCII(1,'o'),		 PSP_CTRL_CIRCLE   = 0x002000 
	KEY_ASCII(1,'x'),		 PSP_CTRL_CROSS    = 0x004000 
	KEY_ASCII(1,'q'),		 PSP_CTRL_SQUARE   = 0x008000 */
 	switch (key) {
	case 'a':			/* startbutton */ /* If START is pressed, kill everything. */

		exit(0);
	break;
	case 'd':
		mouseD = true;
		
	break;
	case 'q':
		if(springy == true)
		{
			//add pressure body
						
			SpringBody *sBody = new SpringBody(springI, 1.0f, 150.0f, 5.0f, 300.0f, 15.0f, Vector2(-5.0f, -5.0f), 0.0f, Vector2::One,false);
			sBody->addInternalSpring(0, 14, 300.0f, 10.0f);
			sBody->addInternalSpring(1, 14, 300.0f, 10.0f);
			sBody->addInternalSpring(1, 15, 300.0f, 10.0f);
			sBody->addInternalSpring(1, 5, 300.0f, 10.0f);
			sBody->addInternalSpring(2, 14, 300.0f, 10.0f);
			sBody->addInternalSpring(2, 5, 300.0f, 10.0f);
			sBody->addInternalSpring(1, 5, 300.0f, 10.0f);
			sBody->addInternalSpring(14, 5, 300.0f, 10.0f);
			sBody->addInternalSpring(2, 4, 300.0f, 10.0f);
			sBody->addInternalSpring(3, 5, 300.0f, 10.0f);
			sBody->addInternalSpring(14, 6, 300.0f, 10.0f);
			sBody->addInternalSpring(5, 13, 300.0f, 10.0f);
			sBody->addInternalSpring(13, 6, 300.0f, 10.0f);
			sBody->addInternalSpring(12, 10, 300.0f, 10.0f);
			sBody->addInternalSpring(13, 11, 300.0f, 10.0f);
			sBody->addInternalSpring(13, 10, 300.0f, 10.0f);
			sBody->addInternalSpring(13, 9, 300.0f, 10.0f);
			sBody->addInternalSpring(6, 10, 300.0f, 10.0f);
			sBody->addInternalSpring(6, 9, 300.0f, 10.0f);
			sBody->addInternalSpring(6, 8, 300.0f, 10.0f);
			sBody->addInternalSpring(7, 9, 300.0f, 10.0f);

			// polygons!
			sBody->addTriangle(0, 15, 1);
			sBody->addTriangle(1, 15, 14);
			sBody->addTriangle(1, 14, 5);
			sBody->addTriangle(1, 5, 2);
			sBody->addTriangle(2, 5, 4);
			sBody->addTriangle(2, 4, 3);
			sBody->addTriangle(14, 13, 6);
			sBody->addTriangle(14, 6, 5);
			sBody->addTriangle(12, 11, 10);
			sBody->addTriangle(12, 10, 13);
			sBody->addTriangle(13, 10, 9);
			sBody->addTriangle(13, 9, 6);
			sBody->addTriangle(6, 9, 8);
			sBody->addTriangle(6, 8, 7);
			sBody->finalizeTriangles();

			mWorld.addBody(sBody);
			springBodies.push_back(sBody);

			springy = false;
		}
		break;
	case 'o':
		if(pressure == true)
		{
			PressureBody * pressureBody = new PressureBody(ball, 1.0f, 40.0f, 10.0f, 1.0f, 300.0f, 20.0f, Vector2(0, -10), 0, Vector2(0.5f,0.5f),false);

			mWorld.addBody(pressureBody);
			pressureBodies.push_back(pressureBody);

			pressure = false;
		}
		break;
	
	default:
		;
	}
}

void special(int key, int x, int y)
{
	switch(key)
	{
		case GLUT_KEY_LEFT:
			xMouse-=1.0f;
		break;
		case GLUT_KEY_RIGHT:
			xMouse+=1.0f;
		break;
		case GLUT_KEY_UP:
			yMouse+=1.0f;
		break;
		case GLUT_KEY_DOWN:
			yMouse-=1.0f;
		break;
		default:
		;
	}
}

void keyup (unsigned char key, int x, int y)
{
	switch (key) {
	case 'd':
		mouseD = false;
	break;
	case 'q':
		springy = true;
		break;
	case 'o':
		pressure = true;
		break;
	default:
		;
	}
}

int main(int argc, char **argv) 
{  
  /* Initialize GLUT state - glut will take any command line arguments that pertain to it or 
     X Windows - look at its documentation at http://reality.sgi.com/mjk/spec3/spec3.html */  
  glutInit(&argc, argv);  

  /* Select type of Display mode:   
     Double buffer 
     RGBA color
     Alpha components supported 
     Depth buffer */  
  glutInitDisplayMode( GLUT_DOUBLE );  

  /* get a 640 x 480 window */
  glutInitWindowSize(480, 272);  // @@@

  /* the window starts at the upper left corner of the screen */
  glutInitWindowPosition(0, 0);  

  /* Open a window */  
  window = glutCreateWindow("Soft Body Test");  

  /* Register the function to do all our OpenGL drawing. */
  glutDisplayFunc(&DrawGLScene);  

  /* Go fullscreen.  This is as soon as possible. */
//  glutFullScreen(); @@@ there is no glutFullScreen in pspgl

  /* Even if there are no events, redraw our gl scene. */
  glutIdleFunc(&DrawGLScene);

  /* Register the function called when our window is resized. */
  glutReshapeFunc(&ReSizeGLScene);

  /* Register the function called when the keyboard is pressed. */
  glutKeyboardFunc(&keyPressed);
  glutKeyboardUpFunc(&keyup);
  glutSpecialFunc(&special);

  /* Initialize our window. */
  InitGL(480, 272); // @@@
  
  /* Start Event Processing Engine */  
  glutMainLoop();  

  return 1;
}

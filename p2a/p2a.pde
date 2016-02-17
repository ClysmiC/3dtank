// 3D Scene Example

import processing.opengl.*;

float time = 0;  // keep track of passing of time
final int CAMERA_DISTANCE = 130;

float xRotate = -PI / 6;
float yRotate = PI / 6;
boolean mouseDown = false;

final int PRIMARY_COLOR = 0xFFB0B0B0;
final int SECONDARY_COLOR = 0xFF3232F0;
final int TIRE_COLOR = 0xFF222222;

void setup() {
  size(700, 700, P3D);  // must use 3D here !!!
  noStroke();           // do not draw the edges of polygons
}

//allow for arbitrary rotation except for Z axis (better for viewing)
void mousePressed()
{
  mouseDown = true;
}

void mouseReleased()
{
  mouseDown = false;
}

void keyPressed()
{
  //resets camera
  if (key == ' ')
  {
    xRotate = -PI/6;
    yRotate = PI/6;
  }
}

void rotateDueToMouse()
{
  //fires max 100 times per second
  if(mouseDown && millis() - time >= 10)
  {
    //location of click where origin is center of screen
    int xLoc = mouseX - width / 2;
    int yLoc = -(mouseY - height / 2);
    
    yRotate += (xLoc / 5000f);
    xRotate += (yLoc / 5000f);
    
    time = millis();
  }
  
  rotate(xRotate, 1, 0, 0);
  rotate(yRotate, 0, 1, 0);
}

// Draw a scene with a cylinder, a sphere and a box
void draw() {
  
  resetMatrix();  // set the transformation matrix to the identity (important!)

  background(0);  // clear the screen to black
  
  // set up for perspective projection
  perspective (PI * 0.333, 1.0, 0.01, 1000.0);
  
  // place the camera in the scene (just like gluLookAt())
  camera (0, 0, CAMERA_DISTANCE, 0.0, 0.0, 0, 0.0, 1.0, 0.0);
  
    
  // create an ambient light source
  ambientLight (102, 102, 102);
  
  // create two directional light sources
  lightSpecular (150, 150, 150);
  directionalLight (102, 102, 102, 1, 0.7, .2);
  directionalLight (102, 102, 102, 1, .7, .2);
  
  //rotate EVERYTHING by xRotate and yRotate, to allow for arbitrary-ish rotation by user
  pushMatrix();
  rotateDueToMouse();
  
  //front right tire
  pushMatrix();
  translate(-20, 0, 30);
  tireAndCasing();
  popMatrix();
  
  //front left tire
  pushMatrix();
  translate(20, 0, 30);
  tireAndCasing();
  popMatrix();
  
  //back right tire
  pushMatrix();
  translate(-20, 0, -30);
  rotate(PI, 0, 1, 0);
  tireAndCasing();
  popMatrix();
  
  //back left tire
  pushMatrix();
  translate(20, 0, -30);
  rotate(PI, 0, 1, 0);
  tireAndCasing();
  popMatrix();
  
  //flat hex prism connecting wheels
  fill(PRIMARY_COLOR);
  pushMatrix();
  translate(0, -5, 0);
  rotate(PI/2, 1, 0, 0);
  rotate(2 * PI / 12f, 0, 0, 1);
  hexPrism(25, 25, 8);
  popMatrix();
  
  //long hex prism between front and back tires
  pushMatrix();
  translate(0, -4, 0);
  rotate(PI/2, 0, 1, 0);
  hexPrism(42, 8, 24);
  popMatrix();
  
  //hex prism sitting on top to shoot the gun
  pushMatrix();
  translate(0, -14, 0);
  rotate(PI/2, 1, 0, 0);
  hexPrism(20, 20, 15);
  popMatrix();
  
  fill(SECONDARY_COLOR);
  
  //blue emblem on top
  pushMatrix();
  translate(0, -22, 0);
  trapPrism(10, 2, 15);
  popMatrix();
  
  pushMatrix();
  translate(0, -16, 30);
  gun();
  popMatrix();
  
  //pop rotation matrix
  popMatrix();
}

// Draw a cylinder of a given radius, height and number of sides.
// The base is on the y=0 plane, and it extends vertically in the y direction.
void cylinder (float radius, float height, int sides) {
  int i,ii;
  float []c = new float[sides];
  float []s = new float[sides];

  for (i = 0; i < sides; i++) {
    float theta = TWO_PI * i / (float) sides;
    c[i] = cos(theta);
    s[i] = sin(theta);
  }
  
  // bottom end cap
  
  normal (0.0, -1.0, 0.0);
  for (i = 0; i < sides; i++) {
    ii = (i+1) % sides;
    beginShape(TRIANGLES);
    vertex (c[ii] * radius, 0.0, s[ii] * radius);
    vertex (c[i] * radius, 0.0, s[i] * radius);
    vertex (0.0, 0.0, 0.0);
    endShape();
  }
  
  // top end cap

  normal (0.0, 1.0, 0.0);
  for (i = 0; i < sides; i++) {
    ii = (i+1) % sides;
    beginShape(TRIANGLES);
    vertex (c[ii] * radius, height, s[ii] * radius);
    vertex (c[i] * radius, height, s[i] * radius);
    vertex (0.0, height, 0.0);
    endShape();
  }
  
  // main body of cylinder
  for (i = 0; i < sides; i++) {
    ii = (i+1) % sides;
    beginShape();
    normal (c[i], 0.0, s[i]);
    vertex (c[i] * radius, 0.0, s[i] * radius);
    vertex (c[i] * radius, height, s[i] * radius);
    normal (c[ii], 0.0, s[ii]);
    vertex (c[ii] * radius, height, s[ii] * radius);
    vertex (c[ii] * radius, 0.0, s[ii] * radius);
    endShape(CLOSE);
  }
}
  
void rectPrism(float xLength, float yLength, float zLength)
{
  pushMatrix();
  scale(xLength, yLength, zLength);
  box(1);
  popMatrix();
}

void hexPrism(float xScale, float yScale, float zScale)
{
  pushMatrix();
  scale(xScale, yScale, zScale);
  
  //front face
  beginShape();
  vertex(-.5, (float)Math.sqrt(3)/2f, .5);
  vertex(-1, 0, .5);
  vertex(-.5, (float)-Math.sqrt(3)/2f, .5);
  vertex(.5, (float)-Math.sqrt(3)/2f, .5);
  vertex(1, 0, .5);
  vertex(.5, (float)Math.sqrt(3)/2f, .5);
  endShape(CLOSE);
  
  //back face
  beginShape();
  vertex(-.5, (float)Math.sqrt(3)/2f, -.5);
  vertex(-1, 0, -.5);
  vertex(-.5, (float)-Math.sqrt(3)/2f, -.5);
  vertex(.5, (float)-Math.sqrt(3)/2f, -.5);
  vertex(1, 0, -.5);
  vertex(.5, (float)Math.sqrt(3)/2f, -.5);
  endShape(CLOSE);
  
  //top face
  beginShape();
  vertex(-.5, -(float)Math.sqrt(3)/2f, .5);
  vertex(-.5, -(float)Math.sqrt(3)/2f, -.5);
  vertex(.5, -(float)Math.sqrt(3)/2f, -.5);
  vertex(.5, -(float)Math.sqrt(3)/2f, .5);
  endShape(CLOSE);
  
  //top left face
  beginShape();
  vertex(-1, 0, .5);
  vertex(-1, 0, -.5);
  vertex(-.5, -(float)Math.sqrt(3)/2f, -.5);
  vertex(-.5, -(float)Math.sqrt(3)/2f, .5);
  endShape(CLOSE);
  
  //bottom left face
  beginShape();
  vertex(-1, 0, .5);
  vertex(-1, 0, -.5);
  vertex(-.5, (float)Math.sqrt(3)/2f, -.5);
  vertex(-.5, (float)Math.sqrt(3)/2f, .5);
  endShape(CLOSE);
  
  //bottom face
  beginShape();
  vertex(-.5, (float)Math.sqrt(3)/2f, .5);
  vertex(-.5, (float)Math.sqrt(3)/2f, -.5);
  vertex(.5, (float)Math.sqrt(3)/2f, -.5);
  vertex(.5, (float)Math.sqrt(3)/2f, .5);
  endShape(CLOSE);
  
  //bottom right face
  beginShape();
  vertex(1, 0, .5);
  vertex(1, 0, -.5);
  vertex(.5, (float)Math.sqrt(3)/2f, -.5);
  vertex(.5, (float)Math.sqrt(3)/2f, .5);
  endShape(CLOSE);
  
  //top right face
  beginShape();
  vertex(1, 0, .5);
  vertex(1, 0, -.5);
  vertex(.5, -(float)Math.sqrt(3)/2f, -.5);
  vertex(.5, -(float)Math.sqrt(3)/2f, .5);
  endShape(CLOSE);
  
  popMatrix();
}

//draws a trapezoid prism-- at 1 scale it will have 3 sides
//of length 1, and the bottom side of length 2
void trapPrism(float xScale, float yScale, float zScale)
{
  pushMatrix();
  scale(xScale, yScale, zScale);
  
  //front face
  beginShape();
  vertex(-.5, -.5, .5);
  vertex(-1, .5, .5);
  vertex(1, .5, .5);
  vertex(.5, -.5, .5);
  endShape(CLOSE);
  
  //back face
  beginShape();
  vertex(-.5, -.5, -.5);
  vertex(-1, .5, -.5);
  vertex(1, .5, -.5);
  vertex(.5, -.5, -.5);
  endShape(CLOSE);
  
  //top face
  beginShape();
  vertex(-.5, -.5, .5);
  vertex(.5, -.5, .5);
  vertex(.5, -.5, -.5);
  vertex(-.5, -.5, -.5);
  endShape(CLOSE);
  
  //left face
  beginShape();
  vertex(-.5, -.5, .5);
  vertex(-1, .5, .5);
  vertex(-1, .5, -.5);
  vertex(-.5, -.5, -.5);
  endShape(CLOSE);
  
  //bottom face
  beginShape();
  vertex(-1, .5, .5);
  vertex(1, .5, .5);
  vertex(1, .5, -.5);
  vertex(-1, .5, -.5);
  endShape(CLOSE);
  
  //right face
  beginShape();
  vertex(.5, -.5, .5);
  vertex(1, .5, .5);
  vertex(1, .5, -.5);
  vertex(.5, -.5, -.5);
  endShape(CLOSE);
  
  popMatrix();
}

//void octPrism(float xScale, float yScale, float zScale)
//{
//  pushMatrix();
//  scale(xScale, yScale, zScale);
  
//  popMatrix();
//}

void tireAndCasing()
{
  fill(TIRE_COLOR);
  
  //black tire tread
  pushMatrix();
  translate(0, 0, 0);
  rectPrism(10, 10, 26);
  popMatrix();
  
  //black tire (round part)
  pushMatrix();
  translate(5, 0, 13);
  rotate(PI / 2, 0, 0, 1);
  cylinder(5, 10, 20);
  popMatrix();
  
  fill(PRIMARY_COLOR);
  
  //white casing over tire
  pushMatrix();
  translate(0, -3, -2);
  rectPrism(13, 7, 30);
  popMatrix();
  
  //back of white casing
  pushMatrix();
  translate(6.5, 0, -12);
  rotate(PI/2, 0, 0, 1);
  cylinder(5, 13, 20);
  popMatrix();
  
  fill(SECONDARY_COLOR);
  
  //blue emblem on casing
  pushMatrix();
  translate(0, -7, 0);
  rotate(PI/2, 0, 1, 0);
  trapPrism(8, 2, 8);
  popMatrix();
}

void gun()
{
  
  fill(PRIMARY_COLOR);
  
  //main gun arm
  pushMatrix();
  translate(0, 0, 0);
  rectPrism(18, 4, 30);
  popMatrix();
  
  fill(SECONDARY_COLOR);
  
  //blue ramp from hex to gun
  pushMatrix();
  translate(0, -3, -10);
  rotate(-PI/10, 1, 0, 0);
  trapPrism(8, 4, 14);
  popMatrix();
  
  //blue decorations on left gun side
  pushMatrix();
  translate(-9, 0, 4);
  rotate(-PI/2, 0, 0, 1);
  trapPrism(3, 8, 20);
  popMatrix();
  
  //blue decorations on right gun side
  pushMatrix();
  translate(9, 0, 4);
  rotate(PI/2, 0, 0, 1);
  trapPrism(3, 8, 20);
  popMatrix();
  
  //black protrusion from end of gun
  fill(TIRE_COLOR);
  pushMatrix();
  translate(0, 0, 15);
  rectPrism(16, 2, 2);
  popMatrix();
}
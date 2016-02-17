// 3D Scene Example

import processing.opengl.*;

float time = 0;  // keep track of passing of time
final int CAMERA_DISTANCE = 120;

float xRotate = 0;
float yRotate = 0;
boolean mouseDown = false;

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
    xRotate = 0;
    yRotate = 0;
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
  lightSpecular (204, 204, 204);
  directionalLight (102, 102, 102, -0.7, -0.7, -1);
  directionalLight (152, 152, 152, 0, 0, -1);
  
  //rotate EVERYTHING by xRotate and yRotate, to allow for arbitrary-ish rotation by user
  pushMatrix();
  rotateDueToMouse();
  
  pushMatrix();
  translate(0, 10, 0);
  hexPrism(5, 5, 5);
  popMatrix();
  
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
  
  // Draw a sphere
  
  pushMatrix();
  
  ambient (50, 50, 50);
  specular (155, 155, 155);
  shininess (15.0);
  
  sphereDetail (40);
  sphere (5);

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

void tireAndCasing()
{
  //black tire tread
  pushMatrix();
  fill(120, 120, 120);
  translate(0, 0, 0);
  rectPrism(10, 10, 26);
  popMatrix();
  
  //black tire (round part)
  pushMatrix();
  translate(5, 0, 13);
  rotate(PI / 2, 0, 0, 1);
  fill(120, 120, 120);
  cylinder(5, 10, 20);
  popMatrix();
  
  //white casing over tire
  pushMatrix();
  fill(200, 200, 200);
  translate(0, -3, -2);
  rectPrism(13, 7, 30);
  popMatrix();
  
  //back of white casing
  pushMatrix();
  fill(200, 200, 200);
  translate(6, 0, -12);
  rotate(PI/2, 0, 0, 1);
  cylinder(5, 12, 20);
  popMatrix();
  
  //blue emblem on casing
  pushMatrix();
  fill(50, 50, 240);
  translate(0, -6, 5);
  rotate(-PI/16, 1, 0, 0);
  rectPrism(9, 2, 12);
  popMatrix();
}
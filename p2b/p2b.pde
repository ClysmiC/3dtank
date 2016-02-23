// 3D Siege Tank
// Author: Andrew Smith

import processing.opengl.*;

float lastFreeRotateTime = 0;
final int CAMERA_DISTANCE = 130;

float xRotate = -PI / 9;
float yRotate = PI / 6;
boolean mouseDown = false;

final int PRIMARY_COLOR = 0xFFB0B0B0;
final int SECONDARY_COLOR = 0xFF3232F0;
final int TIRE_COLOR = 0xFF222222;

//animation takes place in 3 stages
//stage 1: legs extend
//stage 2: side braces come down, gun rotates 180 degrees
//stage 3: legs turn and lift everything up, gun extends
//stage 4: lift gun angle

final int STAGE_1_DURATION = 500; //milliseconds
final int STAGE_2_DURATION = 1000; //milliseconds
final int STAGE_3_DURATION = 750; //milliseconds
final int STAGE_4_DURATION = 750; //milliseconds

PFont font;

int animStartTime;

//progress from 0-1
float animStage1;
float animStage2;
float animStage3;
float animStage4;

void setup() {
  size(700, 700, P3D);  // must use 3D here !!!
  noStroke();           // do not draw the edges of polygons
  
  font = createFont("Sans-Serif", 100);
  textFont(font);
  textSize(4);
  
  animStartTime = -1;
  animStage1 = 0;
  animStage2 = 0;
  animStage3 = 0;
  animStage4 = 0;
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
    xRotate = -PI/9;
    yRotate = PI/6;
  }
  else if (key == 'a')
  {
    animStartTime = millis();
  }
}

void rotateDueToMouse()
{
  if(mouseDown && millis() - lastFreeRotateTime >= 10)
  {
    //location of click where origin is center of screen
    int xLoc = mouseX - width / 2;
    int yLoc = -(mouseY - height / 2);
    
    yRotate += (xLoc / 5000f);
    xRotate += (yLoc / 5000f);
    
    lastFreeRotateTime = millis();
  }
  
  rotate(xRotate, 1, 0, 0);
  rotate(yRotate, 0, 1, 0);
}

void draw() {
  
  resetMatrix();  // set the transformation matrix to the identity (important!)

  background(0);  // clear the screen to black
  
  if(animStartTime == -1)
  {
    //animation hasn't started
    animStage1 = 0;
    animStage2 = 0;
    animStage3 = 0;
  }
  else
  {
    int elapsedTime = millis() - animStartTime;
    animStage1 = Math.min(1, (float)elapsedTime / STAGE_1_DURATION);
    animStage2 = Math.max(0, Math.min(1, ((float)elapsedTime - STAGE_1_DURATION) / STAGE_2_DURATION));
    animStage3 = Math.max(0, Math.min(1, ((float)elapsedTime - STAGE_1_DURATION - STAGE_2_DURATION) / STAGE_3_DURATION));
    animStage4 = Math.max(0, Math.min(1, ((float)elapsedTime - STAGE_1_DURATION - STAGE_2_DURATION - STAGE_3_DURATION) / STAGE_4_DURATION));
  }
  
  
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
  
    siegeTank();
  
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

/**
 * @param frOrBl - Whether or not the tire is on the front-right (fr) or back-left (bl) side of the tank.
 * The method needs to know this to rotate the tire properly
 */
void tireAndCasing(boolean frOrBl)
{
  final int EXTEND_DISTANCE = 6; //stage 1
  final int SHIFT_DISTANCE = 4; //stage 3
  final float ROTATE_SIDE = frOrBl ? -PI / 10 : PI / 10; //stage 3
  final float ROTATE_DOWN = -PI / 16; //stage 3
  
  fill(TIRE_COLOR);
  
  pushMatrix();
  
    translate(animStage3 * SHIFT_DISTANCE, 0, animStage1 * EXTEND_DISTANCE);
    rotate(animStage3 * ROTATE_SIDE, 0, 1, 0);
    rotate(animStage3 * ROTATE_DOWN, 1, 0, 0);
    
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
    
  popMatrix();
}

void gun()
{
  fill(PRIMARY_COLOR);
  
  final float GUN_ROTATION = -PI; //stage2
  final int DECORATION_EXTEND_DISTANCE = 10; //stage2
  final float GUN_LIFT = PI / 12; //stage4
  
  
  pushMatrix();
    rotate(animStage2 * GUN_ROTATION, 0, 1, 0);
    
    //hex prism sitting on top to shoot the gun
    pushMatrix();
      translate(0, 0, 0);
      rotate(PI/2, 1, 0, 0);
      hexPrism(20, 20, 15);
    popMatrix();
    
    fill(SECONDARY_COLOR);
    
    //blue emblem on top
    pushMatrix();
      translate(0, -8, 0);
      trapPrism(10, 2, 15);
    popMatrix();
    
    fill(PRIMARY_COLOR);
    
    pushMatrix();
      rotate(animStage4 * GUN_LIFT, 1, 0, 0);
      
      //main gun arm
      pushMatrix();
        translate(0, -2, 28);
        rectPrism(18, 4, 34);
      popMatrix();
      
      fill(SECONDARY_COLOR);
      
      //blue ramp from hex to gun
      pushMatrix();
        translate(0, -5, 20);
        rotate(-PI/16, 1, 0, 0);
        trapPrism(8, 4, 14);
      popMatrix();
      
      //blue decorations on left gun side
      pushMatrix();
        translate(-9, -2, 34 + animStage3 * DECORATION_EXTEND_DISTANCE);
        rotate(-PI/2, 0, 0, 1);
        trapPrism(3, 8, 20);
      popMatrix();
      
      //blue decorations on right gun side
      pushMatrix();
        translate(9, -2, 34 + animStage3 * DECORATION_EXTEND_DISTANCE);
        rotate(PI/2, 0, 0, 1);
        trapPrism(3, 8, 20);
      popMatrix();
      
      fill(TIRE_COLOR);
      
      //black protrusion from end of gun
      pushMatrix();
        translate(0, -2, 41 + animStage3 * DECORATION_EXTEND_DISTANCE * .5);
        rectPrism(16, 2, 10);
      popMatrix();
    
    popMatrix();
  
  popMatrix();
}

void siegeTank()
{
  //front right tire
  pushMatrix();
    translate(-20, 0, 30);
    tireAndCasing(true);
  popMatrix();
  
  //front left tire
  pushMatrix();
    translate(20, 0, 30);
    tireAndCasing(false);
  popMatrix();
  
  //back right tire
  pushMatrix();
    translate(-20, 0, -30);
    rotate(PI, 0, 1, 0);
    tireAndCasing(false);
  popMatrix();
  
  //back left tire
  pushMatrix();
    translate(20, 0, -30);
    rotate(PI, 0, 1, 0);
    tireAndCasing(true);
  popMatrix();
  
  final int LIFT_DISTANCE = -4; //stage 3
  pushMatrix();
    translate(0, animStage3 * LIFT_DISTANCE, 0);
    
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
    
    pushMatrix();
      translate(0, -18, 0);
      gun();
    popMatrix();
  
  popMatrix();
}
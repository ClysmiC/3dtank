// 3D Siege Tank
// Author: Andrew Smith

import processing.opengl.*;

PImage titleImage;

float lastFreeRotateTime = 0;
final int CAMERA_DISTANCE = 150;

float xRotate = -PI / 9;
float yRotate = PI / 6;
boolean mouseDown = false;
boolean animForward = true;

final int PRIMARY_COLOR = 0xFFB0B0B0;
final int SECONDARY_COLOR = 0xFF3232F0;
final int ENEMY_SECONDARY_COLOR = 0xFFF03232;
final int TIRE_COLOR = 0xFF222222;
final int BUNKER_COLOR = 0xFF2A2A2A;
final int FIRE_COLOR = 0x00FF8888;

/***ANIMATION DURATIONS (ms)***/
//camera movement, tank movement
final int START_DURATION = 0;
final int CAMERA_MOVE_DURATION = 4000;
final int CAMERA_MOVE_2_DURATION = 4000;
final int TANK_MOVE_DURATION = 4000;
final int TANK_ROTATE_DURATION = 1000;
final int CAMERA_MOVE_3_DURATION = 4000;

//4 stage siege mode deployment
final int STAGE_1_DURATION = 400;
final int STAGE_2_DURATION = 800;
final int STAGE_3_DURATION = 600;
final int STAGE_4_DURATION = 600;

//fire 3 volleys
final int FIRE_DURATION = 500;
final int FIRE_COOLDOWN_DURATION = 1500;

final int BUNKER_DESTROY_DURATION = 3000;

//4 stage siege mode un-deployment
final int STAGE_5_DURATION = STAGE_1_DURATION;
final int STAGE_6_DURATION = STAGE_2_DURATION;
final int STAGE_7_DURATION = STAGE_3_DURATION;
final int STAGE_8_DURATION = STAGE_4_DURATION;

final int TANK_ROTATE_AWAY_DURATION = TANK_ROTATE_DURATION;
final int TANK_MOVE_AWAY_DURATION =  (int)(1.5 * TANK_MOVE_DURATION);

final int CAMERA_RETURN_TO_START_DURATION = 5000;

int startTime;

//progress from 0-1
float animStart;
float animCameraMove;
float animCameraMove2;
float animTankMove;
float animTankRotate;
float animCameraMove3;
float animStage1;
float animStage2;
float animStage3;
float animStage4;
float animFire;
float animBunkerDestroy;
float animStage5;
float animStage6;
float animStage7;
float animStage8;
float animTankRotateAway;
float animTankMoveAway;
float animCameraReturnToStart;

boolean bunkerAlive;

void setup()
{
  size(700, 700, P3D);  // must use 3D here !!!
  noStroke();           // do not draw the edges of polygons
  
  titleImage = loadImage("title.jpg");
  
  if(titleImage == null)
  {
    System.out.println("Failed to load title image");
  }
  
  animForward = true;
  startTime = -1;
  animStart = 0;
  animCameraMove = 0;
  animCameraMove2 = 0;
  animTankMove = 0;
  animTankRotate = 0;
  animCameraMove3 = 0;
  animStage1 = 0;
  animStage2 = 0;
  animStage3 = 0;
  animStage4 = 0;
  animFire = 0;
  animBunkerDestroy = 0;
  animStage5 = 0;
  animStage6 = 0;
  animStage7 = 0;
  animStage8 = 0;
  animTankRotateAway = 0;
  animTankMoveAway = 0;
  animCameraReturnToStart = 0;
  
  bunkerAlive = true;
}

void keyPressed()
{
 //resets camera
 if (key == ' ')
 {
   startTime = millis();
   bunkerAlive = true;
 }
}

void draw() {
  
  resetMatrix();  // set the transformation matrix to the identity (important!)

  background(0);  // clear the screen to black
  
  if(startTime != -1)
  {
    int elapsedTime = millis() - startTime;
    
    if(!animForward)
    {
      elapsedTime = STAGE_1_DURATION + STAGE_2_DURATION + STAGE_3_DURATION + STAGE_4_DURATION - elapsedTime;
    }
    
    animStart = Math.max(0, Math.min(1, (float)elapsedTime / START_DURATION));
    animCameraMove = Math.max(0, Math.min(1, ((float)elapsedTime - START_DURATION) / CAMERA_MOVE_DURATION));
    animCameraMove2 = Math.max(0, Math.min(1, ((float)elapsedTime - START_DURATION - CAMERA_MOVE_DURATION) / CAMERA_MOVE_2_DURATION));
    animTankMove = Math.max(0, Math.min(1, ((float)elapsedTime - START_DURATION - CAMERA_MOVE_DURATION - CAMERA_MOVE_2_DURATION) / TANK_MOVE_DURATION));
    animCameraMove3 =  Math.max(0, Math.min(1, ((float)elapsedTime - START_DURATION - CAMERA_MOVE_DURATION - CAMERA_MOVE_DURATION - TANK_MOVE_DURATION) / CAMERA_MOVE_3_DURATION));
    animTankRotate =  Math.max(0, Math.min(1, ((float)elapsedTime - START_DURATION - CAMERA_MOVE_DURATION - CAMERA_MOVE_DURATION - TANK_MOVE_DURATION - CAMERA_MOVE_3_DURATION) / TANK_ROTATE_DURATION));
    
    int preSiegeDuration = START_DURATION + CAMERA_MOVE_DURATION + CAMERA_MOVE_2_DURATION + TANK_MOVE_DURATION + TANK_ROTATE_DURATION + CAMERA_MOVE_3_DURATION;
    animStage1 = Math.max(0, Math.min(1, ((float)elapsedTime - preSiegeDuration) / STAGE_1_DURATION));
    animStage2 = Math.max(0, Math.min(1, ((float)elapsedTime - preSiegeDuration - STAGE_1_DURATION) / STAGE_2_DURATION));
    animStage3 = Math.max(0, Math.min(1, ((float)elapsedTime - preSiegeDuration - STAGE_1_DURATION - STAGE_2_DURATION) / STAGE_3_DURATION));
    animStage4 = Math.max(0, Math.min(1, ((float)elapsedTime - preSiegeDuration - STAGE_1_DURATION - STAGE_2_DURATION - STAGE_3_DURATION) / STAGE_4_DURATION));
    
    int preFireDuration = preSiegeDuration + STAGE_1_DURATION + STAGE_2_DURATION + STAGE_3_DURATION + STAGE_4_DURATION;
    if(elapsedTime - preFireDuration <= FIRE_DURATION)
    {
      //fire!
      animFire = Math.max(0, ((float)elapsedTime - preFireDuration) / FIRE_DURATION);
    }
    else if(elapsedTime - preFireDuration <= FIRE_DURATION + FIRE_COOLDOWN_DURATION)
    {
      //cooldown
      animFire = 0;
    }
    else if(elapsedTime - preFireDuration <= 2 * FIRE_DURATION + FIRE_COOLDOWN_DURATION)
    {
      //fire!
      animFire = Math.max(0, ((float)elapsedTime - preFireDuration - FIRE_DURATION - FIRE_COOLDOWN_DURATION) / FIRE_DURATION);
    }
    else if(elapsedTime - preFireDuration <= 2 * FIRE_DURATION + 2 * FIRE_COOLDOWN_DURATION)
    {
      //cooldown
      animFire = 0;
    }
    else if(elapsedTime - preFireDuration <= 3 * FIRE_DURATION + 2 * FIRE_COOLDOWN_DURATION)
    {
      //fire!
      animFire = Math.max(0, ((float)elapsedTime - preFireDuration - 2 * FIRE_DURATION - 2 * FIRE_COOLDOWN_DURATION) / FIRE_DURATION);
    }
    else
    {
      animFire = 0;
    }
    
    int preUnsiegeDuration = preFireDuration + 3 * FIRE_DURATION + 2 * FIRE_COOLDOWN_DURATION;
    if(elapsedTime - preUnsiegeDuration < BUNKER_DESTROY_DURATION)
    {
      animBunkerDestroy = Math.max(0, Math.min(1, ((float)elapsedTime - preUnsiegeDuration) / BUNKER_DESTROY_DURATION)); 
    }
    else
    {
      animBunkerDestroy = 0;
    }
    
    animStage5 = Math.max(0, Math.min(1, ((float)elapsedTime - preUnsiegeDuration - BUNKER_DESTROY_DURATION) / STAGE_5_DURATION));
    animStage6 = Math.max(0, Math.min(1, ((float)elapsedTime - preUnsiegeDuration - BUNKER_DESTROY_DURATION - STAGE_5_DURATION) / STAGE_6_DURATION));
    animStage7 = Math.max(0, Math.min(1, ((float)elapsedTime - preUnsiegeDuration - BUNKER_DESTROY_DURATION - STAGE_5_DURATION - STAGE_6_DURATION) / STAGE_7_DURATION));
    animStage8 = Math.max(0, Math.min(1, ((float)elapsedTime - preUnsiegeDuration - BUNKER_DESTROY_DURATION - STAGE_5_DURATION - STAGE_6_DURATION - STAGE_7_DURATION) / STAGE_8_DURATION));
  
    int preMoveAwayDuration = preUnsiegeDuration + BUNKER_DESTROY_DURATION + STAGE_5_DURATION + STAGE_6_DURATION + STAGE_7_DURATION + STAGE_8_DURATION;
    animTankRotateAway = Math.max(0, Math.min(1, ((float)elapsedTime - preMoveAwayDuration) / TANK_ROTATE_AWAY_DURATION));
    animTankMoveAway = Math.max(0, Math.min(1, ((float)elapsedTime - preMoveAwayDuration - TANK_ROTATE_AWAY_DURATION) / TANK_MOVE_AWAY_DURATION));
    
    animCameraReturnToStart = Math.max(0, Math.min(1, ((float)elapsedTime - preMoveAwayDuration - TANK_ROTATE_AWAY_DURATION - TANK_MOVE_AWAY_DURATION) / CAMERA_RETURN_TO_START_DURATION));
  }
  
  
  // set up for perspective projection
  perspective (PI * 0.333, 1.0, 0.01, 1500.0);
  
  
  float cameraTilt = (animFire <= .5) ? animFire : 1 - animFire;
  PVector tiltVector = PVector.random3D();
  
  // place the camera in the scene (just like gluLookAt())
  camera (
    //eye
    0 - 100 * animCameraMove + 300 * animCameraMove2 - 700 * animCameraMove3 + 500 * animCameraReturnToStart,
    -100 + 50 * animCameraMove - 20 * animCameraMove2 - 30 * animCameraReturnToStart,
    -200 + 100 * animCameraMove - 100 * animCameraMove2 + 350 * animCameraMove3 - 350 * animCameraReturnToStart,
    
    //target
    0 + 100 * animCameraMove2 - 100 * animCameraReturnToStart,
    -100 + 50 * animCameraMove - 50 * animCameraReturnToStart, 
    -500 + 500 * animCameraMove + 100 * animCameraMove3 - 600 * animCameraReturnToStart,
    
    //up
    .1 * cameraTilt * tiltVector.x, .1 * cameraTilt * tiltVector.y + 1.0, .1 * cameraTilt * tiltVector.z);
  
  pushMatrix();
  beginShape();
  texture(titleImage);
  vertex(-50, -75, -300, 0, 400);
  vertex(50, -75, -300, 800, 400);
  vertex(50, -125, -300, 800, 0);
  vertex(-50, -125, -300, 0, 0);
  //rectPrism(40, 40, 1);
  endShape();
  popMatrix();
  
  //image(titleImage, width/2, height/2);
  
  // create an ambient light source
  ambientLight (102, 102, 102);
  
  // create two directional light sources
  lightSpecular (150, 150, 150);
  directionalLight (102, 102, 102, 1, 0.7, -.2);
  directionalLight (102, 102, 102, -1, 0.7, -.2);
  
  pushMatrix();
    
    //ground
    fill(0xFF00FF00); //green
    pushMatrix();
      translate(0, 1, 0);
      rectPrism(2000, 2, 2000);
    popMatrix();
    
    //sky (note: camera is "inside" sky-box)
    fill(0xFF4444FF);
    sphere(700);
    
    pushMatrix();
      translate(-300, -5, 500 - 300 * animTankMove - 1.5 * 300 * animTankMoveAway);
      rotate(PI + 6 * PI / 10 * animTankRotate - 6 * PI / 10 * animTankRotateAway, 0, 1, 0);
      siegeTank();
    popMatrix();
    
    pushMatrix();
      translate(-220, -5, 550 - 300 * animTankMove - 1.5 * 300 * animTankMoveAway);
      rotate(PI + 6 * PI / 10 * animTankRotate - 6 * PI / 10 * animTankRotateAway, 0, 1, 0);
      siegeTank();
    popMatrix();
    
    pushMatrix();
      translate(-170, -5, 480 - 300 * animTankMove - 1.5 * 300 * animTankMoveAway);
      rotate(PI + 6 * PI / 10 * animTankRotate - 6 * PI / 10 * animTankRotateAway, 0, 1, 0);
      siegeTank();
    popMatrix();
    
    if(bunkerAlive)
    {
      pushMatrix();
        translate(100, -10, 100);
        bunker();
      popMatrix();
    }
    
    if(animBunkerDestroy > 0)
    {
      //draw explosion
      bunkerAlive = false;
      
      final float FIRE_MIN_RADIUS = 50;
      final float FIRE_MAX_RADIUS = 100;
      
      pushMatrix();
        int alpha = 255 - (int)(.5 * 255 * animBunkerDestroy);
        translate(100, -10, 100);
        fill((alpha << 24) | FIRE_COLOR);
        sphere(animBunkerDestroy == 0 ? 0 : FIRE_MIN_RADIUS + animBunkerDestroy * (FIRE_MAX_RADIUS - FIRE_MIN_RADIUS));
      popMatrix();
    }
  
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
  final int SHIFT_DISTANCE = frOrBl ? -1 : 1; //stage 3
  final float ROTATE_SIDE = frOrBl ? -PI / 10 : PI / 10; //stage 3
  final float ROTATE_DOWN = -PI / 16; //stage 3
  
  fill(TIRE_COLOR);
  
  pushMatrix();
  
    translate(animStage3 * SHIFT_DISTANCE, 0, animStage1 * EXTEND_DISTANCE - animStage8 * EXTEND_DISTANCE);
    rotate(animStage3 * ROTATE_SIDE - animStage6 * ROTATE_SIDE, 0, 1, 0);
    rotate(animStage3 * ROTATE_DOWN - animStage6 * ROTATE_DOWN, 1, 0, 0);
    
    //black tire tread
    pushMatrix();
      translate(0, 0, -3);
      rectPrism(10, 10, 32);
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
      translate(0, -3, -5);
      rectPrism(13, 7, 36);
    popMatrix();
    
    //back of white casing
    pushMatrix();
      translate(6.5, 0, -18);
      rotate(PI/2, 0, 0, 1);
      cylinder(5, 13, 20);
    popMatrix();
    
    fill(SECONDARY_COLOR);
    
    //blue emblem on casing
    pushMatrix();
      translate(0, -7, -3);
      rotate(PI/2, 0, 1, 0);
      trapPrism(8, 2, 8);
    popMatrix();
    
  popMatrix();
}

//braces that slide into place when entering siege mode
//note: this method draws a brace oriented vertically-- the calling location should rotate it as desired
void brace()
{ 
    int UNLOAD_DISTANCE = 16; //stage2
    int UNLOAD_SHIFT_DOWN = 4; //stage3
    float UNLOAD_ANGLE = PI/4; //stage3
    
    fill(TIRE_COLOR);
    pushMatrix();
      translate(-UNLOAD_SHIFT_DOWN * animStage3 + UNLOAD_SHIFT_DOWN * animStage6, -UNLOAD_DISTANCE * animStage2 + UNLOAD_DISTANCE * animStage7, 0);

      //3-part arm
      pushMatrix();
        translate(0, 15, 0);
        rectPrism(3, 30, 10);
      popMatrix();
      
      pushMatrix();
        rotate(UNLOAD_ANGLE, 0, 0, 1);
        rotate(-UNLOAD_ANGLE * animStage3 + UNLOAD_ANGLE * animStage3, 0, 0, 1);
        pushMatrix();
          translate(-2, -3, 0);
          rotate(-PI/6, 0, 0, 1);
          rectPrism(3, 9, 10);
        popMatrix();
        
        pushMatrix();
          translate(-7, -6, 0);
          rectPrism(8, 3, 10);
        popMatrix();
        //end 3-part arm
        
        //trapezoid base
        pushMatrix();
          translate(-10, -6.5, 0);
          rotate(PI/2, 0, 1, 0);
          trapPrism(10, 8, 3);
        popMatrix();
      popMatrix();
    popMatrix();
}

void gun()
{
  fill(PRIMARY_COLOR);
  
  final float GUN_ROTATION = -PI; //stage2
  final int DECORATION_EXTEND_DISTANCE = 10; //stage2
  final float GUN_LIFT = PI / 12; //stage4
  final float FIRE_MIN_RADIUS = 2;
  final float FIRE_MAX_RADIUS = 15;
  
  pushMatrix();
    rotate(animStage2 * GUN_ROTATION - animStage7 * GUN_ROTATION, 0, 1, 0);
    
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
      rotate(animStage4 * GUN_LIFT - animStage5 * GUN_LIFT, 1, 0, 0);
      
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
        translate(-9, -2, 34 + animStage3 * DECORATION_EXTEND_DISTANCE - animStage6 * DECORATION_EXTEND_DISTANCE);
        rotate(-PI/2, 0, 0, 1);
        trapPrism(3, 8, 20);
      popMatrix();
      
      //blue decorations on right gun side
      pushMatrix();
        translate(9, -2, 34 + animStage3 * DECORATION_EXTEND_DISTANCE - animStage6 * DECORATION_EXTEND_DISTANCE);
        rotate(PI/2, 0, 0, 1);
        trapPrism(3, 8, 20);
      popMatrix();
      
      fill(TIRE_COLOR);
      
      //black protrusion from end of gun
      pushMatrix();
        translate(0, -2, 41);
        rectPrism(16, 2, 10);
      popMatrix();

      int alpha = 255 - (int)(.5 * 255 * animFire);
      
      //fire sphere  
      pushMatrix();
        translate(0, -2, 58);
        fill((alpha << 24) | FIRE_COLOR);
        sphere(animFire == 0 ? 0 : FIRE_MIN_RADIUS + animFire * (FIRE_MAX_RADIUS - FIRE_MIN_RADIUS));
      popMatrix();
    
    popMatrix();
  
  popMatrix();
}

void bunker()
{
  fill(BUNKER_COLOR);
  pushMatrix();
  
     rectPrism(70, 20, 70);
    
    //ramps
    pushMatrix();
      translate(-20, 0, 0);
      trapPrism(30, 20, 40);
    popMatrix();
    pushMatrix();
      translate(20, 0, 0);
      trapPrism(30, 20, 40);
    popMatrix();
    pushMatrix();
      translate(0, 0, -20);
      rotate(PI/2, 0, 1, 0);
      trapPrism(30, 20, 40);
    popMatrix();
    pushMatrix();
      translate(0, 0, 20);
      rotate(PI/2, 0, 1, 0);
      trapPrism(30, 20, 40);
    popMatrix();
    
    //red emblems
    fill(ENEMY_SECONDARY_COLOR);
    pushMatrix();
      translate(-32, 0, -32);
      rectPrism(10, 23, 10);
    popMatrix();
    pushMatrix();
      translate(32, 0, -32);
      rectPrism(10, 23, 10);
    popMatrix();
    pushMatrix();
      translate(32, 0, 32);
      rectPrism(10, 23, 10);
    popMatrix();
    pushMatrix();
      translate(-32, 0, 32);
      rectPrism(10, 23, 10);
    popMatrix();
  
  
    fill(BUNKER_COLOR);
   //round top
   pushMatrix();
     translate(0, 0, 0);
     sphere(30);
   popMatrix();
  
  popMatrix();
}

void siegeTank()
{
  int SHIFT_UP_DISTANCE = -3; //prevents rotated tires from clipping into ground
  pushMatrix();
    translate(0, animStage3 * SHIFT_UP_DISTANCE - animStage6 * SHIFT_UP_DISTANCE, 0);
    
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
      translate(0, animStage3 * LIFT_DISTANCE - animStage6 * LIFT_DISTANCE, 0);
      
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
      
      //right brace
      pushMatrix();
        translate(-10, -2 - animStage3 * 1 + animStage6 * 1, 0);
        rotate(-PI/2, 0, 0, 1);
        brace();
      popMatrix();
      
      //left brace
      pushMatrix();
        translate(10, -2 - animStage3 * 1 + animStage6 * 1, 0);
        rotate(PI/2, 0, 0, 1);
        rotate(PI, 0, 1, 0);
        brace();
      popMatrix();
      
      pushMatrix();
        translate(0, -18, 0);
        gun();
      popMatrix();
    popMatrix();
  popMatrix();
}
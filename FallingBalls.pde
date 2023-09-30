//classes

class BallType{
  public
  Vec2 pos;
  float radius = 10;
  Vec2 vel;
  float mass;
  
  BallType(Vec2 pos, Vec2 vel) {
    this.pos = pos;
    this.vel = vel;
  }
};

class CircleType {
  public
  Vec2 pos;
  float radius;
  int special = 0;
  
  CircleType(Vec2 pos, float r) {
    this.pos = pos;
    this.radius = r;
  }
};

class RecType {
  public
  Vec2 pos;
  float h;
  float w;
  Vec2 ul;
  Vec2 ur;
  Vec2 ll;
  Vec2 lr;
  float area;
  
  RecType(Vec2 pos, float h, float w) {
    this.pos = pos;
    this.h = h;
    this.w = w;
    this.area = w * h;
  }
};

class LineType {
  public
  Vec2 v1;
  Vec2 v2;
  
  LineType(Vec2 v1, Vec2 v2) {
    this.v1 = v1;
    this.v2 = v2;
  }
  
  Vec2 getNormal(){
    float dx = v2.x - v1.x;
    float dy = v2.y - v1.y;
    Vec2 normal = new Vec2(-dy, dx);
    return normal;
  }
};







//global variables

static int numParticles = 5;
static int numCircles = 9;
static int numRecs = 3;
static int numLines = 9;
int numCollisions = 0;
float gravity = 100;
float cor = 0.95f;

BallType balls[] = new BallType[numParticles];
CircleType circles[] =  new CircleType[numCircles];
RecType recs[] = new RecType[numRecs];
LineType lines[] = new LineType[numLines];


//functions
boolean ballCircleCollision(BallType object1, CircleType object2) {
    if (object1.pos.distanceTo(object2.pos) <= object1.radius + object2.radius) {
        return true;
    }
    return false;
}

boolean pointLineCollision(Vec2 p, LineType l) {
    float len = l.v1.distanceTo(l.v2);
    float d1 = p.distanceTo(l.v1);
    float d2 = p.distanceTo(l.v2);
    if (d1 + d2 >= len - 0.01 && d1 + d2 <= len + 0.01) {
        return true;
    }
    return false;
}

boolean lineBallCollision(LineType line, BallType circle) { //https://www.jeffreythompson.org/collision-detection/line-circle.php
    if (line.v1.distanceTo(circle.pos) < circle.radius || line.v2.distanceTo(circle.pos) < circle.radius) { //check if line exists within circle
        return true;
    }
    float len = line.v1.distanceTo(line.v2);
    float t = (((circle.pos.x - line.v1.x) * (line.v2.x - line.v1.x)) + ((circle.pos.y - line.v1.y) * (line.v2.y - line.v1.y))) / pow(len, 2);
    Vec2 nearestPoint = new Vec2(line.v1.x + (t * (line.v2.x - line.v1.x)), line.v1.y + (t * (line.v2.y - line.v1.y)));
    if (nearestPoint.distanceTo(circle.pos) < circle.radius && pointLineCollision(nearestPoint, line)) {
        return true;
    }
    return false;
}

float clamp(float value, float min, float max) {
    if (value < min) {
        return min;
    }
    else if (value > max) {
        return max;
    }
    else {
        return value;
    }
}

boolean circleRectangleCollision(BallType circle, RecType rectangle) {
    Vec2 closest = new Vec2(clamp(circle.pos.x, rectangle.pos.x - rectangle.w / 2, rectangle.pos.x + rectangle.w / 2), clamp(circle.pos.y, rectangle.pos.y - rectangle.h / 2, rectangle.pos.y + rectangle.h / 2));
    if (closest.distanceTo(circle.pos) <= circle.radius) {
        return true;
    }
    return false;
}






//setup

void setup(){
  size(800,800);
  surface.setTitle("Pinball");
  
  for (int i = 0; i < numParticles; i++){  //initalize balls with random position and velocity
    balls[i] = new BallType(new Vec2(700+random(80),700+random(80)), new Vec2(random(40),-520+random(20)));
    balls[i].mass = 5;
  }
  
  //build lines
  lines[0] = new LineType(new Vec2(0.0f, 0.0f), new Vec2(0.0f, 800.0f));
  lines[1] = new LineType(new Vec2(0.0f, 0.0f), new Vec2(800.0f, 0.0f));
  lines[2] = new LineType(new Vec2(800.0f, 800.0f), new Vec2(800.0f, 00.0f));
  lines[3] = new LineType(new Vec2(700.0f, 800.0f), new Vec2(700.0f, 150.0f));
  lines[4] = new LineType(new Vec2(700.0f, 800.0f), new Vec2(800.0f, 800.0f));
  lines[5] = new LineType(new Vec2(800.0f, 100.0f), new Vec2(700.0f, 0.0f));
  
  //build triangle
  lines[6] = new LineType(new Vec2(200.0f, 200.0f), new Vec2(300.0f, 300.0f));
  lines[7] = new LineType(new Vec2(200.0f, 200.0f), new Vec2(200.0f, 300.0f));
  lines[8] = new LineType(new Vec2(300.0f, 300.0f), new Vec2(200.0f, 300.0f));
  
  for(int i = 0; i < 4; i++){ //circles layer 1
    circles[i] = new CircleType(new Vec2(150 * (i+1), 400), 20);
  }
  
  for(int i = 4; i < 8; i++){ //circles layer 2
    circles[i] = new CircleType(new Vec2(150 * (i -3), 600), 20);
  }
  
  circles[8] = new CircleType(new Vec2(400, 200), 15);
  circles[8].special = 1;
  strokeWeight(2); //Draw thicker lines 
}







//update

void update(float dt){
  for (int i = 0; i <  numParticles; i++){
    balls[i].vel.y += gravity * dt;          //move ball
    balls[i].pos.add(balls[i].vel.times(dt));  //move ball
    
    for(int j = 0; j < numLines; j++){  //collision with lines and polygons
      if(lineBallCollision(lines[j], balls[i])){
        Vec2 closest;
        Vec2 dir = lines[j].v2.minus(lines[j].v1);
        Vec2 dir_norm = dir.normalized();
        float proj = dot(balls[i].pos.minus(lines[j].v1), dir_norm);
        if(proj < 0){
          closest = lines[j].v1;
        }
        else if(proj > dir.length()){
          closest = lines[j].v2;
        }
        else{
          closest = lines[j].v1.plus(dir_norm.times(proj));
        }
        dir = balls[i].pos.minus(closest);
        float dist = dir.length();
        if(dist > balls[i].radius){
          return;
        }
        dir.mul(1/dist);
        balls[i].pos = closest.plus(dir.times(balls[i].radius));
        Vec2 v = balls[i].vel;
        Vec2 n = dir;
        balls[i].vel = v.minus( n.times(.7).times(dot(v, n)).times(2));
      }
    }
    
    for(int j = 0; j < numCircles; j++){ //collision with circles
      Vec2 delta = balls[i].pos.minus(circles[j].pos);
      float dist = sqrt(delta.x * delta.x + delta.y * delta.y);
      
      if(dist < balls[i].radius + circles[j].radius){
        float overlap = balls[i].radius + circles[j].radius - dist;

        Vec2 normalizedDelta = delta.normalized();
      
        Vec2 adj = normalizedDelta.times(overlap);
      
        Vec2 adj2 = balls[i].pos.plus(adj);
        balls[i].pos = adj2;
      
        float dP = dot(balls[i].vel, normalizedDelta);
        Vec2 refVec = normalizedDelta.times(2 * dP);
        if(circles[j].special == 1){
          balls[i].vel = balls[i].vel.minus(refVec).times(2);
          circles[j].pos = new Vec2(random(700), random(700));
        }
        else{
          balls[i].vel = balls[i].vel.minus(refVec).times(0.7);
        }
      }
    }
    
    for (int j = i + 1; j < numParticles; j++){
      Vec2 delta = balls[i].pos.minus(balls[j].pos);
      float dist = delta.length();
      if (dist < balls[i].radius + balls[i].radius){
        // Move balls out of collision
        float overlap = 0.5f * (dist - balls[i].radius - balls[j].radius);
        balls[i].pos.subtract(delta.normalized().times(overlap));
        balls[j].pos.add(delta.normalized().times(overlap));


        // Collision
        Vec2 dir = delta.normalized();
        float v1 = dot(balls[i].vel, dir);
        float v2 = dot(balls[j].vel, dir);
        float m1 = balls[i].mass;
        float m2 = balls[j].mass;
        // Pseudo-code for collision response
        float new_v1 = (m1 * v1 + m2 * v2 - m2 * (v1 - v2) * cor) / (m1 + m2);
        float new_v2 = (m1 * v1 + m2 * v2 - m1 * (v2 - v1) * cor) / (m1 + m2);
        balls[i].vel.add((dir.times(new_v1 - v1)));
        balls[j].vel.add((dir.times(new_v2 - v2)));
      }
    }
    
    
    
    
  }
}


//draw

void draw(){
  update(1.0/frameRate);
  
  background(255); //White background
  stroke(0,0,0);
  fill(10,120,10);
  for (int i = 0; i < numParticles; i++){
    circle(balls[i].pos.x, balls[i].pos.y, balls[i].radius * 2); 
  }
  
  for(int i = 0; i < numLines; i++){
    line(lines[i].v1.x, lines[i].v1.y, lines[i].v2.x, lines[i].v2.y);
  }
    
  //for(int i = 0; i < numRecs; i++){
  //}
  fill(120,10,10);
  for(int i = 0; i < numCircles -1; i++){
    circle(circles[i].pos.x, circles[i].pos.y, circles[i].radius * 2);
  }
  
  fill(10,10,120);
  circle(circles[8].pos.x, circles[8].pos.y, circles[8].radius * 2);
  
}

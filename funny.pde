float dashTimer, SPEED = 7.5, DASH_SPEED = 20, DASH_COOLDOWN = 30;
int pisstime, hp;
boolean isDashing, keys[] = new boolean[2000], piss;
PVector position = new PVector(300, 300), dashDirection;
PShape playerShape;
PGraphics vingette, scanlines, noiseOverlay;
ArrayList<plabull> plabullets = new ArrayList<plabull>();

void keyPressed() {
  keys[keyCode] = true;
}

void keyReleased() {
  keys[keyCode] = false;
}

void mousePressed() {
  piss = true;
}

void mouseReleased() {
  piss = false;
}

void setup() {
  fullScreen();
  frameRate(60);
  innit();
  hp = 100;
  position = new PVector(300, 300);
}

void draw() {
  background(0);
  if (hp >= 1) {
    player();
    for (plabull b : plabullets) b.display();
    plabullets.removeIf(b -> b.isDead());
    postpenis();
  }
}

class plabull {
  PVector pos, vel;
  float lifespan = 60;
  plabull(PVector startPos, PVector direction) {
    pos = startPos.copy();
    vel = direction.copy().setMag(10);
  }
  void display() {
    pos.add(vel);
    lifespan--;
    fill(0, 255, 255);
    noStroke();
    ellipse(pos.x, pos.y, 10, 10);
  }
  boolean isDead() {
    return lifespan <= 0 || pos.x < 0 || pos.x > width || pos.y < 0 || pos.y > height;
  }
}

void postpenis() {
  image(scanlines, 0, 0);
  blendMode(MULTIPLY);
  image(vingette, 0, 0);
  blendMode(BLEND);
  if (frameCount % 10 == 0) updateNoiseOverlay();
  tint(255,25);
  image(noiseOverlay, 0, 0);
  noTint();
  println(frameRate);
}


 
void updateNoiseOverlay() {
  noiseOverlay.beginDraw();
  noiseOverlay.loadPixels();
  for (int i = 0; i < noiseOverlay.pixels.length; i++) noiseOverlay.pixels[i] = color(random(10),random(10),random(10));
  noiseOverlay.updatePixels();
  noiseOverlay.endDraw();
}

void innit() {
  playerShape = createShape();
  playerShape.beginShape(LINES);
  playerShape.stroke(255, 0, 0);
  int[] pts = {50, 10, 0, 50, 50, 10, 0, 10, 50, -10, 0, -10, 50, -10, 0, -50};
  for (int i = 0; i < pts.length; i += 2) {
    playerShape.vertex(pts[i], pts[i+1]);
  }
  playerShape.endShape();

  vingette = createGraphics(width, height);
  vingette.beginDraw();
  vingette.loadPixels();
  for (int y = 0; y < vingette.height; y++) for (int x = 0; x < vingette.width; x++) {
    float dx = x - width / 2;
    float dy = y - height / 2;
    float d = sqrt(dx * dx + dy * dy);
    float maxD = sqrt(sq(width / 2) + sq(height / 2));
    float alpha = map(d, 0, maxD, 0, 200);
    vingette.pixels[y * width + x] = color(0, alpha);
  }
  vingette.updatePixels();
  vingette.endDraw();


  scanlines = createGraphics(width, height);
  scanlines.beginDraw();
  scanlines.clear();
  scanlines.stroke(50, 100);
  scanlines.strokeWeight(5);
  for (int y = 0; y < height; y += 3) {
    scanlines.line(0, y, width, y);
  }
  scanlines.endDraw();
  noiseOverlay = createGraphics(width, height);
  noiseOverlay.beginDraw();
  noiseOverlay.loadPixels();
  for (int i = 0; i < noiseOverlay.pixels.length; i++) noiseOverlay.pixels[i] = color(random(10));
  noiseOverlay.updatePixels();
  noiseOverlay.endDraw();
}

void player() {
  PVector move = new PVector((keys['D'] ? 1 : 0) - (keys['A'] ? 1 : 0), (keys['S'] ? 1 : 0) - (keys['W'] ? 1 : 0));
  if (!isDashing && move.magSq() > 0) {
    move.setMag(SPEED);
    position.add(move);
    if (keys[32] && dashTimer <= 0) {
      dashDirection = move.copy().setMag(DASH_SPEED);
      isDashing = true;
      dashTimer = DASH_COOLDOWN;
    }
  } else if (isDashing) {
    position.add(dashDirection);
  }
  isDashing = dashTimer > DASH_COOLDOWN - 10;
  position.x = constrain(position.x, 0, width);
  position.y = constrain(position.y, 0, height);
  dashTimer = max(0, dashTimer - 1);

  pushMatrix();
  translate(position.x, position.y);
  rotate(atan2(mouseY - position.y, mouseX - position.x));
  shape(playerShape);
  noFill();
  stroke(0, 255, 0);
  circle(0, 0, 30);
  popMatrix();

  // Shooting plabullets
  PVector aimDir = new PVector(mouseX - position.x, mouseY - position.y);
  if (piss && (millis() - pisstime) > 100) {
    plabullets.add(new plabull(position, aimDir));
    pisstime = millis();
  }
}

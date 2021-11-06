/* 
 * Copyright (c) 2021 Fredrick Brennan
 * Copyright (c) 2010 Karsten Schmidt
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
 
import toxi.geom.*;
import toxi.math.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import toxi.physics2d.constraints.*;
import geomerative.*;
import java.util.*;

int WIDTH  = 1920;
int HEIGHT = 980;
float DEFAULT_REPULSION = 80.f;
float DEFAULT_REPEL_FORCE = -1.2f;

VerletPhysics2D physics;
AttractionBehavior2D mouseAttractor;

int SVGlength = 0;
ArrayList<VerletParticle2D> mps = new ArrayList<VerletParticle2D>();
PShape internal1;
PShape internal2;
RPoint[] points;
RShape arrow;
RPoint[] arrow_points;
String NUMHOME="../../numbers.ufo/glyphs/";
PShape[] pnumbers;
ArrayList<String> glyphs_array = new ArrayList<String>();
String glyph;

public void settings() {
  size(WIDTH, HEIGHT, P3D);
}

void drawSVG(String filename, float radius, float strength) {
  RShape glyph = RG.loadShape(filename);
  RShape path = RG.polygonize(glyph);
  points = path.getPoints();
  SVGlength += points.length/2;
  VerletParticle2D last_pa = null;
  for (int i = 0; i < points.length; i++) {
    if (i % 2 != 0) {continue;}
    RPoint rp = points[i];
    PVector p = new PVector(rp.x, rp.y);
    VerletParticle2D pa = new VerletParticle2D(WIDTH / 3 + p.x, p.y + (HEIGHT / 2));
    for (VerletParticle2D vp2d : mps) {
      if (vp2d.distanceTo(pa) < 200 || true) {
        addParticle(pa, true, radius, strength);
        break;
      }
    }
  }
}

void drawSVG(String filename) {
  drawSVG(filename, DEFAULT_REPULSION, DEFAULT_REPEL_FORCE);
}

void drawSVG(String filename, float radius) {
  drawSVG(filename, radius, DEFAULT_REPEL_FORCE);
}

void setup() {
  RG.init(this);
  pnumbers = new PShape[]{loadShape(NUMHOME+"/__combstroke0_cairo.svg"), loadShape(NUMHOME+"/__combstroke1_cairo.svg"), loadShape(NUMHOME+"/__combstroke2_cairo.svg"), loadShape(NUMHOME+"/__combstroke3_cairo.svg"), loadShape(NUMHOME+"/__combstroke4_cairo.svg"), loadShape(NUMHOME+"/__combstroke5_cairo.svg"), loadShape(NUMHOME+"/__combstroke6_cairo.svg"), loadShape(NUMHOME+"/__combstroke7_cairo.svg"), loadShape(NUMHOME+"/__combstroke8_cairo.svg"), loadShape(NUMHOME+"/__combstroke9_cairo.svg")};

  String[] lines = loadStrings("glyphs.txt");
  glyphs_array = new ArrayList(Arrays.asList(lines));

  nextGlyph();
}

void outputGlyph() {
  char[] outglyph_c = glyph.toCharArray();
  String outglyph = "";
  for (int i = 0; i < outglyph_c.length; i++) {
    if (i != 0 && outglyph_c[i] == '_' && outglyph_c[i-1] >= 'A' && outglyph_c[i-1] <= 'Z') {
      continue;
    } else {
      outglyph += outglyph_c[i];
    }
  }
  int i = 0;
  for (VerletParticle2D p : mps) {
    i++;
    println(outglyph + "\t" + (int)(p.x - (WIDTH/3)) + "\t" + -(int)(p.y - (HEIGHT/2)) + "\tstroke" + i);
  }
}

boolean nextGlyph() {
  physics = new VerletPhysics2D();
  physics.setDrag(0.04f);
  physics.setWorldBounds(new Rect(0, 0, WIDTH, HEIGHT*1.5));
  mps = new ArrayList<VerletParticle2D>();

  String SVGHOMEUFO = "physics_SVGs/";
  String SVGHOME = "../physics_SVGs/";
  if (glyphs_array.size() == 0) { return false; }
  glyph = glyphs_array.remove(0);
  arrow = RG.loadShape(SVGHOMEUFO+glyph+"_arrows_internal.svg");
  arrow_points = arrow.getPoints();
  addMovingParticles();
  drawSVG(SVGHOMEUFO+glyph+".svg");
  drawSVG(SVGHOMEUFO+glyph+"_arrows.svg");
  internal1 = loadShape(SVGHOME+glyph+"_internal.svg");
  internal1.disableStyle();
  internal2 = loadShape(SVGHOMEUFO+glyph+"_arrows_internal.svg");
  internal2.disableStyle();
  return true;
}

void addMovingParticles() {
  int i = 0;
  for (RPoint[] rpoints : arrow.getPointsInPaths()) {
    Vec2D pv = new Vec2D(rpoints[0].x, rpoints[0].y);
    Vec2D pv2 = new Vec2D(rpoints[1].x, rpoints[1].y);
    Vec2D pv3 = pv.interpolateTo(pv2, -2.0);
    VerletParticle2D arrow_begin = new VerletParticle2D(WIDTH / 3 + pv.x, pv.y + (HEIGHT / 2));
    VerletParticle2D vp2d = new VerletParticle2D(WIDTH / 3 + pv3.x, pv3.y + (HEIGHT / 2));
    vp2d.setPreviousPosition(arrow_begin);
    mps.add(vp2d);
    addParticle(vp2d, false, 400.0, DEFAULT_REPEL_FORCE*2);
    addParticle(arrow_begin, true, 0, 0.1);
    AngleSpring2D spring = new AngleSpring2D(arrow_begin, vp2d, 40., 0.01f, vp2d.sub(arrow_begin).heading());
    spring.lockA(true);
    physics.addSpring(spring);
    i += 1;
  }
}

void addParticle(VerletParticle2D p, boolean locked, float radius, float strength) {
  if (locked) { p.lock(); } else { p.unlock(); }
  physics.addBehavior(new AttractionBehavior2D(p, radius, strength));
  physics.addParticle(p);
}

void addParticle(VerletParticle2D p, boolean locked) {
  addParticle(p, locked, DEFAULT_REPULSION, DEFAULT_REPEL_FORCE);
}

void addParticle(VerletParticle2D p) {
  addParticle(p, false, DEFAULT_REPULSION, DEFAULT_REPEL_FORCE);
}

void draw() {
  scale(0.8);
  background(255);
  noFill();
  stroke(0, 0, 128);
  shape(internal1, WIDTH / 3, HEIGHT / 2);
  stroke(128, 0, 0);
  shape(internal2, WIDTH / 3, HEIGHT / 2);
  noStroke();
  for (int i = 0; i < 100; i++) {
    physics.update();
  }
  textSize(100);
  text(glyph, 40, 100);
  shapeMode(CENTER);
  for (int i = 0; i < mps.size(); i++) {
    shape(pnumbers[i+1], mps.get(i).x, mps.get(i).y);
  }
  shapeMode(CORNER);
  for (VerletParticle2D p : physics.particles) {
    if (p.isLocked()) { fill(0); } else {
      fill(200, 0, 0);
    }
    ellipse(p.x, p.y, 5, 5);
  }
  for (VerletSpring2D s : physics.springs) {
    noFill(); stroke(128, 128, 128);
    for (int i = 1; i < 20; i++) {
      if (i%2!=0) { continue ; }
      Vec2D aa = s.a.interpolateTo(s.b, ((i+1) * 0.05));
      Vec2D bb = s.a.interpolateTo(s.b, (i * 0.05));
      line(aa.x, aa.y, bb.x, bb.y);
    }
  }
  { outputGlyph(); if (!nextGlyph()) exit(); }
}

class AngleSpring2D extends VerletSpring2D {
  public float target_heading;

  public AngleSpring2D(VerletParticle2D a, VerletParticle2D b,
         float restLength, float strength, float target_heading) {
    super(a, b, 0, strength);
    a.lock();
    setRestLength(restLength);
    this.target_heading = target_heading;
  }

  protected void update(boolean applyConstraints) {
    Vec2D th = Vec2D.fromTheta(target_heading);
    //println(degrees(b.sub(a).heading()), degrees(target_heading));
    //if (applyConstraints && (abs(abs(b.sub(a).heading()) - abs(target_heading)) > radians(15))) {
    if (applyConstraints) {
      float str = getStrength() * (abs(abs(b.sub(a).heading()) - abs(target_heading)) / PI);
      //println(str);
      b.addVelocity(th.scale(1.0 - str).scaleSelf(3.0));
    }
    super.update(applyConstraints);
  }   
}

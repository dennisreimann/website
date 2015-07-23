import processing.core.*; import java.applet.*; import java.awt.*; import java.awt.image.*; import java.awt.event.*; import java.io.*; import java.net.*; import java.text.*; import java.util.*; import java.util.zip.*; public class Entwicklung extends PApplet {int s = 1; // Strichst\u00e4rke
int coord = 0; // X- und Y-Koordinate
int c = 0; // X- und Y-Koordinate

public void setup() {
  size(200, 200);
  background(255);
}

public void draw() {
  strokeWeight(s);
  stroke(c);
  point(coord, coord);
  // Werte um 1 erh\u00f6hen
  coord++;
  s++;
  c++;
}
static public void main(String args[]) {   PApplet.main(new String[] { "Entwicklung" });}}
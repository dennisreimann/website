import processing.core.*; import java.applet.*; import java.awt.*; import java.awt.image.*; import java.awt.event.*; import java.io.*; import java.net.*; import java.text.*; import java.util.*; import java.util.zip.*; public class Hell_Dunkel_1 extends PApplet {public void setup() {background(255);
// Strichfarbe und -st\u00e4rke
stroke(200);
strokeWeight(1);
// vertikale Linien
line(25, 0, 25, 100);
line(50, 0, 50, 100);
line(75, 0, 75, 100);
// horizontale Linien
line(0, 25, 100, 25);
line(0, 50, 100, 50);
line(0, 75, 100, 75);
noLoop(); } static public void main(String args[]) {   PApplet.main(new String[] { "Hell_Dunkel_1" });}}
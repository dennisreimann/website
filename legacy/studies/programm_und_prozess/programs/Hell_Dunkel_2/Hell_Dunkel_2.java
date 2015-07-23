import processing.core.*; import java.applet.*; import java.awt.*; import java.awt.image.*; import java.awt.event.*; import java.io.*; import java.net.*; import java.text.*; import java.util.*; import java.util.zip.*; public class Hell_Dunkel_2 extends PApplet {public void setup() {// Hintergrund weiss
background(255);
// Strichfarbe und -st\u00e4rke
stroke(120);
strokeWeight(10);
// vertikale Linien
line(20, 0, 20, 100);
line(50, 0, 50, 100);
line(80, 0, 80, 100);
// horizontale Linien
line(0, 20, 100, 20);
line(0, 50, 100, 50);
line(0, 80, 100, 80);
noLoop(); } static public void main(String args[]) {   PApplet.main(new String[] { "Hell_Dunkel_2" });}}
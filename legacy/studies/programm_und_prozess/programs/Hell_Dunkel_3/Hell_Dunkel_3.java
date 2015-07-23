import processing.core.*; import java.applet.*; import java.awt.*; import java.awt.image.*; import java.awt.event.*; import java.io.*; import java.net.*; import java.text.*; import java.util.*; import java.util.zip.*; public class Hell_Dunkel_3 extends PApplet {public void setup() {// Hintergrund weiss
background(255);
// Strichfarbe und -st\u00e4rke
stroke(0);
strokeWeight(25);
// vertikale Linien
line(18, 0, 18, 100);
line(50, 0, 50, 100);
line(82, 0, 82, 100);
// horizontale Linien
line(0, 18, 100, 18);
line(0, 50, 100, 50);
line(0, 82, 100, 82);
noLoop(); } static public void main(String args[]) {   PApplet.main(new String[] { "Hell_Dunkel_3" });}}
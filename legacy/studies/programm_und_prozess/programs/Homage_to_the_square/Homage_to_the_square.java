import processing.core.*; import java.applet.*; import java.awt.*; import java.awt.image.*; import java.awt.event.*; import java.io.*; import java.net.*; import java.text.*; import java.util.*; import java.util.zip.*; public class Homage_to_the_square extends PApplet {// Konstanten
int SIZE = 250;
int COLOR_RANGE = 255;

// Variablen
int homageCounter = 0;
int[] homageColors = {
  color(161, 182, 223),
  color(153, 153, 102),
  color(255, 255, 255),
  color(204, 255, 51)
};

// Array welches die Permutationen enth\u00e4lt
int countPermutations = factorial(homageColors.length);

/**
 *  berechnet die Fakult\u00e4t
 */
public int factorial(int n)
{
  return n == 0 ? 1 : n * factorial (n-1);
}

/**
 *  Vertauscht zwei Elemente des Arrays
 */
public void swap(int index1, int index2)
{
  int temp = homageColors[index1];
  homageColors[index1] = homageColors[index2];
  homageColors[index2] = temp;
}

/**
 *  F\u00fchrt eine Permutation durch
 *  fix: Funktioniert noch nicht richtig!
 */
public void permute(int index)
{
  int i = (index == 0) ? 0 : index % homageColors.length;
  int j = (i == homageColors.length-1) ? 0 : i+1;
  swap(i, j);
}

/**
 * setup setzt die B\u00fchneneigenschaften
 * und zeichent die erste Homage
 */
public void setup() 
{
  size(SIZE, SIZE);
  colorMode(RGB, COLOR_RANGE);
  background(COLOR_RANGE);
  rectMode(CENTER);
  noStroke();
  drawNewHomage();
}

/**
 * homage erwartet als Eingabeparameter den
 * Farbvektor mit vier Farben und zeichnet 
 * eine Homage auf die B\u00fchne
 */
public void homage(int[] c)
{
  for(int i=0; i<c.length;i++) {
    int rectSize = SIZE-(SIZE/5)*i;
    int rectYpos = PApplet.parseInt(SIZE/2+((SIZE/20)*i));
    drawSquare(c[i], rectYpos, rectSize);
  }
}

/**
 * Permutiert die Farbfolgen in der Homage
 * und zeichnet die jeweils aktuelle
 */
public void drawNewHomage()
{
  if(homageCounter == countPermutations)
    homageCounter = 0;
  // Homage zeichnen
  homage(homageColors);
  // permutieren und Counter erh\u00f6hen
  permute(homageCounter);
  homageCounter++;
}

/**
 * draw_square bekommt als Eingabeparameter 
 * eine Farbe, die x- und y-Position und Gr\u00f6\u00dfe
 * des Rechtecks und zeichnet das Rechteck 
 */
public void drawSquare(int c, int y, int s)
{
  fill(c);
  rect(SIZE/2, y, s, s);
}

/**
 * leer implementiert, damit mouseRelease funktioniert
 */
public void draw()
{
}

/**
 * 
 */
public void mouseReleased()
{
  drawNewHomage();
}

/**
 * 
 
void randomColor() {
  for (int i = 1; i <= 3; i++) {
    setColor(i, int(random(1,255)), int(random(1,255)), int(random(1,255)));
  }
}*/
static public void main(String args[]) {   PApplet.main(new String[] { "Homage_to_the_square" });}}
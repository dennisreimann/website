import processing.core.*; import java.applet.*; import java.awt.*; import java.awt.image.*; import java.awt.event.*; import java.io.*; import java.net.*; import java.text.*; import java.util.*; import java.util.zip.*; public class Bildungsgesetz extends PApplet {// Konstanten
int MARGIN = 20; // Randabstand
int FONT_SIZE = 36; // Schriftgr\u00f6\u00dfe
int ROWS = 5;
int COLUMNS = 2;
int COLUMN_GAP = 130;
int LETTER_START = 97;
int LETTER_END = 122;
// Buchstabenvariablen
int letterLeft = LETTER_START;
int letterRight = LETTER_START;

/**
 * Setup
 */
public void setup() 
{
  size((COLUMNS*COLUMN_GAP), (ROWS*FONT_SIZE)+MARGIN);
  fill(255);
  textFont(loadFont("CourierNew36.vlw"), FONT_SIZE);
  increment();
}

/**
 * leer implementiert, damit mouseRelease funktioniert
 */
public void draw()
{
}

/**
 * neues Inkrement ausf\u00fchren
 */
public void mouseReleased()
{
  increment();
}

/**
 * Zeichnet die jeweiligen W\u00f6rter auf die
 * B\u00fchne und setzt die Buchstaben neu
 */
public void increment()
{
  // zur\u00fccksetzen
  background(0);
  // zwei Spalten
  for(int x=0; x<COLUMNS; x++) {
    // f\u00fcnf Zeilen
    for(int y=1; y<=ROWS; y++) {
      // Wort zusammensetzen, dazu die Letter typecasten
      String word = (char)letterLeft + "ei" + (char)letterRight;
      // W\u00f6rter auf die B\u00fchne zeichnen
      text(word, (x*COLUMN_GAP)+MARGIN, (y*FONT_SIZE));
      // Buchstaben neu setzen
      if(letterRight == LETTER_END) {
        letterLeft += 1;
        letterRight = LETTER_START;
      } else
        letterRight += 1;
      // eventuell von vorne beginnen
      if(letterLeft > LETTER_END)
        letterLeft = LETTER_START;
    }
  }
}
static public void main(String args[]) {   PApplet.main(new String[] { "Bildungsgesetz" });}}
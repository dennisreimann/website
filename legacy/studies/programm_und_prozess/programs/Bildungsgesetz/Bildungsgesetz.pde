// Konstanten
int MARGIN = 20; // Randabstand
int FONT_SIZE = 36; // Schriftgröße
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
void setup() 
{
  size((COLUMNS*COLUMN_GAP), (ROWS*FONT_SIZE)+MARGIN);
  fill(255);
  textFont(loadFont("CourierNew36.vlw"), FONT_SIZE);
  increment();
}

/**
 * leer implementiert, damit mouseRelease funktioniert
 */
void draw()
{
}

/**
 * neues Inkrement ausführen
 */
void mouseReleased()
{
  increment();
}

/**
 * Zeichnet die jeweiligen Wörter auf die
 * Bühne und setzt die Buchstaben neu
 */
void increment()
{
  // zurücksetzen
  background(0);
  // zwei Spalten
  for(int x=0; x<COLUMNS; x++) {
    // fünf Zeilen
    for(int y=1; y<=ROWS; y++) {
      // Wort zusammensetzen, dazu die Letter typecasten
      String word = (char)letterLeft + "ei" + (char)letterRight;
      // Wörter auf die Bühne zeichnen
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

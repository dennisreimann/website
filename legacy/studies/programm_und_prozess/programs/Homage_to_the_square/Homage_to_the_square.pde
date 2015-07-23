// Konstanten
int SIZE = 250;
int COLOR_RANGE = 255;

// Variablen
int homageCounter = 0;
color[] homageColors = {
  color(161, 182, 223),
  color(153, 153, 102),
  color(255, 255, 255),
  color(204, 255, 51)
};

// Array welches die Permutationen enthält
int countPermutations = factorial(homageColors.length);

/**
 *  berechnet die Fakultät
 */
int factorial(int n)
{
  return n == 0 ? 1 : n * factorial (n-1);
}

/**
 *  Vertauscht zwei Elemente des Arrays
 */
void swap(int index1, int index2)
{
  color temp = homageColors[index1];
  homageColors[index1] = homageColors[index2];
  homageColors[index2] = temp;
}

/**
 *  Führt eine Permutation durch
 *  fix: Funktioniert noch nicht richtig!
 */
void permute(int index)
{
  int i = (index == 0) ? 0 : index % homageColors.length;
  int j = (i == homageColors.length-1) ? 0 : i+1;
  swap(i, j);
}

/**
 * setup setzt die Bühneneigenschaften
 * und zeichent die erste Homage
 */
void setup() 
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
 * eine Homage auf die Bühne
 */
void homage(color[] c)
{
  for(int i=0; i<c.length;i++) {
    int rectSize = SIZE-(SIZE/5)*i;
    int rectYpos = int(SIZE/2+((SIZE/20)*i));
    drawSquare(c[i], rectYpos, rectSize);
  }
}

/**
 * Permutiert die Farbfolgen in der Homage
 * und zeichnet die jeweils aktuelle
 */
void drawNewHomage()
{
  if(homageCounter == countPermutations)
    homageCounter = 0;
  // Homage zeichnen
  homage(homageColors);
  // permutieren und Counter erhöhen
  permute(homageCounter);
  homageCounter++;
}

/**
 * draw_square bekommt als Eingabeparameter 
 * eine Farbe, die x- und y-Position und Größe
 * des Rechtecks und zeichnet das Rechteck 
 */
void drawSquare(color c, int y, int s)
{
  fill(c);
  rect(SIZE/2, y, s, s);
}

/**
 * leer implementiert, damit mouseRelease funktioniert
 */
void draw()
{
}

/**
 * 
 */
void mouseReleased()
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

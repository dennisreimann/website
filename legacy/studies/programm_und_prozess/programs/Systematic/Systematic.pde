/**
 *  Settings
 */
int CANVAS_SIZE = 500;
int RECT_SIZE = 20;
int COUNT_FIELDS; // Anzahl der Rechtecke
int MARGIN = 20;
int CONTROL_WIDTH = 270; // Breite des Einstellungsbereichs
int FONT_SIZE = 12;
int DELAY_MIN = 0; // Minimalwert Delay
int DELAY_MAX = 1000; // Maximalwert Delay
int RAND_MIN = -4; // Minimalwert Zufall
int RAND_MAX = 4; // Maximalwert Zufall
int BG_COLOR = 125; // Hintergrundfarbe
int COLOR_FOCUS = 240; // Farbe fuers Highlight (Buttons)
int COLOR_BLUR = 200; // Farbe fuerNormalzustand (Buttons)
int STATES; // Anzahl der verschiedenen Zustaende
int counter; // Zaehler fuer die Zustaende
String state; // Aktueller Zustand (binaer), fuer systematischen Modus
String mode; // Modus - wird durch die Funkton set_mode() gesetzt
Slider ctrl_delay, ctrl_rand;
Button btn_systematic, btn_random, btn_reset;

/**
 *  Erzeugt die Buehne fuer den spaeteren Ablauf
 *  und die Slider (Kontrollelemente)
 */
void setup()
{
  background(BG_COLOR);
  size(CANVAS_SIZE + 2*MARGIN + CONTROL_WIDTH, CANVAS_SIZE + 2*MARGIN);
  // Font fuer die Werteausgabe
  PFont font = loadFont("Monaco-" + FONT_SIZE + ".vlw"); 
  textFont(font, FONT_SIZE);
  // Slider erstellen
  ctrl_delay = new Slider("Delay", 550, MARGIN, DELAY_MIN, DELAY_MAX);
  ctrl_rand = new Slider("Random", 680 , MARGIN, RAND_MIN, RAND_MAX);
  // Buttons erstellen
  btn_systematic = new Button("systematisch", 550, 240);
  btn_reset = new Button("reset", 550, 290);
  btn_random = new Button("zufällig", 680, 240);
  COUNT_FIELDS = int(sq(CANVAS_SIZE/RECT_SIZE));
  STATES = int(pow(2, (CANVAS_SIZE/RECT_SIZE)*2)); // 2 hoch X verschiedene Zustaende moeglich
  reset();
}

/**
 *  Zeichnet die Rechtecke systematisch auf die Buehne. 
 *  Dafuer wird zunaechst der Zustand angepasst und
 *  anschliessend die Felder durch draw_rects() gezeichnet.
 *  Danach wird der Counter erhoeht und ggf. verzoegert.
 */
void draw_systematic()
{
  state = binary(counter); // String mit binaerem Zahlenwert
  draw_rects();
  counter = counter < STATES ? counter + 1 : 0; // naechster Zustand
  delay(ctrl_delay.value); // evtl. verzoegern
}

/**
 *  Zeichnet die Rechtecke zufaellig auf die Buehne.
 *  state wird auf einen Zufallswert gesetzt und dann
 *  die Funktion draw_rects() aufgerufen, welche die
 *  Rechtecke zeichnet
 */
void draw_random()
{
  state = "";
  // Erzeugen eines Strings aus 0 un
  for(int i=0; i<COUNT_FIELDS; i++) {
    // Einstellung bei Wertberechnung mit einbeziehen
    float seed = float(ctrl_rand.value)/10;
    int k = round(random(1) + seed);
    // Wert ggf. auf 0 oder 1 anpassen
    k = k<0 ? 0 : k;
    k = k>1 ? 1 : k;
    state += k;
  }
  draw_rects();
}

/**
 *  Zeichnet die Rechtecke auf die Buehne. Der Farbwert des 
 *  jeweiligen Rechtecks wird durch die Funktion get_value()
 *  berechnet, welcher der Index des aktuellen Rechtecks 
 *  uebergeben werden muss.
 */
void draw_rects()
{
  noSmooth(); // Anti-Aliasing aus
  int pointer = 1; // Index des Rechtecks
  for(int y=0; y<CANVAS_SIZE; y+=RECT_SIZE){ // Zeilen
    for(int x=0; x<CANVAS_SIZE; x+=RECT_SIZE){ // Spalten
      fill(get_value(pointer));
      rect(MARGIN+x, MARGIN+y, RECT_SIZE, RECT_SIZE);
      pointer++; // Pointer auf das naechste Rechteck setzen
    }
  }
}

/**
 *  Setzt die Felder zurueck und stellt
 *  den Modus auf keinen Ablauf
 */
void reset()
{
  state = "";
  set_mode("");
  draw_rects();
}

/**
 *  Gibt den Farbwert fuer den angegebenen Index zurueck.
 *  Der Index verweist hierbei auf das Zeichen (von hinten 
 *  gezaehlt) des Strings mit dem binaeren Zahlenwert.
 *  Beispiel: state = "10010", index = 2 -> Zeichen = "1".
 *  Ist das Zeichen "1", so wird schwarz zurueckgegeben,
 *  ansonsten weiss...
 */
int get_value(int index)
{
  int len = state.length();
  int g = len - index;
  String sub = (index <= len) ? state.substring(g, g+1) : "0";
  return sub.equals("1") ? 0 : 255;
}

/**
 *  Zeichnet bei jedem Bild die Rechtecke neu
 */
void draw()
{
  strokeWeight(1.0); // Strichstaerke zuruecksetzen
  if(mode == "systematic")
    draw_systematic();
}

/**
 *  Bei jeder Mausbewegung wird der Hoverwert
 *  der beiden Slider neu gesetzt 
 */
void mouseMoved() {
  // Slider
  ctrl_delay.mod_hovered = (
    mouseX >= ctrl_delay.MOD_X && 
    mouseX <= ctrl_delay.MOD_X + ctrl_delay.MOD_SIZE &&
    mouseY >= ctrl_delay.mod_y && 
    mouseY <= ctrl_delay.mod_y + ctrl_delay.MOD_SIZE) ? true : false;
  ctrl_rand.mod_hovered = (
    mouseX >= ctrl_rand.MOD_X && 
    mouseX <= ctrl_rand.MOD_X + ctrl_rand.MOD_SIZE &&
    mouseY >= ctrl_rand.mod_y && 
    mouseY <= ctrl_rand.mod_y + ctrl_rand.MOD_SIZE) ? true : false;
  // Buttons
  btn_systematic.hovered = (
    mouseX >= btn_systematic.X && 
    mouseX <= btn_systematic.X + btn_systematic.WIDTH &&
    mouseY >= btn_systematic.Y && 
    mouseY <= btn_systematic.Y + btn_systematic.HEIGHT) ? true : false;
  btn_random.hovered = (
    mouseX >= btn_random.X && 
    mouseX <= btn_random.X + btn_random.WIDTH &&
    mouseY >= btn_random.Y && 
    mouseY <= btn_random.Y + btn_random.HEIGHT) ? true : false;
  btn_reset.hovered = (
    mouseX >= btn_reset.X && 
    mouseX <= btn_reset.X + btn_reset.WIDTH &&
    mouseY >= btn_reset.Y && 
    mouseY <= btn_reset.Y + btn_reset.HEIGHT) ? true : false;
  // neu zeichnen
  ctrl_delay.d();
  ctrl_rand.d();
  btn_systematic.d();
  btn_random.d();
  btn_reset.d();
}

/**
 *  Wird mit gedrueckter Maustaste die Maus bewegt,
 *  wird ggf. die Reglerposition der Slider neu
 *  gesetzt und ihr Wert angepasst.
 */
void mouseDragged() {
  if(ctrl_delay.mod_hovered)
    ctrl_delay.pos(mouseY);

  if(ctrl_rand.mod_hovered)
    ctrl_rand.pos(mouseY);
}

/**
 *  Wird einer der Buttons gedrueckt, so
 *  wird der Modus umgestellt
 */
void mouseReleased() {
  if(btn_systematic.hovered)
    set_mode("systematic");

  if(btn_random.hovered)
    set_mode("random");
   
  if(btn_reset.hovered)
    reset();
    
  // Auf Mausdruck ein neues Zufallsbild zeichnen
  if(mode == "random")
    draw_random();
}

/**
 *  Stellt den Modus um: Akzeptiert
 *  - "systematic"
 *  - "random"
 */
void set_mode(String m)
{
  mode = m;
  if(mode == "systematic")
    counter = 0; // aktuellen Zustand auf null setzen
}

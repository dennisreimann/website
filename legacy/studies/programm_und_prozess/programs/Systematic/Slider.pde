/**
 *  Die Klasse Slider stellt einen Schieberegler dar,
 *  welcher nach aussen hin ueber die Werte mod_hovered,
 *  mod_dragged und value abfragbar ist.
 */
class Slider {
  // Attribute
  private int MOD_SIZE = 15; // Groesse des Reglerknopfes (Konstante)
  private int MOD_Y_MIN, MOD_Y_MAX; // Hoechst- und Minimal-Y des Reglers (Konstante)
  private int WIDTH = 100; // Breite des gesamten Sliders (Konstante)
  private int HEIGHT = 200; // Hoehe des gesamten Sliders (Konstante)
  private int MOD_HEIGHT = 150; // Hoehe der Reglerschiene (Konstante)
  private int MOD_X, mod_y; // X und Y des Reglers
  private int X, Y; // X und Y des gesamten Sliders (Konstante)
  private int VALUE_MIN, VALUE_MAX; // Hoechst- und Minimalwert
  private float VALUE_STEP; // Wert um den nach jedem Schritt erhoeht wird
  private String name; // welcher Wert bearbeitet wird
  public int value; // aktueller Wert
  public boolean mod_hovered, mod_dragged; // Maus ueber Regler, Regler wird gedraggt
  
  /**
   *  Konstruktor: Setzt alle Werte des Sliders und zeichnet 
   *  ihn mit den uebergebenen Koordinaten auf die Buehne
   */
  Slider(String name, int x, int y, int value_min, int value_max)
  {
    this.name = name;
    this.X = x;
    this.Y = y;
    this.MOD_X = this.X + 50;
    this.MOD_Y_MIN = this.Y + this.MOD_SIZE;
    this.MOD_Y_MAX = this.Y + this.MOD_HEIGHT + this.MOD_SIZE;
    this.VALUE_MIN = value_min;
    this.VALUE_MAX = value_max;
    this.VALUE_STEP = float(this.VALUE_MAX - this.VALUE_MIN) / (this.MOD_Y_MAX-this.MOD_Y_MIN);
    this.pos(this.Y + this.MOD_SIZE);
  }
  
  /**
   *  Zeichnet den Slider auf die Buehne
   */
  void d()
  {
    smooth();
    // Hintergrund
    stroke(0);
    strokeWeight(1.0);
    fill(BG_COLOR);
    rect(this.X, this.Y, this.WIDTH, this.HEIGHT);
    // Slider
    strokeWeight(2.0);
    strokeCap(ROUND);
    line(this.MOD_X, this.MOD_Y_MIN, this.MOD_X, this.MOD_Y_MAX);
    // Regler
    strokeWeight(1.0);
    stroke(50);
    fill(this.mod_hovered ? COLOR_FOCUS : COLOR_BLUR);
    ellipse(this.MOD_X, this.mod_y, this.MOD_SIZE, this.MOD_SIZE);  
    // Name und Wert des Sliders
    fill(0);
    text(name + ": " + this.value, this.X + 5, this.Y + this.HEIGHT - FONT_SIZE);
  }
  
  /**
   *  Positioniert den Schieberegler neu und
   *  bestimmt den neuen Wert
   */
  void pos(int new_y)
  {
    if(new_y >= this.MOD_Y_MIN && new_y <= this.MOD_Y_MAX){
      this.mod_y = new_y;
      this.value = this.VALUE_MIN + int((new_y - this.MOD_Y_MIN) * this.VALUE_STEP);
      this.d(); // Neu auf Buehne zeichnen
    }
  }
}

/**
 *  Die Klasse Button
 */
class Button {
  // Attribute
  private int WIDTH = 100; // Breite des gesamten Buttons (Konstante)
  private int HEIGHT = 3*FONT_SIZE; // Hoehe des gesamten Buttons (Konstante)
  private int X, Y; // X und Y des Buttons (Konstante)
  private String name; // welcher Wert bearbeitet wird
  public boolean hovered; // Maus ueber Button
  
  /**
   *  Konstruktor: Setzt alle Werte des Sliders und zeichnet 
   *  ihn mit den uebergebenen Koordinaten auf die Buehne
   */
  Button(String name, int x, int y)
  {
    this.name = name;
    this.X = x;
    this.Y = y;
    this.d();
  }
  
  /**
   *  Zeichnet den Button auf die Buehne
   */
  void d()
  {
    smooth();
    // Hintergrund
    stroke(0);
    strokeWeight(1.0);
    fill(this.hovered ? COLOR_FOCUS : COLOR_BLUR);
    rect(this.X, this.Y, this.WIDTH, this.HEIGHT);
    // Name des Buttons
    fill(0);
    text(name, this.X + 5, this.Y + this.HEIGHT - FONT_SIZE);
  }
}

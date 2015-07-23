class Field {
  
  boolean active; // ist angeklickt?
  int _width, _height, _x, _y, _hue; // Variablen
  int _saturation = 20; // Sättigung im inaktiven Zustand
  int _brightness = 255; // Helligkeit im inaktiven Zustand
  
  // Konstruktor
  Field (int w, int h, int x, int y, int c)
  {  
    active = false;
    _width = w;
    _height = h;
    _x = x;
    _y = y;
    _hue = c;
    draw_field(_hue, _saturation, _brightness);
  }
  
  void toggle()
  {
    active = !active; // active auf das Gegenteil setzen
    if(active) // wenn jetzt aktiv, dann highlighten
      highlight();
  }
  
  void highlight()
  {
    // Farbton beibehalten, Sättigung und Helligkeit maximal
    draw_field(_hue, 255, 255);
  }
  
  void blur()
  {
    if(!active) // wenn das Feld nicht geklickt ist, dann zurücksetzen
      draw_field(_hue, _saturation, _brightness);
  }
  
  private void draw_field(int h, int s, int b)
  {
    fill(h, s, b);
    rect(_x, _y, _width, _height);
  }
  
  private boolean is_hovered()
  {
    return (mouseX >= _x && mouseX < _x + _width 
         && mouseY >= _y && mouseY < _y + _height);
  }
}

int start_color = 255; // Farbe mit der wir beginnen
int color_factor = 15; // Anteil um den der Farbton abnimmt
int field_width = 80;  // Breite des Felds
int field_height = 80; // Höhe des Felds
int stage_size = 400;  // Dimension der Bühne
int num_fields = int(stage_size/field_width) * int(stage_size/field_height); // Anzahl der Felder?
Field current_field;   // speichert das Feld über dem die Maus ist
Field[] fields = new Field[num_fields]; // Array mit allen Feldern

void setup()
{
  size(stage_size, stage_size);
  colorMode(HSB, 255); 
  background(0);
  int current_color = start_color;
  // Felder erstellen
  int index = 0;
  for(int i=0; i<(height/field_height); i++) {
    int y = i * field_height;
    for(int j=0; j<(width/field_width); j++) { 
      int x = j * field_width;
      // Felder in das Array schreiben, brauchen wir zur Referenzierung
      fields[index] = new Field(field_width, field_height, x, y, current_color);
      current_color -= color_factor;
      // zurücksetzen, wenn der Wert zu klein wird
      if(current_color <= 0)
        current_color = start_color;
      index++; // Arrayindex erhöhen
    }
  }
  current_field = fields[0]; // erstes Feld als Startwert setzen
}

void draw()
{
}

void mouseMoved()
{
  current_field.blur(); // altes Feld ausblenden
  current_field = get_current_field(); // welches Feld ist das aktuelle?
  current_field.highlight(); // neues Feld highlighten
}

void mouseReleased()
{
  current_field = get_current_field(); // welches Feld ist das aktuelle?
  current_field.toggle(); // bei Klick den Zustand wechseln
}

Field get_current_field()
{
  // Position anhand der Mausposition berechnen
  int x = floor(mouseX/field_width);
  int y = floor(mouseY/field_height);
  int id = (y * (width/field_width)) + x; // Feldindex berechnen 
  return fields[id]; // Aktuelles Feld zurückgeben
}

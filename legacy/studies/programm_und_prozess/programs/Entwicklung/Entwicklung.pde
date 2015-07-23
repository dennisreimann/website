int s = 1; // Strichstärke
int coord = 0; // X- und Y-Koordinate
color c = 0; // X- und Y-Koordinate

void setup() {
  size(200, 200);
  background(255);
}

void draw() {
  strokeWeight(s);
  stroke(c);
  point(coord, coord);
  // Werte um 1 erhöhen
  coord++;
  s++;
  c++;
}

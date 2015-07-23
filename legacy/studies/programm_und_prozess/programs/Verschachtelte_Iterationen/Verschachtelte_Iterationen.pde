void setup()
{
  // Variablen
  int canvas_size = 500;
  int box_size = 100;
  int start_size = 95;
  int size_factor = -4;
  int start_margin = 0;
  int margin_factor = 0;
  int start_color = 0;
  int color_factor = 8;
  // Setup
  size(canvas_size, canvas_size); 
  background(255);
  // Funktionsaufruf
  draw_rects(canvas_size, box_size, start_size, size_factor, start_margin, margin_factor, start_color, color_factor);
}

void draw_rects(int cs, int bs, int ss, int sf, int sm, int mf, int sc, int cf)
{
  int act_size = ss;
  int act_margin = sm;
  int act_color = sc;
  // vertikale Schleife
  for(int i=0; i<(cs/bs); i++) {
    int y = i * bs + act_margin;
    // horizontale Schleife
    for(int j=0; j<(cs/bs); j++) { 
      int x = j * bs + act_margin;
      fill(act_color);
      stroke(act_color);
      rect(x, y, act_size, act_size);
      act_size += sf; 
      act_margin += mf;
      act_color += cf;
    }
  }
} 

		

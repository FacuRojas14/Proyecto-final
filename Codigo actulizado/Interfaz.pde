// ==================== CLASE BOTON ====================
class Boton
{
  float x, y, w, h;
  String texto;
  boolean hover = false; // indica si el mouse está encima del botón

  // Constructor: asigna la ubicación del botón y el texto
  Boton(float x, float y, float w, float h, String texto)
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.texto = texto;
  }

  // Dibuja el botón en pantalla
  void dibujar()
  {
    hover = mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h; // detecta si el mouse está sobre el botón
    
    if (hover)
    {
      fill(color(80, 180, 255));  // Si el mouse está encima: azul
    } 
    else
    {
      fill(color(200));           // Si no está encima: gris
    }
    
    stroke(0);
    rect(x, y, w, h, 10);
    
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(texto, x + w/2, y + h/2);
  }
  
  // Verifica si el mouse está sobre el botón
  boolean estaSobre(float mx, float my)
  {
    return mx > x && mx < x + w && my > y && my < y + h;
  }
}


// ==================== CLASE CAMPO DE TEXTO ====================
class CampoTexto
{
  float x, y, w, h;
  String texto = "";
  boolean activo = true;
  String etiqueta = "";

  // Constructor: se usa para crear un campo de entrada de texto
  CampoTexto(float x, float y, float w, float h, String etiqueta)
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.etiqueta = etiqueta;
  }

  // Dibuja el campo de texto en pantalla
  void dibujar()
  {
    // Dibuja el campo
    fill(255);
    stroke(0);
    rect(x, y, w, h, 10);
    rect(x - 5, y - 21, w + 40, h - 20, 10);
    
    // Dibuja el texto del usuario
    fill(0);
    textAlign(LEFT, CENTER);
    textSize(16);
    text(texto, x + 10, y + h/2);

    // Dibuja la etiqueta
    fill(0);
    textAlign(LEFT, BOTTOM);
    textSize(12);
    text(etiqueta, x, y - 5);
  }

  // Maneja la escritura de caracteres
  void escribir(char tecla)
  {
    if (!activo) return;
    
    if (tecla == BACKSPACE && texto.length() > 0)
    {
      // Si presiona la tecla de borrar y hay texto, borra el último carácter
      texto = texto.substring(0, texto.length() - 1);
    } 
    else if (tecla == ENTER || tecla == RETURN)
    {
      // Si presiona Enter, desactiva el campo
      activo = false;
    } 
    else if (tecla != CODED)
    {
      // Si no es una tecla especial, agrega el carácter en mayúscula
      texto += Character.toUpperCase(tecla);
    }
  }
}

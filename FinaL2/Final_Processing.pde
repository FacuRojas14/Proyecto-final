import processing.serial.*; //nos sirve para comunicarnos con el arduino
import java.text.SimpleDateFormat; // nos ayuda a que la hora guardada sea legible y mdificar
import java.util.Date;// nos ayuda a trabajar con el horario de la computadora

Serial miArduino;

PImage parking; // PImage nos sirve para declarar la imagen
PImage auto_rojo_arriba, auto_amarillo_arriba, auto_rojo_abajo, auto_amarillo_abajo;

boolean[] ocupado = new boolean[8]; // boolean crea una lista de 8 lugares para guardar true o falso
String[] patenteLugar = new String[8]; // String nos sirve para guardar el texto que queramos
String[] horaEntrada = new String[8];
long[] horaEntradaMs = new long[8]; // long nos sirve para guardar el horario en millis

int[][] posiciones = // definimos la hubicacion de los lugares de los autos
{
  {174, 43, 155, 170},
  {338, 43, 146, 170},
  {493, 43, 146, 170},
  {648, 43, 146, 170},
  {174, 385,155, 172},
  {337, 385,147, 172},
  {492, 385,147, 172},
  {645, 385,147, 172}
};

int estadoMenu = 0;
String patenteIngresada = "";
String nombreSocio = "";
String patente1 = "";
String patente2 = "";
String patenteExtra = "";
int lugarARetirar = -1;

ArrayList<String[]> socios; //ArrayList<Socio[]> stipos de variable que vaa guardar en la lista y la palabra socio significa como se va a llamar

// Variables del cartel
boolean mostrarCartel = false;
float montoOriginal = 0;
float montoFinal = 0;
boolean cartelSocio = false;
String cartelNombreSocio = "";

// Variables del cartel de estacionamiento lleno
boolean mostrarCartelLleno = false;
long tiempoCartelLleno = 0;
boolean estacionamientoLleno = false;

// --- BOTONES DEL MENÚ ---
Boton botonIngresar, botonRetirar, botonAgregarSocio, botonAgregarPatente;

// --- CAMPO DE TEXTO ---
CampoTexto campoTexto = null;

void setup()
{
  fullScreen(); // inicialisamos la pantalla atrabajar que en este caso espantalla completa
  parking = loadImage("Parking.jpg"); // cargamos la imagenes
  auto_rojo_arriba = loadImage("auto_rojo.jpg");
  auto_amarillo_arriba = loadImage("auto_amarillo.jpg");
  auto_rojo_abajo = loadImage("auto_rojo_abajo.jpg");
  auto_amarillo_abajo = loadImage("auto_amarillo_abajo.jpg");

  printArray(Serial.list()); // nos indica que puertos estan siendo usados
 miArduino = new Serial(this, Serial.list()[1], 9600); // nos comunicamos con elarduino

  socios = new ArrayList<String[]>(); //inicialisamos la lista de socios
  cargarSocios();
  mostrarMenu();

  // Crear botones del menú
  botonIngresar = new Boton( width * 4/5 + 20, 200, width * 9/50 - 40, 50, "Ingresar Auto");
  botonRetirar = new Boton(width * 4/5 + 20, 200 + 70, width * 9/50 - 40, 50, "Retirar Auto");
  botonAgregarSocio = new Boton(width * 4/5 + 20, 200 + 70*2, width * 9/50 - 40, 50, "Agregar Socio");
  botonAgregarPatente = new Boton(width * 4/5 + 20, 200 + 70*3, width * 9/50 - 40, 50, "Agregar Patente");
}

void draw()
{
  background(0); // nos sirve para limpiar y actualizar la pantalla
  image(parking, 0, 0, width/1.3,height); // dibujamos la imagen del parkin
  for (int i = 0; i < 8; i++) imprimirAutos(i); // recorremos los 8 lgares del estacionamiento
  for (int i = 0; i < 8; i++)
  {
    if (ocupado[i]) // verififica que esta ocupado
    {
      if (mouseX > posiciones[i][0] && mouseX < posiciones[i][0] + posiciones[i][2] &&
          mouseY > posiciones[i][1] && mouseY < posiciones[i][1] + posiciones[i][3]) // verificamos si el maus esta sobre alguno de los 8 lugares
          {
        fill(255); // le damos color blanco
        rect(mouseX, mouseY - 20, 160, 20);// dibuja un rectangulo
        fill(0); // el color del texto
        text("Patente: " + patenteLugar[i], mouseX + 5, mouseY - 5); // No da informacoin del auto estacionado
      }
    }
  }

  // Dibuja el cartel de pago
  if (mostrarCartel) // entra en el if si solo la variable mostrar cartel es true
  {
    fill(0, 150);
    rect(0, 0, width, height);

    fill(255);
    rect(width/2 - 180, height/2 - 110, 360, 220, 20);

    fill(0);
    textAlign(CENTER, TOP); // indicamos la alineacion del texto
    textSize(16);// tamaño del texto
    text("Información del vehículo", width/2, height/2 - 95);
    textSize(14);
    textAlign(LEFT, TOP);

    float y = height/2 - 60;
    text("Socio: " + (cartelSocio ? "Sí" : "No"), width/2 - 150, y); // indicamos si es socio
    y += 25;
    if (cartelSocio)// en caso de que lo sea
    {
      text("Nombre del socio: " + cartelNombreSocio, width/2 - 150, y);
      y += 25;
      text("Monto original: $" + nf(montoOriginal, 0, 2), width/2 - 150, y);
      y += 25;
      text("Monto con descuento (15%): $" + nf(montoFinal, 0, 2), width/2 - 150, y);
    } else
    {
      text("Monto total: $" + nf(montoOriginal, 0, 2), width/2 - 150, y);// mostramos el monto total a pagar
    }

    fill(200, 0, 0);
    rect(width/2 - 50, height/2 + 60, 100, 30, 10);
    fill(255);
    textAlign(CENTER, CENTER);
    text("Cerrar", width/2, height/2 + 75); // boton para cerrar la ventana a pagar
  }

  //  Dibuja el cartel de estacionamiento lleno
  if (mostrarCartelLleno)
  {
    fill(0, 150);
    rect(0, 0, width, height);
    fill(255, 0, 0);
    rect(width/2 - 180, height/2 - 70, 360, 140, 20);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(22);
    text("ESTACIONAMIENTO LLENO", width/2, height/2);
    if (millis() - tiempoCartelLleno > 5000) // temporizador para ocultar el cartel luego de 5 segunodos
    {
      mostrarCartelLleno = false;
    }
  }

  // PANEL LATERAL Y BOTONES
  fill(50, 100);
  noStroke(); // nos sirve para quitar el contorno
  rect(width *39/50, 0, width * 11/50, height);

  botonIngresar.dibujar(); // dibuja los botones del menu
  botonRetirar.dibujar();
  botonAgregarSocio.dibujar();
  botonAgregarPatente.dibujar();

  //DIBUJA CAMPO DE TEXTO SI EXISTE
  if (campoTexto != null)
  {
    campoTexto.dibujar();
  }
}

void imprimirAutos(int i)
{
  if (ocupado[i])
  {
    PImage img; // variable temporal para la imagen
 if (i < 4) // dibuja los autos de arriba
 {
  if (i % 2 == 0) // si es par pone el auto de color rojo y si es impar pone el de color amarillo
  {
    img = auto_rojo_arriba;
  } else
  {
    img = auto_amarillo_arriba;
  }
} else // dibuja los autos de arriba
{
  if (i % 2 == 0)
  {
    img = auto_rojo_abajo;
  } else
  {
    img = auto_amarillo_abajo;
  }
}

    image(img, posiciones[i][0], posiciones[i][1], posiciones[i][2], posiciones[i][3]); // dibuja el auto en la posicion ya establecida
  }
}

// CLASE BOTÓN
class Boton
{
  float x, y, w, h;
  String texto;
  boolean hover = false; //indica si el mouse está encima del botón

  Boton(float x, float y, float w, float h, String texto) // asigno la ubicacion del boton y el texto
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.texto = texto;
  }

/*
void dibujar()
{
  boolean sobre = estaSobre()

  if (texto.equals("Ingresar Auto") && estacionamientoLleno) //texto.equals nos sirve para comparar los textos
  {
    fill(120); // gris desactivado
  } else if (sobre)
  {
    fill(70, 130, 255); // azul más claro al pasar el mouse
  } else
  {
    fill(30, 90, 200); // azul normal
  }

  rect(x, y, w, h, 10);
  fill(255);
  textAlign(CENTER, CENTER);
  text(texto, x + w/2, y + h/2);
}   */

  void dibujar() // este no deberia ir
  {
    hover = mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h; // detecta si el mou esta sobre el boton
  if (hover)
  {
  fill(color(80, 180, 255));  // Si el mouse está encima azul
} else
{
  fill(color(200));           // Si no está encima gris
}
    stroke(0);
    rect(x, y, w, h, 10);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(texto, x + w/2, y + h/2);
  }

  boolean presionado() // me debuelve un true si esta sobre el boton
  {
    return hover;
  }
}

// CLASE CAMPO DE TEXTO
class CampoTexto
{
  float x, y, w, h;
  String texto = "";
  boolean activo = true;
  String etiqueta = "";

  CampoTexto(float x, float y, float w, float h, String etiqueta) //se usa para crear un campo de pantalla
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.etiqueta = etiqueta;
  }

  void dibujar()
  {
   // dibuja el campo
    fill(255);
    stroke(0);
    rect(x, y, w, h, 10);
// dibuja el texto del usuario
    fill(0);
    textAlign(LEFT, CENTER);
    textSize(16);
    text(texto, x + 10, y + h/2);

    fill(0);
    textAlign(LEFT, BOTTOM);
    textSize(12);
    text(etiqueta, x, y - 5);
  }

  void escribir(char tecla)
  {
  if (!activo)
  {
  return;
} else
{
  if (tecla == BACKSPACE && texto.length() > 0)
  {
    texto = texto.substring(0, texto.length() - 1);    // Si presiona la tecla de borrar y hay texto, borra el último carácter

  } else if (tecla == ENTER || tecla == RETURN)
  {
 activo = false;    // Si presiona Enter, desactiva el campo
  } else if (tecla != CODED)
  {
    texto += Character.toUpperCase(tecla); // Si no es una tecla especial, agrega el carácter en mayúscula
  }
}
  }
}

//  MOUSE PRESSED
  public void mousePressed()
{
   if (mostrarCartel) //Si está abierto el cartel de información, solo permite cerrarlo
  {
    if (mouseX > width/2 - 50 && mouseX < width/2 + 50 &&
        mouseY > height/2 + 60 && mouseY < height/2 + 90)
        {
      mostrarCartel = false;
    }
    return;
  }

  if (botonIngresar.presionado())   // Validación si se presiona el botón de Ingresar y está lleno, no deja
  {
    if (estacionamientoLleno)
    {
      mostrarCartelLleno = true; // Muestra cartel de lleno y cancela acción
      tiempoCartelLleno = millis();
      return;
    }
    key = '1';  // Si no está lleno, procede normalmente
    keyPressed();
  }
  else if (botonRetirar.presionado())
  {
    key = '2';
    keyPressed();
  }
  else if (botonAgregarSocio.presionado())
  {
    key = '3';
    keyPressed();
  }
  else if (botonAgregarPatente.presionado())
  {
    key = '4';
    keyPressed();
  }
}

// --- KEY PRESSED MODIFICADO PARA USAR CAMPO DE TEXTO ---
public void keyPressed()
{
  // Si hay campo de texto activo
  if (campoTexto != null)
 {
    campoTexto.escribir(key);
    if (!campoTexto.activo)
    { // Enter presionado
       if (estadoMenu == 1)
  {
    patenteIngresada = campoTexto.texto;
    campoTexto = null;
    ocuparLugar(patenteIngresada);
    mostrarMenu();
  }
  else if (estadoMenu == 2)
{
  int lugar = int(campoTexto.texto.trim()) - 1; // convertir texto a número (1–8 → 0–7)
  campoTexto = null;

  if (lugar < 0 || lugar >= 8) {
    println("⚠️ Número de lugar inválido.");
    mostrarMenu();
    return;
  }

  if (!ocupado[lugar]) {
    println("⚠️ Ese lugar ya está vacío.");
    mostrarMenu();
    return;
  }

  // Calcular monto (por ejemplo, $100 por minuto)
  long tiempoEstadia = millis() - horaEntradaMs[lugar];
  float minutos = tiempoEstadia / 60000.0;
  montoOriginal = minutos * 100.0; // 💵 ejemplo: 100 por minuto
  montoFinal = montoOriginal;

  // Mostrar cartel de pago
  mostrarCartel = true;
  cartelSocio = false;
  for (String[] s : socios) {
    for (int j = 1; j < s.length; j++) {
      if (s[j].equalsIgnoreCase(patenteLugar[lugar])) {
        cartelSocio = true;
        cartelNombreSocio = s[0];
        montoFinal *= 0.85; // 15% descuento
      }
    }
  }

  // Liberar el lugar
  ocupado[lugar] = false;
  println("Auto retirado del lugar " + (lugar + 1));
  
  // 🟢 Enviar al Arduino el monto del pago
  String mensaje = "Pago:" + int(montoFinal) + "\n";
  println("→ Enviando a Arduino: " + mensaje);
  miArduino.write(mensaje);

  mostrarMenu();
}

      if (estadoMenu == 3)
      {
        nombreSocio = campoTexto.texto;
        println("Nombre socio: " + nombreSocio);
        campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese primera patente");
        estadoMenu = 4;
      } else if (estadoMenu == 4)
      {
        patente1 = campoTexto.texto;
        if (patente1.equals("")) patente1 = "-";
        println("Primera patente: " + patente1);
        campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese segunda patente (ENTER si no tiene)");
        estadoMenu = 5;
      } else if (estadoMenu == 5)
      {
        patente2 = campoTexto.texto;
        if (patente2.equals("")) patente2 = "-";
        agregarSocio(nombreSocio, patente1, patente2);
        guardarSocios();
        println("Socio agregado.");
        campoTexto = null;
        mostrarMenu();
      } else if (estadoMenu == 6)
      {
        nombreSocio = campoTexto.texto;
        campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese nueva patente");
        estadoMenu = 7;
      } else if (estadoMenu == 7)
      {
        patenteExtra = campoTexto.texto;
        agregarPatenteASocio(nombreSocio, patenteExtra);
        guardarSocios();
        println("Patente agregada.");
        campoTexto = null;
        mostrarMenu();
      }
    }
    return;
  }

  // --- MENÚ PRINCIPAL ---
  if (estadoMenu == 0)
  {
    if (key == '1') {
  if (estacionamientoLleno) {
    println("⚠️ Estacionamiento lleno, no se puede ingresar más autos.");
    mostrarCartelLleno = true;
    tiempoCartelLleno = millis();
    return;
  }

  estadoMenu = 1;
  patenteIngresada = "";
  println("Ingrese patente del auto: ");
  
  campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese patente del auto");
}
 else if (key == '2')
  {
  estadoMenu = 2;
  println("Ingrese número de lugar (1-8):");
  campoTexto = new CampoTexto(
    width * 4/5 + 20,
    height - 80,
    width * 9/50 - 40,
    40,
    "Ingrese número de lugar (1-8)"
  );
}
    else if (key == '3')
  { estadoMenu = 3; campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese nombre del socio"); }

    else if (key == '4')
  { estadoMenu = 6; campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese nombre del socio a modificar"); }

    else { println("Opción inválida."); mostrarMenu(); }
  }
}

// --- RESTO DE FUNCIONES (no cambian) ---
void mostrarMenu()
{
  println("\n===== MENÚ PRINCIPAL =====");
  println("1 - Ingresar auto");
  println("2 - Retirar auto");
  println("3 - Agregar socio");
  println("4 - Agregar patente a socio");
  println("==========================");
  print("Seleccione una opción: ");
  estadoMenu = 0;
}

void ocuparLugar(String patente)
{
  for (int i = 0; i < 8; i++)
  {
    if (!ocupado[i])
    {
      ocupado[i] = true;
      patenteLugar[i] = patente;
      horaEntrada[i] = obtenerHoraActual();
      horaEntradaMs[i] = millis();
      println("Auto ubicado en lugar " + (i+1) + " a las " + horaEntrada[i]);
      String mensaje = "Lugar:" + (i+1) + "\n";
      println("→ Enviando a Arduino: " + mensaje);
      miArduino.write(mensaje);
      break;
    }
  }
}

String obtenerHoraActual()
{
  SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
  return sdf.format(new Date());
}

void agregarSocio(String nombre, String p1, String p2)
{
  String[] nuevo = {nombre, p1, p2};
  socios.add(nuevo);
  println("Socio agregado: " + nombre);
}

void agregarPatenteASocio(String nombre, String nuevaPatente)
{
  for (String[] s : socios)
  {
    if (s[0].equalsIgnoreCase(nombre))
    {
      String[] actualizado = append(s, nuevaPatente);
      socios.set(socios.indexOf(s), actualizado);
      println("Patente agregada correctamente a " + nombre);
      return;
    }
  }
  println("No se encontró el socio con ese nombre.");
}

void cargarSocios()
{
  socios.clear();
  String[] lineas = loadStrings("socios.txt");
  if (lineas == null) return;
  for (String l : lineas)
  {
    String[] partes = split(l, ';');
    if (partes.length >= 3) socios.add(partes);
  }
}

void guardarSocios()
{
  String[] lineas = new String[socios.size()];
  for (int i = 0; i < socios.size(); i++) lineas[i] = join(socios.get(i), ';');
  saveStrings("socios.txt", lineas);
}

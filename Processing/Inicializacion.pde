// ============================================
// PESTAÑA: Inicializacion
// Contiene todas las funciones de inicialización del programa
// ============================================

// Carga todas las imágenes necesarias
void cargarImagenes()
{
  parking = loadImage("Parking.jpg");
  auto_rojo_arriba = loadImage("auto_rojo.jpg");
  auto_amarillo_arriba = loadImage("auto_amarillo.jpg");
  auto_rojo_abajo = loadImage("auto_rojo_abajo.jpg");
  auto_amarillo_abajo = loadImage("auto_amarillo_abajo.jpg");
  println(" Imágenes cargadas correctamente");
}

// Inicializa la conexión con Arduino
void inicializarArduino()
{
  printArray(Serial.list()); // muestra los puertos disponibles
  miArduino = new Serial(this, Serial.list()[1], 9600);
  tiempoInicioConexion = millis();
  println(" Conexión con Arduino establecida");
}

// Inicializa el array de lugares de estacionamiento
void inicializarLugares()
{
  for (int i = 0; i < 8; i++)
  {
    lugares[i] = new RegistroAuto();
  }
  println(" Lugares de estacionamiento inicializados");
}

// Inicializa la lista de socios
void inicializarSocios()
{
  socios = new ArrayList<String[]>();
  cargarSocios();
  println(" Sistema de socios inicializado");
}

// Crea todos los botones del menú principal
void crearBotonesMenu()
{
  float x = width * 4/5 + 20;
  float ancho = width * 9/50 - 40;
  
  botonIngresar = new Boton(x, 200, ancho, 50, "Ingresar Auto");
  botonRetirar = new Boton(x, 270, ancho, 50, "Retirar Auto");
  botonAgregarSocio = new Boton(x, 340, ancho, 50, "Agregar Socio");
  botonAgregarPatente = new Boton(x, 410, ancho, 50, "Agregar Patente");
  botonModoManual = new Boton(x, 480, ancho, 50, "Modo Manual");
  botonSalirModoManual = new Boton(x, 480, ancho, 50, "Salir del modo manual");
  botonResumen = new Boton(x, 550, ancho, 50, "Resumen");
  
  println(" Botones del menú creados");
}

// Crea los botones del menú de resumen
void crearBotonesResumen()
{
  botonDia = new Boton(width/2 - 200, height/2 - 60, 180, 50, "Día");
  botonSemana = new Boton(width/2 + 20, height/2 - 60, 180, 50, "Semana");
  botonMes = new Boton(width/2 - 200, height/2 + 20, 180, 50, "Mes");
  botonHistorico = new Boton(width/2 + 20, height/2 + 20, 180, 50, "Histórico");
  botonCerrarResumen = new Boton(width/2 - 60, height/2 + 100, 120, 35, "Cerrar");
  
  println(" Botones de resumen creados");
}

// Inicializa el sistema de alertas
void inicializarAlertas()
{
  for (int i = 0; i < 8; i++)
  {
    alertaMostrada[i] = false;
  }
  println(" Sistema de alertas inicializado");
}

// Carga los datos guardados
void cargarDatosGuardados()
{
  cargarBackup();
  verificarArchivoHistorial();
  println(" Datos guardados cargados");
}

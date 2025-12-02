
import processing.serial.*; //nos sirve para comunicarnos con el arduino
Serial miArduino;

PImage parking; // PImage nos sirve para declarar la imagen
PImage auto_rojo_arriba, auto_amarillo_arriba, auto_rojo_abajo, auto_amarillo_abajo;

RegistroAuto[] lugares = new RegistroAuto[8];

int estadoMenu = 0;
int tiempoInicio = 0;
int duracionMensaje = 3000;
String patenteIngresada = "";
String mensaje = "";
String nombreSocio = "";
String patenteExtra = "";
String codigoSocio = "";

ArrayList<String[]> socios; //ArrayList<Socio[]> tipos de variable que va a guardar en la lista y la palabra socio significa como se va a llamar

//CARTEL
boolean mostrarCartel = false;
boolean mostrarMensaje = false;
boolean ingresoDesdeArduino = false;
float montoOriginal = 0;
float montoFinal = 0;
boolean cartelSocio = false;
String cartelNombreSocio = "";

// CARTEL ESTACIONAMIENTO LLENO
boolean mostrarCartelLleno = false;
long tiempoCartelLleno = 0;
boolean estacionamientoLleno = false;

//BOTONES DEL MENÚ
Boton botonIngresar, botonRetirar, botonAgregarSocio, botonAgregarPatente;
Boton botonModoManual, botonSalirModoManual;
Boton botonResumen;
// Para el menú de resumen
Boton botonDia, botonSemana, botonMes, botonHistorico, botonCerrarResumen;

// --- CAMPO DE TEXTO ---
CampoTexto campoTexto= null;

// --- MODO MANUAL ---
boolean modoManual = false;

//BLOQUEAR TECLAS EN MODO MANUAL
boolean teclasBloqueadas = false; //para modo manual, bloquear todas las teclas

//FECHA Y HORA EN PANTALLA
String horaActual = "";
String fechaActual = "";
int ultimoSegundo = -1;

// ESTADÍSTICAS MODO MANUAL
int autosIngresadosModoManual = 0;
int autosSalidosModoManual = 0;
float dineroIngresadoModoManual = 0;
long tiempoInicioModoManual = 0;

// CARTEL RESUMEN MODO MANUAL
boolean mostrarCartelResumen = false;

// SISTEMA DE RESUMEN Y ALERTAS
boolean mostrarMenuResumen = false;
boolean mostrarCartelEstadisticas = false;
String tipoResumen = ""; // "DIA", "SEMANA", "MES", "HISTORICO"

// Variables para estadísticas
int totalIngresos = 0;
int totalSalidas = 0;
float dineroTotal = 0;

// ALERTAS DE TIEMPO
//final float HORAS_ALERTA = 4.0; // alerta después de 4 horas
final float HORAS_ALERTA = 1; // LO DEJAMOS EN 1 SOLO PARA PROBAR 1 MINUTO
boolean[] alertaMostrada = new boolean[8];

//POSICIONES IMAGENES AUTOS
int[][] posiciones =
{
{228, 54, 206, 221},{442, 54, 195, 221},{645, 54, 195, 221},{849, 54, 195, 221},{229, 494,203, 221},{441, 494,195, 221},{645, 494,195, 221},{848, 494,195, 221}
  //    A1                  A2                    A3                  A4                  A5                  A6                  A7                  A8
};

boolean backupEnviado = false;
int lugaresOcupadosAlCargar = 0;
long tiempoInicioConexion = 0;

void setup()
{
  fullScreen(); // pantalla completa
  
  // INICIALIZACIÓN DEL SISTEMA
  cargarImagenes();
  inicializarArduino();
  inicializarLugares();
  inicializarSocios();
  inicializarAlertas();
  
  // CREAR INTERFAZ
  crearBotonesMenu();
  crearBotonesResumen();
  
  // CARGAR DATOS GUARDADOS
  cargarDatosGuardados();
  
}
//===============TERMINA SETUP====================
void draw()
{
  background(0); // limpiar y actualizar la pantalla
  
  // ENVIAR BACKUP DESPUÉS DE 3 SEGUNDOS
  if (!backupEnviado && millis() - tiempoInicioConexion > 3000)
  {
    if (lugaresOcupadosAlCargar > 0)
    {
      miArduino.write("Ocupados:" + lugaresOcupadosAlCargar + "\n");
      println("Enviado a Arduino: " + lugaresOcupadosAlCargar + " lugares ocupados");
    }
    backupEnviado = true;
  }
  
  // DIBUJAR ELEMENTOS PRINCIPALES
  image(parking, 0, 0, width/1.3, height); // imagen del parking
  for (int i = 0; i < 8; i++) imprimirAutos(i); // dibujar autos
  
  // DIBUJAR INTERFAZ
  dibujarNumerosLugares();
  dibujarInfoSobre();
  dibujarPanelLateral();
  dibujarBotones();
  dibujarIndicadorModoManual();
  dibujarFechaHora();
  dibujarAlertasTiempo();
  dibujarMensajeTemporal();
  
  // DIBUJAR CARTELES Y MENÚS
  dibujarCartelPago();
  dibujarCartelResumenModoManual();
  dibujarCartelEstacionamientoLleno();
  dibujarMenuResumen();
  dibujarCartelEstadisticas();
}

//=====================TERMINA DRAW=========================

void mostrarEnPantalla(String txt)
{
  mensaje = txt;
  mostrarMensaje = true;
  tiempoInicio = millis();
}

//=========================INICIO CLASES==============================

//======================CLASE REGISTRO AUTO=========================
class RegistroAuto
{
  boolean ocupado = false;
  String patente = "";
  // Fecha y hora de entrada
  int diaEntrada, mesEntrada, anioEntrada;
  int horaEntrada, minutoEntrada, segundoEntrada;
  // Constructor
  RegistroAuto()
  {
    ocupado = false;
    patente = "";
  }
  // Registrar entrada
  void registrarEntrada(String pat)
  {
    ocupado = true;
    patente = pat;
    diaEntrada = day();
    mesEntrada = month();
    anioEntrada = year();
    horaEntrada = hour();
    minutoEntrada = minute();
    segundoEntrada = second();
  }
  // Calcular minutos transcurridos desde la entrada
  float calcularMinutosTranscurridos()
  {
    // Calcular diferencia en días
    int diasTranscurridos = (year() - anioEntrada) * 365 + (month() - mesEntrada) * 30 + (day() - diaEntrada);
    // Calcular diferencia en horas, minutos y segundos
    int horasTranscurridas = hour() - horaEntrada;
    int minutosTranscurridos = minute() - minutoEntrada;
    int segundosTranscurridos = second() - segundoEntrada;
    // Convertir todo a minutos totales
    float totalMinutos = diasTranscurridos * 1440 + // días a minutos
                         horasTranscurridas * 60 +   // horas a minutos
                         minutosTranscurridos +       // minutos
                         segundosTranscurridos / 60.0; // segundos a minutos
    return totalMinutos;
  }
  // Formatear fecha/hora de entrada para mostrar
  String obtenerFechaHoraEntrada()
  {
    return nf(diaEntrada, 2) + "/" + nf(mesEntrada, 2) + "/" + anioEntrada + " " + nf(horaEntrada, 2) + ":" + nf(minutoEntrada, 2) + ":" + nf(segundoEntrada, 2);
  }
  // Liberar lugar
  void liberar()
  {
    ocupado = false;
    patente = "";
  }
 
  // Convertir a String para backup (separado por ;)
  String ConvertirAString()
  {
    if (!ocupado)
    {
      return "false;-;0;0;0;0;0;0";
    }
    return ocupado + ";" + patente + ";" + diaEntrada + ";" + mesEntrada + ";" + anioEntrada + ";" +horaEntrada + ";" + minutoEntrada + ";" + segundoEntrada;
  }
 
  // Cargar desde String de backup
  void DesconvierteString(String linea)
  {
    String[] partes = split(linea, ';');
    if (partes.length >= 8)
    {
      ocupado = partes[0].equals("true");
      patente = partes[1].equals("-") ? "" : partes[1];
      diaEntrada = int(partes[2]);
      mesEntrada = int(partes[3]);
      anioEntrada = int(partes[4]);
      horaEntrada = int(partes[5]);
      minutoEntrada = int(partes[6]);
      segundoEntrada = int(partes[7]);
    }
  }
}
//======================FINAL CLASES=========================

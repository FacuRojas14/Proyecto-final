
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

int EntradaAuto(String nombre)
{
  int lugar = -1;
  for (int i = 0; i < 8; i++) 
  {
    if (!lugares[i].ocupado) int EntradaAuto(String nombre)
{
  int lugar = -1;
  for (int i = 0; i < 8; i++) 
  {
    if (!lugares[i].ocupado) 
    {
      lugares[i].registrarEntrada(nombre);
      actualizarEstadoEstacionamiento();
      lugar = i + 1;
      mostrarEnPantalla(" Auto ubicado en lugar " + lugar + " (" + nombre + ")" + "   Entrada: " + lugares[i].obtenerFechaHoraEntrada());
      
      // GUARDAR EN HISTORIAL - ENTRADA
      guardarEnHistorial(nombre, 0, "ENTRADA", lugar);
      
      // Contar ingreso si está en modo manual
      if (modoManual)
      {
        autosIngresadosModoManual++;
      }
      break;
    }
  }
  guardarBackup();
  return lugar;
}

int SalidaAuto(String nombre)
{
  int lugar = -1;
  
  // Buscar el lugar ocupado por ese socio o patente
  for (int i = 0; i < 8; i++)
  {
    if (lugares[i].ocupado && lugares[i].patente.equalsIgnoreCase(nombre))
    {
      lugar = i;
      break;
    }
  }
  
  if (lugar == -1)
  {
    mostrarEnPantalla("No se encontró el auto de " + nombre);
    return -1;
  }
  
  // Calcular tiempo y monto base
  float minutos = lugares[lugar].calcularMinutosTranscurridos();
  montoOriginal = minutos * 100.0;
  montoFinal = montoOriginal;
  
  // --- Aplicar descuento según modo ---
  if (!ingresoDesdeArduino)
  {
    // Modo manual: aplicar descuento si es socio
    cartelSocio = false;
    cartelNombreSocio = "";
    for (String[] s : socios)
    {
      for (int j = 1; j < s.length; j++)
      {
        if (s[j].equalsIgnoreCase(lugares[lugar].patente))
        {
          cartelSocio = true;
          cartelNombreSocio = s[0];
          montoFinal *= 0.85; // 15% descuento
        }
      }
    }
    
  } else {
    // Modo Arduino: marcar como socio con descuento
    cartelSocio = true;
    cartelNombreSocio = nombre;
    montoFinal *= 0.85; // 15% descuento
  }
  
  // GUARDAR EN HISTORIAL - SALIDA
  guardarEnHistorial(nombre, montoFinal, "SALIDA", lugar + 1);
  
  // Liberar lugar
  lugares[lugar].liberar();
  actualizarEstadoEstacionamiento();
  
  // Mostrar cartel solo si NO está en modo manual
  if (!modoManual)
  {
    mostrarCartel = true;
  }
  else  
  {
    // Acumular estadísticas para modo manual
    autosSalidosModoManual++;
    dineroIngresadoModoManual += montoFinal;
  }
  
  mostrarEnPantalla("Auto de " + nombre + "   retirado del lugar " + (lugar + 1)+ "   Tiempo: " + nf(minutos, 0, 2) + " minutos");
  
  // Resetear flag de ingreso desde Arduino
  ingresoDesdeArduino = false;
 
  guardarBackup();
  return lugar;
}

// Actualiza el estado de ocupación del estacionamiento
void actualizarEstadoEstacionamiento()
{
  estacionamientoLleno = true;
  for (int i = 0; i < lugares.length; i++)
  {
    if (!lugares[i].ocupado)
    {
      estacionamientoLleno = false;
      break;
    }
  }
}

void imprimirAutos(int i)
{
  if (lugares[i].ocupado)
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
    }
    else // dibuja los autos de abajo
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
    {
      lugares[i].registrarEntrada(nombre);
      actualizarEstadoEstacionamiento();
      lugar = i + 1;
      mostrarEnPantalla(" Auto ubicado en lugar " + lugar + " (" + nombre + ")" + "   Entrada: " + lugares[i].obtenerFechaHoraEntrada());
      
      // GUARDAR EN HISTORIAL - ENTRADA
      guardarEnHistorial(nombre, 0, "ENTRADA", lugar);
      
      // Contar ingreso si está en modo manual
      if (modoManual)
      {
        autosIngresadosModoManual++;
      }
      break;
    }
  }
  guardarBackup();
  return lugar;
}

int SalidaAuto(String nombre)
{
  int lugar = -1;
  
  // Buscar el lugar ocupado por ese socio o patente
  for (int i = 0; i < 8; i++)
  {
    if (lugares[i].ocupado && lugares[i].patente.equalsIgnoreCase(nombre))
    {
      lugar = i;
      break;
    }
  }
  
  if (lugar == -1)
  {
    mostrarEnPantalla("No se encontró el auto de " + nombre);
    return -1;
  }
  
  // Calcular tiempo y monto base
  float minutos = lugares[lugar].calcularMinutosTranscurridos();
  montoOriginal = minutos * 100.0;
  montoFinal = montoOriginal;
  
  // --- Aplicar descuento según modo ---
  if (!ingresoDesdeArduino)
  {
    // Modo manual: aplicar descuento si es socio
    cartelSocio = false;
    cartelNombreSocio = "";
    for (String[] s : socios)
    {
      for (int j = 1; j < s.length; j++)
      {
        if (s[j].equalsIgnoreCase(lugares[lugar].patente))
        {
          cartelSocio = true;
          cartelNombreSocio = s[0];
          montoFinal *= 0.85; // 15% descuento
        }
      }
    }
    
  } else {
    // Modo Arduino: marcar como socio con descuento
    cartelSocio = true;
    cartelNombreSocio = nombre;
    montoFinal *= 0.85; // 15% descuento
  }
  
  // GUARDAR EN HISTORIAL - SALIDA
  guardarEnHistorial(nombre, montoFinal, "SALIDA", lugar + 1);
  
  // Liberar lugar
  lugares[lugar].liberar();
  actualizarEstadoEstacionamiento();
  
  // Mostrar cartel solo si NO está en modo manual
  if (!modoManual)
  {
    mostrarCartel = true;
  }
  else  
  {
    // Acumular estadísticas para modo manual
    autosSalidosModoManual++;
    dineroIngresadoModoManual += montoFinal;
  }
  
  mostrarEnPantalla("Auto de " + nombre + "   retirado del lugar " + (lugar + 1)+ "   Tiempo: " + nf(minutos, 0, 2) + " minutos");
  
  // Resetear flag de ingreso desde Arduino
  ingresoDesdeArduino = false;
 
  guardarBackup();
  return lugar;
}

// Actualiza el estado de ocupación del estacionamiento
void actualizarEstadoEstacionamiento()
{
  estacionamientoLleno = true;
  for (int i = 0; i < lugares.length; i++)
  {
    if (!lugares[i].ocupado)
    {
      estacionamientoLleno = false;
      break;
    }
  }
}

void imprimirAutos(int i)
{
  if (lugares[i].ocupado)
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
    }
    else // dibuja los autos de abajo
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

// Guarda el estado actual del estacionamiento en archivo
void guardarBackup()
{
  String[] lineas = new String[8];
  for (int i = 0; i < 8; i++)
  {
    lineas[i] = lugares[i].ConvertirAString();
  }
  saveStrings("backup.txt", lineas);
  println("Backup guardado correctamente.");
}

// Carga el estado del estacionamiento al iniciar el programa
void cargarBackup()
{
  String[] lineas = loadStrings("backup.txt");
  if (lineas == null)
  {
    println("No se encontró backup previo, iniciando vacío.");
    backupEnviado = true;
    return;
  }
 
  for (int i = 0; i < min(lineas.length, 8); i++)
  {
    lugares[i].DesconvierteString(lineas[i]);
  }
  actualizarEstadoEstacionamiento();
 
  // Contar lugares ocupados al cargar
  lugaresOcupadosAlCargar = 0;
  for (int i = 0; i < 8; i++)
  {
    if (lugares[i].ocupado)
    {
      lugaresOcupadosAlCargar++;
    }
  }
  
  // Enviar a Arduino la cantidad de lugares ocupados
  if (lugaresOcupadosAlCargar > 0)
  {
    miArduino.write("Ocupados:" + lugaresOcupadosAlCargar + "\n");
    println("Enviado a Arduino: " + lugaresOcupadosAlCargar + " lugares ocupados");
  }
 
  println(" Backup cargado correctamente.");
}
void serialEvent(Serial p)
{
  String dato = p.readStringUntil('\n');
  if (dato != null)
  {
    dato = trim(dato);
    mostrarEnPantalla("Recibido: " + dato);
   
    // Arduino indica que entró la selección del usuario en el shield: ENTRADA_MANUAL o SALIDA_MANUAL
 if (dato.equalsIgnoreCase("LLENO"))
    {
      estacionamientoLleno = true;
      mostrarCartelLleno = true;
      tiempoCartelLleno = millis();
    } else if (dato.equalsIgnoreCase("LIBRE"))
    {
      estacionamientoLleno = false;
    }
    else if (dato.startsWith("SOCIO:"))
   {
      String nombre = dato.substring(6).trim();  // obtiene el nombre sin "SOCIO:"
      mostrarEnPantalla("Socio verificado: " + nombre);
      ingresoDesdeArduino = true;  
      //  Asignar un lugar automáticamente
      int lugarAsignado = EntradaAuto(nombre);  // esta función debe devolver un número
      // Enviar el número de lugar a Arduino
      miArduino.write("Lugar:" + lugarAsignado + "\n");
      mostrarEnPantalla("Enviado a Arduino → Lugar:" + lugarAsignado);
   }
 else if (dato.startsWith("Entrada:"))
{
  String codigoIngresado = dato.substring(8).trim(); // obtiene el código después de "Entrada:"
  mostrarEnPantalla("Código ingresado desde Arduino: " + codigoIngresado);
 
  // Buscar si el código pertenece a algún socio
  boolean encontrado = false;
  String nombreSocio = "";
 
  for (String[] s : socios)
  {
    if (s.length >= 2 && s[1].equals(codigoIngresado))
    {
      encontrado = true;
      nombreSocio = s[0];
      break;
    }
  }
 
  if (encontrado)
  {
    // Es un socio válido
    ingresoDesdeArduino = true;
   
    // Enviar confirmación de socio a Arduino
    miArduino.write("Socio:" + nombreSocio + "\n");
   
    // Asignar lugar
    int lugarAsignado = EntradaAuto(nombreSocio);
    miArduino.write("Lugar:" + lugarAsignado + "\n");
   
    mostrarEnPantalla("Socio encontrado: " + nombreSocio + " - Lugar: " + lugarAsignado);
  }
  else
  {
    // Código no válido
    miArduino.write("NoSocio:\n");
    mostrarEnPantalla("Código no válido: " + codigoIngresado);
  }
}
else if (dato.startsWith("Salida:"))
{
  String codigoIngresado = dato.substring(7).trim();
  mostrarEnPantalla("Código de salida ingresado desde Arduino: " + codigoIngresado);
  //delay(1000);
  // Buscar si el código pertenece a algún socio
  boolean encontrado = false;
  String nombreSocio = "";
  String[] patentesSocio = null;  //GUARDAMOS TODO EL ARRAY

  for (String[] s : socios)
  {
    if (s.length >= 2 && s[1].equals(codigoIngresado))
    {
      encontrado = true;
      nombreSocio = s[0];
      patentesSocio = s;  //GUARDAMOS EL ARRAY COMPLETO
      break;
    }
  }

  if (encontrado)
  {
    //Buscar si ALGUNA DE LAS PATENTES del socio está estacionada
    int lugarEncontrado = -1;
    String patenteEncontrada = "";  
    for (int i = 0; i < 8; i++)
    {
      if (lugares[i].ocupado)
      {
        //Verificar si la patente estacionada pertenece al socio
        for (int j = 2; j < patentesSocio.length; j++)  // desde índice 2 porque [0]=nombre, [1]=código
        {
          if (patentesSocio[j].equalsIgnoreCase(lugares[i].patente))
          {
            lugarEncontrado = i;
            patenteEncontrada = lugares[i].patente;  //GUARDAMOS LA PATENTE
            break;
          }
        }
        if (lugarEncontrado != -1) break;
      }
    }

    if (lugarEncontrado != -1)
    {
      // Socio tiene un auto estacionado, procesar salida
      miArduino.write("SalidaSocio:" + nombreSocio + "\n");

      //USAMOS LA PATENTE, NO EL NOMBRE
      int lugar = SalidaAuto(patenteEncontrada);
      if (lugar != -1)
      {
        miArduino.write("Salida:" + (lugar + 1) + "\n");
        miArduino.write("Pago:" + int(montoFinal) + "\n");
      }
    }
    else
    {
      // Socio existe pero no tiene autos estacionados
      miArduino.write("SocioNoEstacionado:\n");
      mostrarEnPantalla("El socio " + nombreSocio + " no tiene autos estacionados");
    }
  }
  else
  {
    // Código no válido
    miArduino.write("NoSocio:\n");
    mostrarEnPantalla("Código no válido: " + codigoIngresado);
  }
}
}
}
// Verifica si existe el archivo de historial, si no lo crea
void verificarArchivoHistorial() 
{
  String[] lineas = loadStrings("historial.txt");
  if (lineas == null) 
  {
    // Crear archivo con encabezado
    String[] encabezado = {"Fecha;Hora;Patente;Tipo;Lugar;Monto"};
    saveStrings("historial.txt", encabezado);
    println("Archivo historial.txt creado.");
  }
}

// Guarda un registro de entrada o salida en el historial
void guardarEnHistorial(String patente, float monto, String tipo, int lugar)
{
  // Formato: dia/mes/año;hora:min:seg;patente;ENTRADA/SALIDA;lugar;monto
  String fecha = nf(day(), 2) + "/" + nf(month(), 2) + "/" + year();
  String hora = nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2);
  String montoStr = (tipo.equals("ENTRADA")) ? "-" : nf(monto, 0, 2);
  String registro = fecha + ";" + hora + ";" + patente + ";" + tipo + ";" + lugar + ";" + montoStr;
  
  String[] lineas = loadStrings("historial.txt");
  if (lineas == null) 
  {
    lineas = new String[0];
  }
  
  // Agregar la nueva línea
  lineas = append(lineas, registro);
  
  // Guardar todo de nuevo
  saveStrings("historial.txt", lineas);
  println(" Guardado en historial: " + registro);
}

// Guarda una marca especial en el historial (ej: activación de modo manual)
void guardarMarcaEnHistorial(String marca)
{
  String fecha = nf(day(), 2) + "/" + nf(month(), 2) + "/" + year();
  String hora = nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2);
  String registro = fecha + ";" + hora + ";" + marca;
  
  String[] lineas = loadStrings("historial.txt");
  if (lineas == null)
  {
    lineas = new String[0];
  }
  lineas = append(lineas, registro);
  saveStrings("historial.txt", lineas);
  println("️ Marca en historial: " + marca);
}

// Calcula las estadísticas según el período seleccionado
void calcularEstadisticas(String periodo)
{
  tipoResumen = periodo;
  totalIngresos = 0;
  totalSalidas = 0;
  dineroTotal = 0;
  int[] conteoLugares = new int[8];
  
  String[] lineas = loadStrings("historial.txt");
  if (lineas == null || lineas.length <= 1)
  {
    println("No hay datos en el historial");
    return;
  }
  
  int diaActual = day();
  int mesActual = month();
  int anioActual = year();
  
  for (int i = 1; i < lineas.length; i++)
  {
    String[] partes = split(lineas[i], ';');
    if (partes.length < 6) continue;
    if (partes[2].contains("====")) continue;
    
    String[] fecha = split(partes[0], '/');
    if (fecha.length != 3) continue;
    
    int dia = int(fecha[0]);
    int mes = int(fecha[1]);
    int anio = int(fecha[2]);
    
    boolean incluir = false;
    
    if (periodo.equals("DIA"))
    {
      incluir = (dia == diaActual && mes == mesActual && anio == anioActual);
    }
    else if (periodo.equals("SEMANA"))
    {
      int diasDiferencia = (anioActual - anio) * 365 + (mesActual - mes) * 30 + (diaActual - dia);
      incluir = (diasDiferencia >= 0 && diasDiferencia <= 7);
    }
    else if (periodo.equals("MES"))
    {
      incluir = (mes == mesActual && anio == anioActual);
    }
    else if (periodo.equals("HISTORICO"))
    {
      incluir = true;
    }
    
    if (incluir)
    {
      String tipo = partes[3].trim();
      if (tipo.equals("ENTRADA"))
      {
        totalIngresos++;
        int lugar = int(partes[4].trim()) - 1;
        if (lugar >= 0 && lugar < 8)
        {
          conteoLugares[lugar]++;
        }
      }
      else if (tipo.equals("SALIDA"))
      {
        totalSalidas++;
        // Reemplazar coma por punto para pasar correctamente
        String montoStr = partes[5].replace("$", "").replace(" ", "").replace(",", ".").trim();
        if (!montoStr.equals("-") && !montoStr.equals("") && montoStr.length() > 0)
        {
          try {
            float monto = float(montoStr);
            dineroTotal += monto;
          } catch (NumberFormatException e) {
            println("Error parseando: '" + montoStr + "'");
          }
        }
        int lugar = int(partes[4].trim()) - 1;
        if (lugar >= 0 && lugar < 8)
        {
          conteoLugares[lugar]++;
        }
      }
    }
  }
 
  println("=== RESUMEN " + periodo + " ===");
  println("Ingresos: " + totalIngresos);
  println("Salidas: " + totalSalidas);
  println("Dinero: $" + nf(dineroTotal, 0, 2));
}

void cargarImagenes()
{
  parking = loadImage("Parking.jpg");
  auto_rojo_arriba = loadImage("auto_rojo.jpg");
  auto_amarillo_arriba = loadImage("auto_amarillo.jpg");
  auto_rojo_abajo = loadImage("auto_rojo_abajo.jpg");
  auto_amarillo_abajo = loadImage("auto_amarillo_abajo.jpg");
  println("✓ Imágenes cargadas correctamente");
}

// Inicializa la conexión con Arduino
void inicializarArduino()
{
  printArray(Serial.list()); // muestra los puertos disponibles
  miArduino = new Serial(this, Serial.list()[4], 9600);
  tiempoInicioConexion = millis();
  println("✓ Conexión con Arduino establecida");
}

// Inicializa el array de lugares de estacionamiento
void inicializarLugares()
{
  for (int i = 0; i < 8; i++)
  {
    lugares[i] = new RegistroAuto();
  }
  println("✓ Lugares de estacionamiento inicializados");
}

// Inicializa la lista de socios
void inicializarSocios()
{
  socios = new ArrayList<String[]>();
  cargarSocios();
  println("✓ Sistema de socios inicializado");
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
  
  println("✓ Botones del menú creados");
}

// Crea los botones del menú de resumen
void crearBotonesResumen()
{
  botonDia = new Boton(width/2 - 200, height/2 - 60, 180, 50, "Día");
  botonSemana = new Boton(width/2 + 20, height/2 - 60, 180, 50, "Semana");
  botonMes = new Boton(width/2 - 200, height/2 + 20, 180, 50, "Mes");
  botonHistorico = new Boton(width/2 + 20, height/2 + 20, 180, 50, "Histórico");
  botonCerrarResumen = new Boton(width/2 - 60, height/2 + 100, 120, 35, "Cerrar");
  
  println("✓ Botones de resumen creados");
}

// Inicializa el sistema de alertas
void inicializarAlertas()
{
  for (int i = 0; i < 8; i++)
  {
    alertaMostrada[i] = false;
  }
  println("Sistema de alertas inicializado");
}

// Carga los datos guardados
void cargarDatosGuardados()
{
  cargarBackup();
  verificarArchivoHistorial();
  println("Datos guardados cargados");
}

// ==================== CLASE BOTON ====================
class Boton
{
  float x, y, w, h;
  String texto;
  boolean Sobre = false; // indica si el mouse está encima del botón

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
    Sobre = mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h; // detecta si el mouse está sobre el botón
    
    if (Sobre)
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
public void keyPressed()
{
  if (teclasBloqueadas) return;  //Si está bloqueado, ignorar todo
  if (key =='9')
  {
    if (modoManual) desactivarModoManual();
    else activarModoManual();
    return;
  }

  // Si hay campo de texto activo
  if (campoTexto != null)
  {
    campoTexto.escribir(key);
    if (!campoTexto.activo)
    { // Enter presionado: procesar según estadoMenu
//=======================================================
      if (estadoMenu == 1)
      {
        patenteIngresada = campoTexto.texto;
        campoTexto = null;
        int lugarAsignado =EntradaAuto(patenteIngresada);
        // Enviar el número de lugar a Arduino
        miArduino.write("Lugar:" + lugarAsignado + "\n");
       
        estadoMenu = 0;
        return;
      }
//=======================================================
      else if (estadoMenu == 2)
      {
        int lugar = int(campoTexto.texto.trim()) - 1; // convertir texto a número (1–8 → 0–7)
        campoTexto = null;
        if (lugar < 0 || lugar >= 8) //Validamos lugar
        {
          mostrarEnPantalla("numero invalido");
          estadoMenu = 0;
          return;
        }
        if (!lugares[lugar].ocupado)
        {
          mostrarEnPantalla("Ese lugar ya está vacío.");
          estadoMenu = 0;
           return;
        }
        // Obtener el nombre asociado a ese lugar
        String nombre = lugares[lugar].patente;
        mostrarEnPantalla(" Retirando auto del lugar " + (lugar + 1) + " (" + nombre + ")");
        // Usamos la misma función que el modo manual
        int lugarLiberado = SalidaAuto(nombre);
        if (lugarLiberado != -1)
        {
          //Enviar al Arduino la salida y el monto
          miArduino.write("Salida:" + (lugarLiberado + 1) + "\n");
          miArduino.write("Pago:" + int(montoFinal) + "\n");
        }
        estadoMenu = 0;
        guardarBackup();
        return;
      }
//=======================================================
      else if (estadoMenu == 3)
      {
        nombreSocio = campoTexto.texto;
        mostrarEnPantalla("Nombre socio: " + nombreSocio);
        campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese codigo de  socio");
        estadoMenu = 10;
      }
//=======================================================
      else if (estadoMenu == 4)
{
  String patenteNueva = campoTexto.texto.trim();
 
  if (patenteNueva.equals(""))
  {
    // Usuario presionó ENTER sin escribir nada
    // Validar que tenga al menos UNA patente
    if (patenteExtra.equals(""))
    {
      mostrarEnPantalla("Debe ingresar al menos UNA patente");
      campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese al menos una patente");
      return;
    }
   
    // Agregar el socio con todas las patentes
    agregarSocio(nombreSocio, codigoSocio, patenteExtra);
    guardarSocios();
   
    int totalPatentes = split(patenteExtra, '|').length;
    mostrarEnPantalla(" Socio " + nombreSocio + " agregado con " + totalPatentes + " patente(s)");
   
    campoTexto = null;
    estadoMenu = 0;
  }
  else
  {
    // Agregar la patente a la lista
    if (patenteExtra.equals(""))
    {
      patenteExtra = patenteNueva;
      mostrarEnPantalla("Patente agregada: " + patenteNueva);
    } else {
      patenteExtra = patenteExtra + "|" + patenteNueva;
      int total = split(patenteExtra, '|').length;
      mostrarEnPantalla("Patente " + total + " agregada: " + patenteNueva);
    }
   
    // Pedir siguiente patente
    campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Otra patente (ENTER vacío para terminar)");
  }
}
//=======================================================
      else if (estadoMenu == 6)
      {
        nombreSocio = campoTexto.texto;
        campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese nueva patente");
        estadoMenu = 7; //PONER PORQUE LLAMAMOS A MENU=7
      }
//=======================================================
      else if (estadoMenu == 7)
      {
        patenteExtra = campoTexto.texto;
        agregarPatenteASocio(nombreSocio, patenteExtra);
        guardarSocios();
        campoTexto = null;
        estadoMenu = 0;
       
      }
//======================================================
else if (estadoMenu == 10)
{
  codigoSocio = campoTexto.texto;
  
  // VERIFICAR SI EL CÓDIGO YA EXISTE
  if (codigoSocioExiste(codigoSocio))
  {
    mostrarEnPantalla("ERROR: Ya existe un socio con ese código");
    campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese otro código de socio");
    return;  // Vuelve a pedir el código
  }
  
  mostrarEnPantalla("Código del socio: " + codigoSocio);
  patenteExtra = "";
  campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese patente (ENTER vacío para terminar)");
  estadoMenu = 4;
}
    }
    return;
  }

//=================MENÚ PRINCIPAL====================
if (estadoMenu == 0)
{
  if (key == '1')
  {
    if (estacionamientoLleno)
    {
      mostrarCartelLleno = true;
      tiempoCartelLleno = millis();
      return;
    }

    estadoMenu = 1;
    patenteIngresada = "";
    campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese patente del auto");
  }
  else if (key == '2')
  {
    estadoMenu = 2;
    campoTexto = new CampoTexto(
      width * 4/5 + 20,
      height - 80,
      width * 9/50 - 40,40,"Ingrese número de lugar (1-8)");
  }
  else if (key == '3')
  {
    estadoMenu = 3;
    campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese nombre del socio");
  }
  else if (key == '4')
  {
    estadoMenu = 6;
    campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese nombre del socio a modificar");
  }
  else
  {
    mostrarEnPantalla("Opción inválida.");
  }
  }
}
public void keyPressed()
{
  if (teclasBloqueadas) return;  //Si está bloqueado, ignorar todo
  if (key =='9')
  {
    if (modoManual) desactivarModoManual();
    else activarModoManual();
    return;
  }

  // Si hay campo de texto activo
  if (campoTexto != null)
  {
    campoTexto.escribir(key);
    if (!campoTexto.activo)
    { // Enter presionado: procesar según estadoMenu
//=======================================================
      if (estadoMenu == 1)
      {
        patenteIngresada = campoTexto.texto;
        campoTexto = null;
        int lugarAsignado =EntradaAuto(patenteIngresada);
        // Enviar el número de lugar a Arduino
        miArduino.write("Lugar:" + lugarAsignado + "\n");
       
        estadoMenu = 0;
        return;
      }
//=======================================================
      else if (estadoMenu == 2)
      {
        int lugar = int(campoTexto.texto.trim()) - 1; // convertir texto a número (1–8 → 0–7)
        campoTexto = null;
        if (lugar < 0 || lugar >= 8) //Validamos lugar
        {
          mostrarEnPantalla("numero invalido");
          estadoMenu = 0;
          return;
        }
        if (!lugares[lugar].ocupado)
        {
          mostrarEnPantalla("Ese lugar ya está vacío.");
          estadoMenu = 0;
           return;
        }
        // Obtener el nombre asociado a ese lugar
        String nombre = lugares[lugar].patente;
        mostrarEnPantalla(" Retirando auto del lugar " + (lugar + 1) + " (" + nombre + ")");
        // Usamos la misma función que el modo manual
        int lugarLiberado = SalidaAuto(nombre);
        if (lugarLiberado != -1)
        {
          //Enviar al Arduino la salida y el monto
          miArduino.write("Salida:" + (lugarLiberado + 1) + "\n");
          miArduino.write("Pago:" + int(montoFinal) + "\n");
        }
        estadoMenu = 0;
        guardarBackup();
        return;
      }
//=======================================================
      else if (estadoMenu == 3)
      {
        nombreSocio = campoTexto.texto;
        mostrarEnPantalla("Nombre socio: " + nombreSocio);
        campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese codigo de  socio");
        estadoMenu = 10;
      }
//=======================================================
      else if (estadoMenu == 4)
{
  String patenteNueva = campoTexto.texto.trim();
 
  if (patenteNueva.equals(""))
  {
    // Usuario presionó ENTER sin escribir nada
    // Validar que tenga al menos UNA patente
    if (patenteExtra.equals(""))
    {
      mostrarEnPantalla("Debe ingresar al menos UNA patente");
      campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese al menos una patente");
      return;
    }
   
    // Agregar el socio con todas las patentes
    agregarSocio(nombreSocio, codigoSocio, patenteExtra);
    guardarSocios();
   
    int totalPatentes = split(patenteExtra, '|').length;
    mostrarEnPantalla(" Socio " + nombreSocio + " agregado con " + totalPatentes + " patente(s)");
   
    campoTexto = null;
    estadoMenu = 0;
  }
  else
  {
    // Agregar la patente a la lista
    if (patenteExtra.equals(""))
    {
      patenteExtra = patenteNueva;
      mostrarEnPantalla("Patente agregada: " + patenteNueva);
    } else {
      patenteExtra = patenteExtra + "|" + patenteNueva;
      int total = split(patenteExtra, '|').length;
      mostrarEnPantalla("Patente " + total + " agregada: " + patenteNueva);
    }
   
    // Pedir siguiente patente
    campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Otra patente (ENTER vacío para terminar)");
  }
}
//=======================================================
      else if (estadoMenu == 6)
      {
        nombreSocio = campoTexto.texto;
        campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese nueva patente");
        estadoMenu = 7; //PONER PORQUE LLAMAMOS A MENU=7
      }
//=======================================================
      else if (estadoMenu == 7)
      {
        patenteExtra = campoTexto.texto;
        agregarPatenteASocio(nombreSocio, patenteExtra);
        guardarSocios();
        campoTexto = null;
        estadoMenu = 0;
       
      }
//======================================================
else if (estadoMenu == 10)
{
  codigoSocio = campoTexto.texto;
  
  // VERIFICAR SI EL CÓDIGO YA EXISTE
  if (codigoSocioExiste(codigoSocio))
  {
    mostrarEnPantalla("ERROR: Ya existe un socio con ese código");
    campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese otro código de socio");
    return;  // Vuelve a pedir el código
  }
  
  mostrarEnPantalla("Código del socio: " + codigoSocio);
  patenteExtra = "";
  campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese patente (ENTER vacío para terminar)");
  estadoMenu = 4;
}
    }
    return;
  }

//=================MENÚ PRINCIPAL====================
if (estadoMenu == 0)
{
  if (key == '1')
  {
    if (estacionamientoLleno)
    {
      mostrarCartelLleno = true;
      tiempoCartelLleno = millis();
      return;
    }

    estadoMenu = 1;
    patenteIngresada = "";
    campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese patente del auto");
  }
  else if (key == '2')
  {
    estadoMenu = 2;
    campoTexto = new CampoTexto(
      width * 4/5 + 20,
      height - 80,
      width * 9/50 - 40,40,"Ingrese número de lugar (1-8)");
  }
  else if (key == '3')
  {
    estadoMenu = 3;
    campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese nombre del socio");
  }
  else if (key == '4')
  {
    estadoMenu = 6;
    campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese nombre del socio a modificar");
  }
  else
  {
    mostrarEnPantalla("Opción inválida.");
  }
  }
}
public void keyPressed()
{
  if (teclasBloqueadas) return;  //Si está bloqueado, ignorar todo
  if (key =='9')
  {
    if (modoManual) desactivarModoManual();
    else activarModoManual();
    return;
  }

  // Si hay campo de texto activo
  if (campoTexto != null)
  {
    campoTexto.escribir(key);
    if (!campoTexto.activo)
    { // Enter presionado: procesar según estadoMenu
//=======================================================
      if (estadoMenu == 1)
      {
        patenteIngresada = campoTexto.texto;
        campoTexto = null;
        int lugarAsignado =EntradaAuto(patenteIngresada);
        // Enviar el número de lugar a Arduino
        miArduino.write("Lugar:" + lugarAsignado + "\n");
       
        estadoMenu = 0;
        return;
      }
//=======================================================
      else if (estadoMenu == 2)
      {
        int lugar = int(campoTexto.texto.trim()) - 1; // convertir texto a número (1–8 → 0–7)
        campoTexto = null;
        if (lugar < 0 || lugar >= 8) //Validamos lugar
        {
          mostrarEnPantalla("numero invalido");
          estadoMenu = 0;
          return;
        }
        if (!lugares[lugar].ocupado)
        {
          mostrarEnPantalla("Ese lugar ya está vacío.");
          estadoMenu = 0;
           return;
        }
        // Obtener el nombre asociado a ese lugar
        String nombre = lugares[lugar].patente;
        mostrarEnPantalla(" Retirando auto del lugar " + (lugar + 1) + " (" + nombre + ")");
        // Usamos la misma función que el modo manual
        int lugarLiberado = SalidaAuto(nombre);
        if (lugarLiberado != -1)
        {
          //Enviar al Arduino la salida y el monto
          miArduino.write("Salida:" + (lugarLiberado + 1) + "\n");
          miArduino.write("Pago:" + int(montoFinal) + "\n");
        }
        estadoMenu = 0;
        guardarBackup();
        return;
      }
//=======================================================
      else if (estadoMenu == 3)
      {
        nombreSocio = campoTexto.texto;
        mostrarEnPantalla("Nombre socio: " + nombreSocio);
        campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese codigo de  socio");
        estadoMenu = 10;
      }
//=======================================================
      else if (estadoMenu == 4)
{
  String patenteNueva = campoTexto.texto.trim();
 
  if (patenteNueva.equals(""))
  {
    // Usuario presionó ENTER sin escribir nada
    // Validar que tenga al menos UNA patente
    if (patenteExtra.equals(""))
    {
      mostrarEnPantalla("Debe ingresar al menos UNA patente");
      campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese al menos una patente");
      return;
    }
   
    // Agregar el socio con todas las patentes
    agregarSocio(nombreSocio, codigoSocio, patenteExtra);
    guardarSocios();
   
    int totalPatentes = split(patenteExtra, '|').length;
    mostrarEnPantalla(" Socio " + nombreSocio + " agregado con " + totalPatentes + " patente(s)");
   
    campoTexto = null;
    estadoMenu = 0;
  }
  else
  {
    // Agregar la patente a la lista
    if (patenteExtra.equals(""))
    {
      patenteExtra = patenteNueva;
      mostrarEnPantalla("Patente agregada: " + patenteNueva);
    } else {
      patenteExtra = patenteExtra + "|" + patenteNueva;
      int total = split(patenteExtra, '|').length;
      mostrarEnPantalla("Patente " + total + " agregada: " + patenteNueva);
    }
   
    // Pedir siguiente patente
    campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Otra patente (ENTER vacío para terminar)");
  }
}
//=======================================================
      else if (estadoMenu == 6)
      {
        nombreSocio = campoTexto.texto;
        campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese nueva patente");
        estadoMenu = 7; //PONER PORQUE LLAMAMOS A MENU=7
      }
//=======================================================
      else if (estadoMenu == 7)
      {
        patenteExtra = campoTexto.texto;
        agregarPatenteASocio(nombreSocio, patenteExtra);
        guardarSocios();
        campoTexto = null;
        estadoMenu = 0;
       
      }
//======================================================
else if (estadoMenu == 10)
{
  codigoSocio = campoTexto.texto;
  
  // VERIFICAR SI EL CÓDIGO YA EXISTE
  if (codigoSocioExiste(codigoSocio))
  {
    mostrarEnPantalla("ERROR: Ya existe un socio con ese código");
    campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese otro código de socio");
    return;  // Vuelve a pedir el código
  }
  
  mostrarEnPantalla("Código del socio: " + codigoSocio);
  patenteExtra = "";
  campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese patente (ENTER vacío para terminar)");
  estadoMenu = 4;
}
    }
    return;
  }

//=================MENÚ PRINCIPAL====================
if (estadoMenu == 0)
{
  if (key == '1')
  {
    if (estacionamientoLleno)
    {
      mostrarCartelLleno = true;
      tiempoCartelLleno = millis();
      return;
    }

    estadoMenu = 1;
    patenteIngresada = "";
    campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese patente del auto");
  }
  else if (key == '2')
  {
    estadoMenu = 2;
    campoTexto = new CampoTexto(
      width * 4/5 + 20,
      height - 80,
      width * 9/50 - 40,40,"Ingrese número de lugar (1-8)");
  }
  else if (key == '3')
  {
    estadoMenu = 3;
    campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese nombre del socio");
  }
  else if (key == '4')
  {
    estadoMenu = 6;
    campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese nombre del socio a modificar");
  }
  else
  {
    mostrarEnPantalla("Opción inválida.");
  }
  }
}

// Dibuja los números de los lugares de estacionamiento
void dibujarNumerosLugares()
{
  for (int i = 0; i < 8; i++)
  {
    // Posición: esquina superior derecha de cada lugar
    float numX = posiciones[i][0] + posiciones[i][2] - 30; // 30px desde el borde derecho
    float numY = posiciones[i][1] + 25; // 25px desde arriba
   
    // Fondo para el número
    if (lugares[i].ocupado) {
      fill(255, 0, 0, 180); // rojo semi-transparente si está ocupado
    }
    else
    {
      fill(0, 255, 0, 180); // verde semi-transparente si está libre
    }
    noStroke();
    circle(numX, numY, 30); // círculo de fondo
   
    // Número
    fill(255); // blanco
    textAlign(CENTER, CENTER);
    textSize(18);
    text(i + 1, numX, numY); // números del 1 al 8
  }
}

// Dibuja la información del auto cuando el mouse pasa sobre él
void dibujarInfoSobre()
{
  for (int i = 0; i < 8; i++)
  {
    if (lugares[i].ocupado) // verifica que está ocupado
    {
      if (mouseX > posiciones[i][0] && mouseX < posiciones[i][0] + posiciones[i][2] && 
          mouseY > posiciones[i][1] && mouseY < posiciones[i][1] + posiciones[i][3])
      {
        fill(255); // le damos color blanco
        rect(mouseX, mouseY - 20, 160, 20); // dibuja un rectángulo
        textAlign(LEFT, CENTER);
        fill(0); // el color del texto
        text("Patente: " + lugares[i].patente, mouseX + 45, mouseY - 10); // Da info del auto estacionado
      }
    }
  }
}

// Dibuja el cartel de pago cuando se retira un vehículo
void dibujarCartelPago()
{
  if (!mostrarCartel) return;
  
  fill(0, 150);
  rect(0, 0, width, height);
  fill(255);
  rect(width/2 - 180, height/2 - 110, 360, 220, 20);
  fill(0);
  textAlign(CENTER, TOP);
  textSize(16);
  text("Información del vehículo", width/2, height/2 - 95);
  textSize(14);
  textAlign(LEFT, TOP);
  float y = height/2 - 60;
  text("Socio: " + (cartelSocio ? "Sí" : "No"), width/2 - 150, y);
  y += 25;
  if (cartelSocio)
  {
    text("Nombre del socio: " + cartelNombreSocio, width/2 - 150, y);
    y += 25;
    text("Monto original: $" + nf(montoOriginal, 0, 2), width/2 - 150, y);
    y += 25;
    text("Monto con descuento (15%): $" + nf(montoFinal, 0, 2), width/2 - 150, y);
  }
  else
  {
    text("Monto total: $" + nf(montoOriginal, 0, 2), width/2 - 150, y);
  }

  fill(200, 0, 0);
  rect(width/2 - 50, height/2 + 60, 100, 30, 10);
  fill(255);
  textAlign(CENTER, CENTER);
  text("Cerrar", width/2, height/2 + 75);
}

// Dibuja el cartel con el resumen del modo manual
void dibujarCartelResumenModoManual()
{
  if (!mostrarCartelResumen) return;
  
  fill(0, 150);
  rect(0, 0, width, height);
  fill(255);
  rect(width/2 - 250, height/2 - 150, 500, 300, 20);
  fill(0);
  textAlign(CENTER, TOP);
  textSize(20);
  text("RESUMEN MODO MANUAL", width/2, height/2 - 130);
  textSize(16);
  textAlign(LEFT, TOP);
  float y = height/2 - 90;
  
  // Calcular tiempo en modo manual
  long tiempoTranscurrido = millis() - tiempoInicioModoManual;
  int minutos = int(tiempoTranscurrido / 60000);
  int segundos = int((tiempoTranscurrido % 60000) / 1000);
  
  text("Autos que ingresaron: " + autosIngresadosModoManual, width/2 - 220, y);
  y += 40;
  text("Autos que salieron: " + autosSalidosModoManual, width/2 - 220, y);
  y += 40;
  text("Dinero ingresado: $" + nf(dineroIngresadoModoManual, 0, 2), width/2 - 220, y);
  y += 40;
  text("Tiempo en modo manual: " + minutos + " min " + segundos + " seg", width/2 - 220, y);
  
  // Botón cerrar
  fill(0, 150, 255);
  rect(width/2 - 60, height/2 + 100, 120, 35, 10);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(16);
  text("Cerrar", width/2, height/2 + 117);
}

// Dibuja el cartel de estacionamiento lleno
void dibujarCartelEstacionamientoLleno()
{
  if (!mostrarCartelLleno) return;
  
  fill(0, 150);
  rect(0, 0, width, height);
  fill(255, 0, 0);
  rect(width/2 - 180, height/2 - 70, 360, 140, 20);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(22);
  text("ESTACIONAMIENTO LLENO", width/2, height/2);
  
  if (millis() - tiempoCartelLleno > 5000)
  {
    mostrarCartelLleno = false;
  }
}

// Dibuja el panel lateral con botones
void dibujarPanelLateral()
{
  fill(50, 100);
  noStroke();
  rect(width * 39/50, 0, width * 11/50, height);
  fill(255);
  rect(340, 737, 650, 20);
  textSize(18);
  fill(0);
  text("Comunicaciones:", 410, 747);
}

// Dibuja los botones del menú según el modo activo
void dibujarBotones()
{
  if (!modoManual)
  {
    botonIngresar.dibujar();
    botonRetirar.dibujar();
    botonAgregarSocio.dibujar();
    botonAgregarPatente.dibujar();
    botonModoManual.dibujar();
    botonResumen.dibujar();
  }
  else
  {
    botonSalirModoManual.dibujar();
  }
  
  // Dibuja campo de texto si existe
  if (campoTexto != null)
  {
    campoTexto.dibujar();
  }
}

// Dibuja el indicador de modo manual activo
void dibujarIndicadorModoManual()
{
  if (!modoManual) return;
  
  fill(0, 180, 0);
  rect(10, 10, 260, 36, 8);
  fill(255);
  textAlign(LEFT, CENTER);
  textSize(16);
  text("MODO MANUAL ACTIVADO", 20, 28);
}

// Actualiza la fecha y hora
void dibujarFechaHora()
{
  // Actualizar solo cuando cambia el segundo
  if (second() != ultimoSegundo)
  {
    ultimoSegundo = second();
    // Fecha
    fechaActual = "Día: " + day() + "/" + month() + "/" + year();
    // Hora
    int h = hour();
    String sufijo = (h >= 12) ? "PM" : "AM";
    h = h % 12;
    if (h == 0) h = 12;
    horaActual = "Hora: " + nf(h, 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2) + " " + sufijo;
  }
  
  // Cuadro de fondo
  fill(0, 120);
  noStroke();
  rect(10, height - 70, 220, 60, 10);
  
  // Texto de fecha y hora
  fill(255);
  textAlign(LEFT, BOTTOM);
  textSize(16);
  text(fechaActual, 20, height - 40);
  text(horaActual, 20, height - 20);
}

// Dibuja el menú de selección de resumen
void dibujarMenuResumen()
{
  if (!mostrarMenuResumen) return;
  
  fill(0, 150);
  rect(0, 0, width, height);
  fill(255);
  rect(width/2 - 220, height/2 - 100, 440, 240, 20);
  fill(0);
  textAlign(CENTER, TOP);
  textSize(20);
  text("Seleccione período", width/2, height/2 - 80);
  botonDia.dibujar();
  botonSemana.dibujar();
  botonMes.dibujar();
  botonHistorico.dibujar();
  botonCerrarResumen.dibujar();
}

// Dibuja el cartel con las estadísticas
void dibujarCartelEstadisticas()
{
  if (!mostrarCartelEstadisticas) return;
  
  fill(0, 150);
  rect(0, 0, width, height);
  fill(255);
  rect(width/2 - 250, height/2 - 180, 500, 360, 20);
  fill(0);
  textAlign(CENTER, TOP);
  textSize(20);
  text("Resumen - " + tipoResumen, width/2, height/2 - 160);
  textSize(16);
  textAlign(LEFT, TOP);
  float y = height/2 - 120;
  text("Total de ingresos: " + totalIngresos, width/2 - 220, y);
  y += 35;
  text("Total de salidas: " + totalSalidas, width/2 - 220, y);
  y += 35;
  text("Dinero recaudado: $" + nf(dineroTotal, 0, 2), width/2 - 220, y);
  y += 35;
  text("Fecha del reporte: " + day() + "/" + month() + "/" + year(), width/2 - 220, y);
  fill(0, 150, 255);
  rect(width/2 - 60, height/2 + 130, 120, 35, 10);
  fill(255);
  textAlign(CENTER, CENTER);
  text("Cerrar", width/2, height/2 + 147);
}

// Dibuja las alertas de tiempo excedido
void dibujarAlertasTiempo()
{
  for (int i = 0; i < 8; i++)
  {
    if (lugares[i].ocupado)
    {
      float horas = lugares[i].calcularMinutosTranscurridos();
      if (horas > HORAS_ALERTA && !alertaMostrada[i])
      {
        // Mostrar alerta visual
        fill(255, 0, 0, 150);
        rect(posiciones[i][0] - 5, posiciones[i][1] - 5,
             posiciones[i][2] + 10, posiciones[i][3] + 10, 10);
        fill(255);
        textAlign(CENTER, CENTER);
        textSize(14);
        text(nf(horas, 0, 1) + "h", posiciones[i][0] + posiciones[i][2]/2, 
             posiciones[i][1] + posiciones[i][3] + 15);
      }
    }
    else
    {
      alertaMostrada[i] = false; // resetear cuando se libera
    }
  }
}

// Dibuja el mensaje temporal en pantalla
void dibujarMensajeTemporal()
{
  if (!mostrarMensaje) return;
  
  textSize(18);
  fill(0);
  textAlign(LEFT, CENTER);
  text(mensaje, 600, 747);
  
  if (millis() - tiempoInicio > duracionMensaje)
  {
    mostrarMensaje = false;
  }
}

public void mousePressed()
{
  // Si hay cartel de pago abierto, solo permite cerrarlo
  if (mostrarCartel) //Si está abierto el cartel de información, solo permite cerrarlo
  {
    if (mouseX > width/2 - 50 && mouseX < width/2 + 50 && mouseY > height/2 + 60 && mouseY < height/2 + 90)
    {
      mostrarCartel = false;
    }
    return;
  }
  // Cerrar cartel resumen modo manual
  if (mostrarCartelResumen)
  {
    if (mouseX > width/2 - 60 && mouseX < width/2 + 60 && mouseY > height/2 + 100 && mouseY < height/2 + 135)
    {
      mostrarCartelResumen = false;
    }
    return;
  }
  // Cerrar menú de resumen
  if (mostrarMenuResumen)
  {
    if (botonDia.estaSobre(mouseX, mouseY))
    {
      calcularEstadisticas("DIA");
      mostrarMenuResumen = false;
      mostrarCartelEstadisticas = true;
    }
    else if (botonSemana.estaSobre(mouseX, mouseY))
    {
      calcularEstadisticas("SEMANA");
      mostrarMenuResumen = false;
      mostrarCartelEstadisticas = true;
    }
    else if (botonMes.estaSobre(mouseX, mouseY))
    {
      calcularEstadisticas("MES");
      mostrarMenuResumen = false;
      mostrarCartelEstadisticas = true;
    }
    else if (botonHistorico.estaSobre(mouseX, mouseY))
    {
      calcularEstadisticas("HISTORICO");
      mostrarMenuResumen = false;
      mostrarCartelEstadisticas = true;
    }
    else if (botonCerrarResumen.estaSobre(mouseX, mouseY))
    {
      mostrarMenuResumen = false;
    }
  return;
  }

// Cerrar cartel de estadísticas
  if (mostrarCartelEstadisticas)
  {
    if (mouseX > width/2 - 60 && mouseX < width/2 + 60 && mouseY > height/2 + 130 && mouseY < height/2 + 165)
    {
      mostrarCartelEstadisticas = false;
    }
  return;
  }

  // Si modoManual está activo solo permitimos presionar botonSalirModoManual
  if (modoManual)
  {
    if (botonSalirModoManual.estaSobre(mouseX, mouseY))
    {
      desactivarModoManual();
    }
    return;
  }

  // Si no está en modo manual procede con los botones normales
  if (botonIngresar.estaSobre(mouseX, mouseY))
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
  else if (botonRetirar.estaSobre(mouseX, mouseY))
  {
    key = '2';
    keyPressed();
  }
  else if (botonAgregarSocio.estaSobre(mouseX, mouseY))
  {
    key = '3';
    keyPressed();
  }
  else if (botonAgregarPatente.estaSobre(mouseX, mouseY))
  {
    key = '4';
    keyPressed();
  }
  else if (botonModoManual.estaSobre(mouseX, mouseY))
  {
    activarModoManual();
  }
  else if (botonResumen.estaSobre(mouseX, mouseY))
  {
    mostrarMenuResumen = true;
  }
}

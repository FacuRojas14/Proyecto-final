// ===================== INCLUDES =====================
#include <LiquidCrystal.h>
#include <Servo.h>
#include <ParkingSystem.h>
#include <stdlib.h>
#include <string.h>

// ===================== CLASE LECTORBOTON =====================
class LectorBoton {
private:
  int pinAnalogico;
  
  enum Botones {
    btnRIGHT = 0,
    btnUP = 1,
    btnDOWN = 2,
    btnLEFT = 3,
    btnSELECT = 4,
    btnNONE = 5
  };

public:
  // Constructor
  LectorBoton(int pin) {
    pinAnalogico = pin;
  }
  
  // Leer el botón presionado
  int leer() {
    int valor = analogRead(pinAnalogico);
    
    if (valor < 50)         return btnRIGHT;
    else if (valor < 150)   return btnUP;
    else if (valor < 350)   return btnDOWN;
    else if (valor < 550)   return btnLEFT;
    else if (valor < 800)   return btnSELECT;
    else                    return btnNONE;
  }
  
  // Métodos para verificar botones específicos
  bool esArriba() { return leer() == btnUP; }
  bool esAbajo() { return leer() == btnDOWN; }
  bool esIzquierda() { return leer() == btnLEFT; }
  bool esDerecha() { return leer() == btnRIGHT; }
  bool esSeleccionar() { return leer() == btnSELECT; }
  bool ningunBoton() { return leer() == btnNONE; }
  
  // Constantes públicas para comparación
  static const int ARRIBA = 1;
  static const int ABAJO = 2;
  static const int IZQUIERDA = 3;
  static const int DERECHA = 0;
  static const int SELECCIONAR = 4;
  static const int NINGUNO = 5;
};

// ===================== CLASE MOTORBARRERA =====================
class MotorBarrera {
private:
  Servo* servo;
  int pinLed;
  int anguloAbierto;
  int anguloCerrado;
  int anguloNegativo1;
  int anguloNegativo2;
  int tiempoAbierto;
  
public:
  // Constructor
  MotorBarrera(Servo* _servo, int _pinLed) {
    servo = _servo;
    pinLed = _pinLed;
    anguloAbierto = 90;
    anguloCerrado = 0;
    anguloNegativo1 = 60;
    anguloNegativo2 = 120;
    tiempoAbierto = 1000;
  }
  
  // Inicializar el motor
  void inicializar(int pin) {
    pinMode(pinLed, OUTPUT);
    servo->attach(pin);
    cerrar();
  }
  
  // Abrir la barrera
  void abrir() {
    servo->write(anguloAbierto);
    digitalWrite(pinLed, HIGH);
    delay(tiempoAbierto);
    cerrar();
  }
  
  // Cerrar la barrera
  void cerrar() {
    servo->write(anguloCerrado);
    digitalWrite(pinLed, LOW);
  }
  
  // Movimiento de negación (indicar error)
  void movimientoNegativo() {
    for (int i = 0; i < 3; i++) {
      servo->write(anguloNegativo1);
      delay(300);
      servo->write(anguloNegativo2);
      delay(300);
    }
    cerrar();
  }
  
  // Setters para personalizar el comportamiento
  void setAnguloAbierto(int angulo) { anguloAbierto = angulo; }
  void setAnguloCerrado(int angulo) { anguloCerrado = angulo; }
  void setTiempoAbierto(int tiempo) { tiempoAbierto = tiempo; }
};

// ===================== INCLUDES Y OBJETOS =====================
#include <ParkingSystem.h>
#include <LiquidCrystal.h>
#include <Servo.h>
#include <stdlib.h>
#include <string.h>

LiquidCrystal lcd(8, 9, 4, 5, 6, 7);
Servo servoBarrera;

ParkingSystem sistema(&lcd, &servoBarrera);
MotorBarrera motorBarrera(&servoBarrera, 4);
LectorBoton lectorBoton(A0);

// ===================== CONSTANTES Y DEFINICIONES =====================
const int maxLugares = 8;

// ===================== VARIABLES GLOBALES =====================
bool modoManual = false;
bool esperandoPC = false;
int opcionMenu = 0; // 0 = Entrada, 1 = Salida
int contadorAutos = 0;

// ===================== PROTOTIPOS DE FUNCIONES =====================
void volverAPantallaActual();
void mostrarLCD(const char* l1, const char* l2 = "", int t = 1500);
void ejecutarOpcionManual();
void leerMensajesSerial();

// Función wrapper para pasar a mostrarMenuClave
int leerBotonWrapper() {
  return lectorBoton.leer();
}

// ===================== SETUP =====================
void setup() {
  Serial.begin(9600);
  lcd.begin(16, 2);
  lcd.print("Sistema listo");
  delay(1500);
  lcd.clear();
  sistema.mostrarPantallaNormal(maxLugares - contadorAutos);
  motorBarrera.inicializar(2);
}

// ===================== LOOP =====================
void loop() {
  leerMensajesSerial();
  
  // --- Modo manual: usar menú con botones ---
  if (modoManual && !esperandoPC) {
    if (lectorBoton.esArriba()) {
      opcionMenu = 0;
      sistema.mostrarMenuManual(opcionMenu);
      delay(200);
    } else if (lectorBoton.esAbajo()) {
      opcionMenu = 1;
      sistema.mostrarMenuManual(opcionMenu);
      delay(200);
    } else if (lectorBoton.esSeleccionar()) {
      ejecutarOpcionManual();
      delay(200);
    }
  }
  delay(50);
}

// ===================== FUNCIONES =====================

// ---------- MOSTRAR PANTALLA PRINCIPAL ----------
void mostrarPantallaNormal() {
  sistema.mostrarPantallaNormal(maxLugares - contadorAutos);
}

// ---------- EJECUTAR OPCIÓN MANUAL ----------
void ejecutarOpcionManual() {
  lcd.clear();
  String tipoOperacion = "";
  
  if (opcionMenu == 0) {
    lcd.print("Ingreso manual");
    tipoOperacion = "ENTRADA_MANUAL";
  } else if (opcionMenu == 1) {
    lcd.print("Salida manual");
    tipoOperacion = "SALIDA_MANUAL";
  }
  
  delay(800);
  lcd.clear();
  lcd.print("Ingrese clave:");
  delay(800);
  lcd.clear();
  
  // Llamar al menú de clave y obtener la clave como String
  String clave = sistema.mostrarMenuClave(leerBotonWrapper);
  
  // Enviar la operación y la clave al PC
  if (clave.length() > 0) {
    if (tipoOperacion == "ENTRADA_MANUAL") {
      Serial.print("Entrada:");
      Serial.println(clave);
    } else if (tipoOperacion == "SALIDA_MANUAL") {
      Serial.print("Salida:");
      Serial.println(clave);
    }
    esperandoPC = true;
  }
  
  // Volver al menú principal manual
  lcd.clear();
  delay(800);
  sistema.mostrarMenuManual(opcionMenu);
}

// ===============   COMUNICACIÓN SERIAL   =================

void mostrarLCD(const char* l1, const char* l2, int t) {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(l1);
  lcd.setCursor(0, 1);
  lcd.print(l2);
  delay(t);
}

void volverAPantallaActual() {
  lcd.clear();
  if (modoManual) sistema.mostrarMenuManual(opcionMenu);
  else mostrarPantallaNormal();
}

void leerMensajesSerial() {
  if (Serial.available() == 0) return;
  
  String mensaje = Serial.readStringUntil('\n');
  mensaje.trim();
  
  // =================== MODOS ===================
  if (mensaje == "MODO_MANUAL") {
    modoManual = true;
    esperandoPC = false;
    mostrarLCD("Modo Manual ON", "");
    sistema.mostrarMenuManual(opcionMenu);
    return;
  }
  
  if (mensaje == "MODO_NORMAL") {
    modoManual = false;
    esperandoPC = false;
    mostrarLCD("Modo Normal", "");
    mostrarPantallaNormal();
    return;
  }
  
  // =================== ENTRADA ===================
  if (mensaje.startsWith("Lugar:")) {
    int lugar = mensaje.substring(6).toInt();
    esperandoPC = false;
    
    if (lugar > 0) {
      contadorAutos++;
      mostrarLCD("Lugar asignado:", String("Nro " + String(lugar)).c_str(), 1200);
      motorBarrera.abrir();
    } else {
      mostrarLCD("Estacionamiento", "LLENO", 1500);
    }
    
    volverAPantallaActual();
    return;
  }
  
  // =================== SALIDA ===================
  if (mensaje.startsWith("Salida:")) {
    int lugar = mensaje.substring(7).toInt();
    
    if (esperandoPC) {
      esperandoPC = false;
      
      if (lugar > 0) {
        contadorAutos--;
        mostrarLCD("Salida socio", (String("Lugar ") + lugar).c_str(), 1200);
        motorBarrera.abrir();
      } else {
        mostrarLCD("No encontrado", "Socio?", 1500);
      }
      
      volverAPantallaActual();
      return;
    }
    
    // Salida automática
    if (!modoManual) {
      if (contadorAutos > 0) contadorAutos--;
      mostrarLCD("Salida lugar", String(lugar).c_str(), 800);
      motorBarrera.abrir();
      mostrarPantallaNormal();
    }
    
    return;
  }
  
  // =================== SOCIOS ===================
  if (mensaje.startsWith("Socio:")) {
    String nombre = mensaje.substring(6);
    mostrarLCD("Bienvenido", nombre.c_str(), 2000);
    volverAPantallaActual();
    return;
  }
  
  if (mensaje.startsWith("SalidaSocio:")) {
    String nombre = mensaje.substring(12);
    mostrarLCD("Hasta luego", nombre.c_str(), 2000);
    volverAPantallaActual();
    return;
  }
  
  if (mensaje.startsWith("NoSocio:")) {
    esperandoPC = false;
    mostrarLCD("No existe", "El socio", 1200);
    motorBarrera.movimientoNegativo();
    volverAPantallaActual();
    return;
  }
  
  if (mensaje.startsWith("SocioNoEstacionado:")) {
    esperandoPC = false;
    mostrarLCD("El socio no", "esta adentro", 1500);
    motorBarrera.movimientoNegativo();
    volverAPantallaActual();
    return;
  }
  
  // =================== BACKUP ===================
  if (mensaje.startsWith("Ocupados:")) {
    contadorAutos = mensaje.substring(9).toInt();
    mostrarLCD("Backup cargado", String("Ocupados: " + String(contadorAutos)).c_str(), 2000);
    volverAPantallaActual();
    return;
  }
  
  // =================== PAGO ===================
  if (mensaje.startsWith("Pago:")) {
    float monto = mensaje.substring(5).toFloat();
    mostrarLCD("Monto: $", String(monto).c_str(), 1500);
    volverAPantallaActual();
    return;
  }
}
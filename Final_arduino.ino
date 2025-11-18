#include <ParkingSystem.h>
#include <LiquidCrystal.h>
#include <Servo.h>
#include <stdlib.h>
#include <string.h>


LiquidCrystal lcd(8, 9, 4, 5, 6, 7);
Servo barrera;

ParkingSystem sistema(&lcd, &barrera);


// ===================== CONFIGURACIÓN HARDWARE =====================
int numero =0;

// ===================== CONSTANTES Y DEFINICIONES =====================
#define btnRIGHT  0
#define btnUP     1
#define btnDOWN   2
#define btnLEFT   3
#define btnSELECT 4
#define btnNONE   5

const int maxLugares = 8;

// ===================== VARIABLES GLOBALES =====================
bool modoManual = false;
bool esperandoPC = false;

int opcionMenu = 0; // 0 = Entrada, 1 = Salida
int contadorAutos = 0;

int claveIngresada[6];
int cantidad = 0;
int posSeleccion = 0;
String ultimaClave = "";



// ===================== PROTOTIPOS DE FUNCIONES =====================
int leerBoton();
void volverAPantallaActual();
void mostrarLCD();
void ejecutarOpcionManual();
void leerMensajesSerial();
// ===================== SETUP =====================
void setup()
  {
   pinMode(4, OUTPUT);
    Serial.begin(9600);
    lcd.begin(16, 2);
    lcd.print("Sistema listo");
    delay(1500);
    lcd.clear();
    mostrarPantallaNormal();
    barrera.attach(2);
    barrera.write(0);
}

// ===================== LOOP =====================
void loop()
{
    leerMensajesSerial();

    // --- Modo manual: usar menú con botones ---
    if (modoManual && !esperandoPC)
    {
      int boton = leerBoton();
      if (boton == btnUP)
      {
        opcionMenu = 0;
        mostrarMenuManual();
        delay(200);
      }
      else if (boton == btnDOWN)
      {
        opcionMenu = 1;
        mostrarMenuManual();
        delay(200);
      }
      else if (boton == btnSELECT)
      {
        ejecutarOpcionManual();
        delay(200);
      }
    }
    delay(50);
}

// ===================== FUNCIONES =====================

// ---------- LECTURA DE BOTONES ----------
int leerBoton()
{
    int x = analogRead(A0);
    if (x < 50)         return btnRIGHT;
    else if (x < 150)   return btnUP;
    else if (x < 350)   return btnDOWN;
    else if (x < 550)   return btnLEFT;
    else if (x < 800)   return btnSELECT;
    else                return btnNONE;
}

// ---------- MOSTRAR PANTALLA PRINCIPAL ----------
void mostrarPantallaNormal()
{
    lcd.clear();
    lcd.print("Bienvenido");
    lcd.setCursor(0, 1);
    lcd.print("Lugares:");
    lcd.print(maxLugares - contadorAutos);
}

// ---------- MOSTRAR MENÚ MANUAL ----------
void mostrarMenuManual()
{
    lcd.clear();
    lcd.setCursor(0, 0);
    if (opcionMenu == 0) lcd.print("> Entrada");
    else lcd.print("  Entrada");
    lcd.setCursor(0, 1);
    if (opcionMenu == 1) lcd.print("> Salida");
    else lcd.print("  Salida");
}

// ---------- EJECUTAR OPCIÓN MANUAL ----------
void ejecutarOpcionManual()
{
   lcd.clear();

   String tipoOperacion = "";

   if (opcionMenu == 0)
   {
     lcd.print("Ingreso manual");
     tipoOperacion = "ENTRADA_MANUAL";
   }
   else if (opcionMenu == 1)
   {
     lcd.print("Salida manual");
     tipoOperacion = "SALIDA_MANUAL";
   }

   delay(800);

   // Mostrar el menú de clave
   lcd.clear();
   lcd.print("Ingrese clave:");
   delay(800);
   lcd.clear();

   // Reiniciar variables
   cantidad = 0;
   posSeleccion = 0;

   //  Llamar al menú de clave y obtener la clave como String
  String clave = mostrarMenuClave();

  //  Enviar la operación y la clave al PC
if (clave.length() > 0)
{
   if (tipoOperacion == "ENTRADA_MANUAL")
   {
     Serial.print("Entrada:");
     Serial.println(clave);
   }
   else if (tipoOperacion == "SALIDA_MANUAL")
   {
     Serial.print("Salida:");
     Serial.println(clave);
   }

   esperandoPC = true;
}


   // Volver al menú principal manual
   lcd.clear();
   delay(800);
   mostrarMenuManual();
}

void abrirno()
{

   for (int i = 0; i < 3; i++)
   {
     barrera.write(60);
     delay(300);
     barrera.write(120);
     delay(300);
   }
   barrera.write(0); // vuelve al centro
}

// ---------- ABRIR BARRERA ----------
void abrirBarrera()
  {
    barrera.write(90);
    digitalWrite(4, HIGH);
    delay(1000);
    barrera.write(0);
    digitalWrite(4, LOW);
  }

// ---------- MENÚ DE CLAVE NUMÉRICA ----------
String mostrarMenuClave()
{
   bool ingresando = true;
   posSeleccion = 0;
   cantidad = 0;
   unsigned long ultimaActualizacion = 0;
   bool visible = true;  // controla el parpadeo
   String claveFinal = "";

   while (ingresando)
   {
     // Hacemos parpadear el número cada 300 ms
     if (millis() - ultimaActualizacion > 300)
     {
       visible = !visible;
       ultimaActualizacion = millis();

       lcd.setCursor(0, 0);
       for (int i = 0; i < 10; i++)
       {
         if (i == posSeleccion && !visible)
           lcd.print(" ");
         else
           lcd.print(i);
       }

       // Mostrar clave ingresada en segunda línea
       lcd.setCursor(0, 1);
       lcd.print("Clave: ");
       for (int i = 0; i < cantidad; i++)
         lcd.print(claveIngresada[i]);
       lcd.print("   "); // limpiar restos
     }

     int boton = leerBoton();

     if (boton == btnRIGHT)
     {
       posSeleccion++;
       if (posSeleccion > 9) posSeleccion = 0;
       visible = true;
       ultimaActualizacion = millis();
       delay(250);
     }
     else if (boton == btnUP)
     {
       if (cantidad < 6)
       {
         claveIngresada[cantidad] = posSeleccion;
         cantidad++;
       }
       delay(250);
     }
     else if (boton == btnDOWN)
     {
       if (cantidad > 0) cantidad--;
       delay(250);
     }
     else if (boton == btnSELECT)
     {
       ingresando = false;
       delay(300);
     }
   }

   lcd.clear();

   //  Construir el string de clave
   for (int i = 0; i < cantidad; i++)
   {
     claveFinal += String(claveIngresada[i]);
   }

   return claveFinal;
}


// ===============   COMUNICACIÓN SERIAL   =================

void mostrarLCD(const char* l1, const char* l2 = "", int t = 1500) 
{
    lcd.clear();
    lcd.setCursor(0, 0); lcd.print(l1);
    lcd.setCursor(0, 1); lcd.print(l2);
    delay(t);
}

void volverAPantallaActual() 
{
    lcd.clear();
    if (modoManual) mostrarMenuManual();
    else mostrarPantallaNormal();
}

void leerMensajesSerial()
{
    if (Serial.available() == 0) return;

    String mensaje = Serial.readStringUntil('\n');
    mensaje.trim();

    // =================== MODOS ===================
    if (mensaje == "MODO_MANUAL")
     {
        modoManual = true;
        esperandoPC = false;
        mostrarLCD("Modo Manual ON", "");
        mostrarMenuManual();
        return;
    }

    if (mensaje == "MODO_NORMAL") 
    {
        modoManual = false;
        esperandoPC = false;
        mostrarLCD("Modo Normal", "");
        mostrarPantallaNormal();
        return;
    }

    // =================== ENTRADA ===================
    if (mensaje.startsWith("Lugar:"))
     {
        int lugar = mensaje.substring(6).toInt();
        esperandoPC = false;

        if (lugar > 0)
         {
            contadorAutos++;
            mostrarLCD("Lugar asignado:", String("Nro " + String(lugar)).c_str(), 1200);
            abrirBarrera();
        } else 
        {
            mostrarLCD("Estacionamiento", "LLENO", 1500);
        }

        volverAPantallaActual();
        return;
    }

    // =================== SALIDA ===================
    if (mensaje.startsWith("Salida:")) 
    {
        int lugar = mensaje.substring(7).toInt();

        if (esperandoPC) 
           {
            esperandoPC = false;

            if (lugar > 0) 
            {
                contadorAutos--;
                mostrarLCD("Salida socio", (String("Lugar ") + lugar).c_str(), 1200);
                abrirBarrera();
            } else {
                mostrarLCD("No encontrado", "Socio?", 1500);
            }

            volverAPantallaActual();
            return;
        }

        // Salida automática
        if (!modoManual) 
        {
            if (contadorAutos > 0) contadorAutos--;
            mostrarLCD("Salida lugar", String(lugar).c_str(), 800);
            abrirBarrera();
            mostrarPantallaNormal();
        }

        return;
    }

    // =================== SOCIOS ===================
    if (mensaje.startsWith("Socio:")) 
    {
        String nombre = mensaje.substring(6);
        mostrarLCD("Bienvenido", nombre.c_str(), 2000);
        volverAPantallaActual();
        return;
    }

    if (mensaje.startsWith("SalidaSocio:"))
     {
        String nombre = mensaje.substring(12);
        mostrarLCD("Hasta luego", nombre.c_str(), 2000);
        volverAPantallaActual();
        return;
    }

    if (mensaje.startsWith("NoSocio:"))
     {
        esperandoPC = false;
        mostrarLCD("No existe", "El socio", 1200);
        abrirno();
        volverAPantallaActual();
        return;
    }

    if (mensaje.startsWith("SocioNoEstacionado:")) 
    {
        esperandoPC = false;
        mostrarLCD("El socio no", "esta adentro", 1500);
        abrirno();
        volverAPantallaActual();
        return;
    }

    // =================== BACKUP ===================
    if (mensaje.startsWith("Ocupados:"))
     {
        contadorAutos = mensaje.substring(9).toInt();
        mostrarLCD("Backup cargado", String("Ocupados: " + String(contadorAutos)).c_str(), 2000);
        volverAPantallaActual();
        return;
    }

    // =================== PAGO ===================
    if (mensaje.startsWith("Pago:")) 
    {
        float monto = mensaje.substring(5).toFloat();
        mostrarLCD("Monto: $", String(monto).c_str(), 1500);
        volverAPantallaActual();
        return;
    }
}


#include <LiquidCrystal.h>

LiquidCrystal lcd(8, 9, 4, 5, 6, 7);

int contadorAutos = 0; // contador de autos actuales

const int maxLugares = 8;

void setup() 
{
Serial.begin(9600);
lcd.begin(16, 2);
lcd.print("Programa");
lcd.setCursor(0, 1);
lcd.print("cargado");
delay(2000);
lcd.clear();
lcd.print("Bienvenido");
}
void loop()
 {
if (Serial.available())
 {
String dato = Serial.readStringUntil('\n');
dato.trim();

// --- INGRESO ---

if (dato.startsWith("Lugar:")) 
{
  int lugar = dato.substring(6).toInt();
  if (contadorAutos < maxLugares)
   {
    contadorAutos++; // aumenta contador
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Ingrese al lugar");
    lcd.setCursor(0, 1);
    lcd.print(lugar);
    delay(500);

    lcd.clear();
    lcd.print("Bienvenido");
    lcd.setCursor(0, 1);
    lcd.print("Lugares:");
    lcd.print(8-contadorAutos);
  }

}



// --- SALIDA / PAGO ---

if (dato.startsWith("Pago:")) 
{
  int monto = dato.substring(5).toInt();
  if (contadorAutos > 0) contadorAutos--; // baja contador

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Monto a pagar:");
  lcd.setCursor(0, 1);
  lcd.print("$");
  lcd.print(monto);
  delay(500);

  lcd.clear();
  lcd.print("Gracias!");
  delay(2000);
  lcd.clear();
  lcd.print("Bienvenido");
  lcd.setCursor(0, 1);
  lcd.print("Lugares:");
  lcd.print(8-contadorAutos);
}

 if (contadorAutos >= maxLugares) 
 {
     serialEvent();
    else
    {
      Serial.println("LIBRE");
    }

}
void serialEvent(Serial p) {
  String respuesta = p.readStringUntil('\n');
  if (respuesta != null) {
    respuesta = trim(respuesta);
    println("Arduino dice: " + respuesta);

    if (respuesta.equals("LLENO")) {
      estacionamientoLleno = true;
    } else if (respuesta.equals("LIBRE")) {
      estacionamientoLleno = false;
    }
  }
}

}
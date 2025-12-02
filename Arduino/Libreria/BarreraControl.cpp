#include "BarreraControl.h"

// Constructor
BarreraControl::BarreraControl(Servo* servoBarrera, int led) {
	servo = servoBarrera;
	pinLed = led;
	anguloAbierto = 90;
	anguloCerrado = 0;
}

// Configurar la barrera
void BarreraControl::configurar(int pin, int anguloCerrado, int anguloAbierto) {
	this->anguloCerrado = anguloCerrado;
	this->anguloAbierto = anguloAbierto;
	
	servo->attach(pin);
	servo->write(anguloCerrado);
	
	pinMode(pinLed, OUTPUT);
	digitalWrite(pinLed, LOW);
}

// Abrir la barrera (abre, espera 1 segundo y cierra)
void BarreraControl::abrir() {
	servo->write(anguloAbierto);
	digitalWrite(pinLed, HIGH);
	delay(1000);
	servo->write(anguloCerrado);
	digitalWrite(pinLed, LOW);
}

// Movimiento de negación (como "abrirno" original)
void BarreraControl::moverNegacion() {
	for (int i = 0; i < 3; i++) {
		servo->write(60);
		delay(300);
		servo->write(120);
		delay(300);
	}
	servo->write(anguloCerrado);
}

#ifndef BARRERA_CONTROL_H
#define BARRERA_CONTROL_H

#include <Arduino.h>
#include <Servo.h>

class BarreraControl {
private:
	Servo* servo;
	int pinLed;
	int anguloAbierto;
	int anguloCerrado;
	
public:
	// Constructor
	BarreraControl(Servo* servoBarrera, int led = 4);
	
	// Métodos públicos
	void configurar(int pin, int anguloCerrado = 0, int anguloAbierto = 90);
	void abrir(); // Abre, espera 1 segundo y cierra (como tu función original)
	void moverNegacion(); // La función "abrirno" del código original
};

#endif

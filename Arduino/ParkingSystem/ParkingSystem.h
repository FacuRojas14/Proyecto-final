#ifndef ParkingSystem_h
#define ParkingSystem_h

#include <Arduino.h>
#include <LiquidCrystal.h>
#include <Servo.h>

class ParkingSystem {
public:
	ParkingSystem(LiquidCrystal *lcd, Servo *barrera);
	
	void mostrarPantallaNormal(int libres);
	void mostrarMenuManual(int opcionMenu);
	String mostrarMenuClave(int (*leerBoton)());
	
	void abrirBarrera();
	void abrirno();
	
private:
	LiquidCrystal *lcd;
	Servo *barrera;
};

#endif

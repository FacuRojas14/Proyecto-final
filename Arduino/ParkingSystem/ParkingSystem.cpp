#include "ParkingSystem.h"

ParkingSystem::ParkingSystem(LiquidCrystal *lcd, Servo *barrera) {
	this->lcd = lcd;
	this->barrera = barrera;
}

void ParkingSystem::mostrarPantallaNormal(int libres) {
	lcd->clear();
	lcd->print("Bienvenido");
	lcd->setCursor(0, 1);
	lcd->print("Lugares:");
	lcd->print(libres);
}

void ParkingSystem::mostrarMenuManual(int opcionMenu) {
	lcd->clear();
	lcd->setCursor(0, 0);
	lcd->print(opcionMenu == 0 ? "> Entrada" : "  Entrada");
	lcd->setCursor(0, 1);
	lcd->print(opcionMenu == 1 ? "> Salida" : "  Salida");
}

String ParkingSystem::mostrarMenuClave(int (*leerBoton)()) {
	int clave[6];
	int cantidad = 0;
	int pos = 0;
	bool visible = true;
	unsigned long tiempo = 0;
	
	while (true) {
		if (millis() - tiempo > 300) {
			visible = !visible;
			tiempo = millis();
			
			lcd->setCursor(0, 0);
			for (int i = 0; i < 10; i++) {
				if (i == pos && !visible) lcd->print(" ");
				else lcd->print(i);
			}
			
			lcd->setCursor(0, 1);
			lcd->print("Clave: ");
			for (int i = 0; i < cantidad; i++) lcd->print(clave[i]);
			lcd->print("   ");
		}
		
		int b = leerBoton();
		
		if (b == 0) { 
			pos = (pos + 1) % 10;
			visible = true;
			tiempo = millis();
			delay(250);
		}
		else if (b == 1) {
			if (cantidad < 6) clave[cantidad++] = pos;
			delay(250);
		}
		else if (b == 2) { 
			if (cantidad > 0) cantidad--;
			delay(250);
		}
		else if (b == 4) { 
			break;
		}
	}
	
	lcd->clear();
	
	String claveFinal = "";
	for (int i = 0; i < cantidad; i++) claveFinal += String(clave[i]);
	
	return claveFinal;
}

void ParkingSystem::abrirBarrera() {
	barrera->write(90);
	delay(1000);
	barrera->write(0);
}

void ParkingSystem::abrirno() {
	for (int i = 0; i < 3; i++) {
		barrera->write(60);
		delay(300);
		barrera->write(120);
		delay(300);
	}
	barrera->write(0);
}

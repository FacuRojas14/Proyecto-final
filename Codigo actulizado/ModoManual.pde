private void activarModoManual()
{
  modoManual = true;
  miArduino.write("MODO_MANUAL\n");
  teclasBloqueadas = true;
  mostrarEnPantalla("Modo manual activado - enviado a Arduino");
 
  // Resetear estadísticas
  autosIngresadosModoManual = 0;
  autosSalidosModoManual = 0;
  dineroIngresadoModoManual = 0;
  tiempoInicioModoManual = millis();
 
  guardarMarcaEnHistorial("==== MODO MANUAL ACTIVADO ====");
}

void desactivarModoManual()
{
  modoManual = false;
  miArduino.write("MODO_NORMAL\n");
  teclasBloqueadas = false;
  mostrarEnPantalla("Modo manual desactivado - enviado a Arduino");
 
  guardarMarcaEnHistorial("==== MODO MANUAL DESACTIVADO ====");
 
  // Mostrar cartel con resumen
  mostrarCartelResumen = true;

}

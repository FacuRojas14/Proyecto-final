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
void dibujarInfoHover()
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

// Actualiza y dibuja la fecha y hora
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

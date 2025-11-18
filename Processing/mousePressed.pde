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

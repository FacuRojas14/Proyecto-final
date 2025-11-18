int EntradaAuto(String nombre)
{
  int lugar = -1;
  for (int i = 0; i < 8; i++) 
  {
    if (!lugares[i].ocupado) 
    {
      lugares[i].registrarEntrada(nombre);
      actualizarEstadoEstacionamiento();
      lugar = i + 1;
      mostrarEnPantalla(" Auto ubicado en lugar " + lugar + " (" + nombre + ")" + "   Entrada: " + lugares[i].obtenerFechaHoraEntrada());
      
      // GUARDAR EN HISTORIAL - ENTRADA
      guardarEnHistorial(nombre, 0, "ENTRADA", lugar);
      
      // Contar ingreso si está en modo manual
      if (modoManual)
      {
        autosIngresadosModoManual++;
      }
      break;
    }
  }
  guardarBackup();
  return lugar;
}

int SalidaAuto(String nombre)
{
  int lugar = -1;
  
  // Buscar el lugar ocupado por ese socio o patente
  for (int i = 0; i < 8; i++)
  {
    if (lugares[i].ocupado && lugares[i].patente.equalsIgnoreCase(nombre))
    {
      lugar = i;
      break;
    }
  }
  
  if (lugar == -1)
  {
    mostrarEnPantalla("No se encontró el auto de " + nombre);
    return -1;
  }
  
  // Calcular tiempo y monto base
  float minutos = lugares[lugar].calcularMinutosTranscurridos();
  montoOriginal = minutos * 100.0;
  montoFinal = montoOriginal;
  
  // --- Aplicar descuento según modo ---
  if (!ingresoDesdeArduino)
  {
    // Modo manual: aplicar descuento si es socio
    cartelSocio = false;
    cartelNombreSocio = "";
    for (String[] s : socios)
    {
      for (int j = 1; j < s.length; j++)
      {
        if (s[j].equalsIgnoreCase(lugares[lugar].patente))
        {
          cartelSocio = true;
          cartelNombreSocio = s[0];
          montoFinal *= 0.85; // 15% descuento
        }
      }
    }
    
  } else {
    // Modo Arduino: marcar como socio con descuento
    cartelSocio = true;
    cartelNombreSocio = nombre;
    montoFinal *= 0.85; // 15% descuento
  }
  
  // GUARDAR EN HISTORIAL - SALIDA
  guardarEnHistorial(nombre, montoFinal, "SALIDA", lugar + 1);
  
  // Liberar lugar
  lugares[lugar].liberar();
  actualizarEstadoEstacionamiento();
  
  // Mostrar cartel solo si NO está en modo manual
  if (!modoManual)
  {
    mostrarCartel = true;
  }
  else  
  {
    // Acumular estadísticas para modo manual
    autosSalidosModoManual++;
    dineroIngresadoModoManual += montoFinal;
  }
  
  mostrarEnPantalla("Auto de " + nombre + "   retirado del lugar " + (lugar + 1)+ "   Tiempo: " + nf(minutos, 0, 2) + " minutos");
  
  // Resetear flag de ingreso desde Arduino
  ingresoDesdeArduino = false;
 
  guardarBackup();
  return lugar;
}

// Actualiza el estado de ocupación del estacionamiento
void actualizarEstadoEstacionamiento()
{
  estacionamientoLleno = true;
  for (int i = 0; i < lugares.length; i++)
  {
    if (!lugares[i].ocupado)
    {
      estacionamientoLleno = false;
      break;
    }
  }
}

void imprimirAutos(int i)
{
  if (lugares[i].ocupado)
  {
    PImage img; // variable temporal para la imagen
    if (i < 4) // dibuja los autos de arriba
    {
      if (i % 2 == 0) // si es par pone el auto de color rojo y si es impar pone el de color amarillo
      {
        img = auto_rojo_arriba;
      } else
      {
        img = auto_amarillo_arriba;
      }
    }
    else // dibuja los autos de abajo
    {
      if (i % 2 == 0)
      {
        img = auto_rojo_abajo;
      } else
      {
        img = auto_amarillo_abajo;
      }
    }
    image(img, posiciones[i][0], posiciones[i][1], posiciones[i][2], posiciones[i][3]); // dibuja el auto en la posicion ya establecida
  }
}

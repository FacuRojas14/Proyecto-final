// Verifica si existe el archivo de historial, si no lo crea
void verificarArchivoHistorial() 
{
  String[] lineas = loadStrings("historial.txt");
  if (lineas == null) 
  {
    // Crear archivo con encabezado
    String[] encabezado = {"Fecha;Hora;Patente;Tipo;Lugar;Monto"};
    saveStrings("historial.txt", encabezado);
    println("Archivo historial.txt creado.");
  }
}

// Guarda un registro de entrada o salida en el historial
void guardarEnHistorial(String patente, float monto, String tipo, int lugar)
{
  // Formato: dia/mes/año;hora:min:seg;patente;ENTRADA/SALIDA;lugar;monto
  String fecha = nf(day(), 2) + "/" + nf(month(), 2) + "/" + year();
  String hora = nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2);
  String montoStr = (tipo.equals("ENTRADA")) ? "-" : nf(monto, 0, 2);
  String registro = fecha + ";" + hora + ";" + patente + ";" + tipo + ";" + lugar + ";" + montoStr;
  
  String[] lineas = loadStrings("historial.txt");
  if (lineas == null) 
  {
    lineas = new String[0];
  }
  
  // Agregar la nueva línea
  lineas = append(lineas, registro);
  
  // Guardar todo de nuevo
  saveStrings("historial.txt", lineas);
  println(" Guardado en historial: " + registro);
}

// Guarda una marca especial en el historial (ej: activación de modo manual)
void guardarMarcaEnHistorial(String marca)
{
  String fecha = nf(day(), 2) + "/" + nf(month(), 2) + "/" + year();
  String hora = nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2);
  String registro = fecha + ";" + hora + ";" + marca;
  
  String[] lineas = loadStrings("historial.txt");
  if (lineas == null)
  {
    lineas = new String[0];
  }
  lineas = append(lineas, registro);
  saveStrings("historial.txt", lineas);
  println("️ Marca en historial: " + marca);
}

// Calcula las estadísticas según el período seleccionado
void calcularEstadisticas(String periodo)
{
  tipoResumen = periodo;
  totalIngresos = 0;
  totalSalidas = 0;
  dineroTotal = 0;
  int[] conteoLugares = new int[8];
  
  String[] lineas = loadStrings("historial.txt");
  if (lineas == null || lineas.length <= 1)
  {
    println("No hay datos en el historial");
    return;
  }
  
  int diaActual = day();
  int mesActual = month();
  int anioActual = year();
  
  for (int i = 1; i < lineas.length; i++)
  {
    String[] partes = split(lineas[i], ';');
    if (partes.length < 6) continue;
    if (partes[2].contains("====")) continue;
    
    String[] fecha = split(partes[0], '/');
    if (fecha.length != 3) continue;
    
    int dia = int(fecha[0]);
    int mes = int(fecha[1]);
    int anio = int(fecha[2]);
    
    boolean incluir = false;
    
    if (periodo.equals("DIA"))
    {
      incluir = (dia == diaActual && mes == mesActual && anio == anioActual);
    }
    else if (periodo.equals("SEMANA"))
    {
      int diasDiferencia = (anioActual - anio) * 365 + (mesActual - mes) * 30 + (diaActual - dia);
      incluir = (diasDiferencia >= 0 && diasDiferencia <= 7);
    }
    else if (periodo.equals("MES"))
    {
      incluir = (mes == mesActual && anio == anioActual);
    }
    else if (periodo.equals("HISTORICO"))
    {
      incluir = true;
    }
    
    if (incluir)
    {
      String tipo = partes[3].trim();
      if (tipo.equals("ENTRADA"))
      {
        totalIngresos++;
        int lugar = int(partes[4].trim()) - 1;
        if (lugar >= 0 && lugar < 8)
        {
          conteoLugares[lugar]++;
        }
      }
      else if (tipo.equals("SALIDA"))
      {
        totalSalidas++;
        // Reemplazar coma por punto para pasar correctamente
        String montoStr = partes[5].replace("$", "").replace(" ", "").replace(",", ".").trim();
        if (!montoStr.equals("-") && !montoStr.equals("") && montoStr.length() > 0)
        {
          try {
            float monto = float(montoStr);
            dineroTotal += monto;
          } catch (NumberFormatException e) {
            println("Error parseando: '" + montoStr + "'");
          }
        }
        int lugar = int(partes[4].trim()) - 1;
        if (lugar >= 0 && lugar < 8)
        {
          conteoLugares[lugar]++;
        }
      }
    }
  }
 
  println("=== RESUMEN " + periodo + " ===");
  println("Ingresos: " + totalIngresos);
  println("Salidas: " + totalSalidas);
  println("Dinero: $" + nf(dineroTotal, 0, 2));
}

void serialEvent(Serial p)
{
  String dato = p.readStringUntil('\n');
  if (dato != null)
  {
    dato = trim(dato);
    mostrarEnPantalla("Recibido: " + dato);
   
    // Arduino indica que entró la selección del usuario en el shield: ENTRADA_MANUAL o SALIDA_MANUAL
 if (dato.equalsIgnoreCase("LLENO"))
    {
      estacionamientoLleno = true;
      mostrarCartelLleno = true;
      tiempoCartelLleno = millis();
    } else if (dato.equalsIgnoreCase("LIBRE"))
    {
      estacionamientoLleno = false;
    }
    else if (dato.startsWith("SOCIO:"))
   {
      String nombre = dato.substring(6).trim();  // obtiene el nombre sin "SOCIO:"
      mostrarEnPantalla("Socio verificado: " + nombre);
      ingresoDesdeArduino = true;  
      //  Asignar un lugar automáticamente
      int lugarAsignado = EntradaAuto(nombre);  // esta función debe devolver un número
      // Enviar el número de lugar a Arduino
      miArduino.write("Lugar:" + lugarAsignado + "\n");
      mostrarEnPantalla("Enviado a Arduino → Lugar:" + lugarAsignado);
   }
   else if (dato.startsWith("Entrada:"))
{
  String codigoIngresado = dato.substring(8).trim(); // obtiene el código después de "Entrada:"
  mostrarEnPantalla("Código ingresado desde Arduino: " + codigoIngresado);
 
  // Buscar si el código pertenece a algún socio
  boolean encontrado = false;
  String nombreSocio = "";
 
  for (String[] s : socios)
  {
    if (s.length >= 2 && s[1].equals(codigoIngresado))
    {
      encontrado = true;
      nombreSocio = s[0];
      break;
    }
  }
 
  if (encontrado)
  {
    // Es un socio válido
    ingresoDesdeArduino = true;
   
    // Enviar confirmación de socio a Arduino
    miArduino.write("Socio:" + nombreSocio + "\n");
   
    // Asignar lugar
    int lugarAsignado = EntradaAuto(nombreSocio);
    miArduino.write("Lugar:" + lugarAsignado + "\n");
   
    mostrarEnPantalla("Socio encontrado: " + nombreSocio + " - Lugar: " + lugarAsignado);
  }
  else
  {
    // Código no válido
    miArduino.write("NoSocio:\n");
    mostrarEnPantalla("Código no válido: " + codigoIngresado);
  }
}
else if (dato.startsWith("Salida:"))
{
  String codigoIngresado = dato.substring(7).trim();
  mostrarEnPantalla("Código de salida ingresado desde Arduino: " + codigoIngresado);
 
  // Buscar si el código pertenece a algún socio
  boolean encontrado = false;
  String nombreSocio = "";
  String[] patentesSocio = null;  //GUARDAMOS TODO EL ARRAY
 
  for (String[] s : socios)
  {
    if (s.length >= 2 && s[1].equals(codigoIngresado))
    {
      encontrado = true;
      nombreSocio = s[0];
      patentesSocio = s;  //GUARDAMOS EL ARRAY COMPLETO
      break;
    }
  }
 
  if (encontrado)
  {
    //Buscar si ALGUNA DE LAS PATENTES del socio está estacionada
    int lugarEncontrado = -1;
    String patenteEncontrada = "";  
    for (int i = 0; i < 8; i++)
    {
      if (lugares[i].ocupado)
      {
        //Verificar si la patente estacionada pertenece al socio
        for (int j = 2; j < patentesSocio.length; j++)  // desde índice 2 porque [0]=nombre, [1]=código
        {
          if (patentesSocio[j].equalsIgnoreCase(lugares[i].patente))
          {
            lugarEncontrado = i;
            patenteEncontrada = lugares[i].patente;  //GUARDAMOS LA PATENTE
            break;
          }
        }
        if (lugarEncontrado != -1) break;
      }
    }
   
    if (lugarEncontrado != -1)
    {
      // Socio tiene un auto estacionado, procesar salida
      miArduino.write("SalidaSocio:" + nombreSocio + "\n");
     
      //USAMOS LA PATENTE, NO EL NOMBRE
      int lugar = SalidaAuto(patenteEncontrada);
      if (lugar != -1)
      {
        miArduino.write("Salida:" + (lugar + 1) + "\n");
        miArduino.write("Pago:" + int(montoFinal) + "\n");
      }
    }
    else
    {
      // Socio existe pero no tiene autos estacionados
      miArduino.write("SocioNoEstacionado:\n");
      mostrarEnPantalla("El socio " + nombreSocio + " no tiene autos estacionados");
    }
  }
  else
  {
    // Código no válido
    miArduino.write("NoSocio:\n");
    mostrarEnPantalla("Código no válido: " + codigoIngresado);
  }
}

  // Podés hacer alguna acción, por ejemplo mostrar mensaje en pantalla
}
}

public void keyPressed()
{
  if (teclasBloqueadas) return;  //Si está bloqueado, ignorar todo
  if (key =='9')
  {
    if (modoManual) desactivarModoManual();
    else activarModoManual();
    return;
  }

  // Si hay campo de texto activo
  if (campoTexto != null)
  {
    campoTexto.escribir(key);
    if (!campoTexto.activo)
    { // Enter presionado: procesar según estadoMenu
//=======================================================
      if (estadoMenu == 1)
      {
        patenteIngresada = campoTexto.texto;
        campoTexto = null;
        int lugarAsignado =EntradaAuto(patenteIngresada);
        // Enviar el número de lugar a Arduino
        miArduino.write("Lugar:" + lugarAsignado + "\n");
       
        estadoMenu = 0;
        return;
      }
//=======================================================
      else if (estadoMenu == 2)
      {
        int lugar = int(campoTexto.texto.trim()) - 1; // convertir texto a número (1–8 → 0–7)
        campoTexto = null;
        if (lugar < 0 || lugar >= 8) //Validamos lugar
        {
          mostrarEnPantalla("numero invalido");
          estadoMenu = 0;
          return;
        }
        if (!lugares[lugar].ocupado)
        {
          mostrarEnPantalla("Ese lugar ya está vacío.");
          estadoMenu = 0;
           return;
        }
        // Obtener el nombre asociado a ese lugar
        String nombre = lugares[lugar].patente;
        mostrarEnPantalla(" Retirando auto del lugar " + (lugar + 1) + " (" + nombre + ")");
        // Usamos la misma función que el modo manual
        int lugarLiberado = SalidaAuto(nombre);
        if (lugarLiberado != -1)
        {
          //Enviar al Arduino la salida y el monto
          miArduino.write("Salida:" + (lugarLiberado + 1) + "\n");
          miArduino.write("Pago:" + int(montoFinal) + "\n");
        }
        estadoMenu = 0;
        guardarBackup();
        return;
      }
//=======================================================
      else if (estadoMenu == 3)
      {
        nombreSocio = campoTexto.texto;
        mostrarEnPantalla("Nombre socio: " + nombreSocio);
        campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese codigo de  socio");
        estadoMenu = 10;
      }
//=======================================================
      else if (estadoMenu == 4)
{
  String patenteNueva = campoTexto.texto.trim();
 
  if (patenteNueva.equals(""))
  {
    // Usuario presionó ENTER sin escribir nada
    // Validar que tenga al menos UNA patente
    if (patenteExtra.equals(""))
    {
      mostrarEnPantalla("Debe ingresar al menos UNA patente");
      campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese al menos una patente");
      return;
    }
   
    // Agregar el socio con todas las patentes
    agregarSocio(nombreSocio, codigoSocio, patenteExtra);
    guardarSocios();
   
    int totalPatentes = split(patenteExtra, '|').length;
    mostrarEnPantalla(" Socio " + nombreSocio + " agregado con " + totalPatentes + " patente(s)");
   
    campoTexto = null;
    estadoMenu = 0;
  }
  else
  {
    // Agregar la patente a la lista
    if (patenteExtra.equals(""))
    {
      patenteExtra = patenteNueva;
      mostrarEnPantalla("Patente agregada: " + patenteNueva);
    } else {
      patenteExtra = patenteExtra + "|" + patenteNueva;
      int total = split(patenteExtra, '|').length;
      mostrarEnPantalla("Patente " + total + " agregada: " + patenteNueva);
    }
   
    // Pedir siguiente patente
    campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Otra patente (ENTER vacío para terminar)");
  }
}
//=======================================================
      else if (estadoMenu == 6)
      {
        nombreSocio = campoTexto.texto;
        campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese nueva patente");
        estadoMenu = 7; //PONER PORQUE LLAMAMOS A MENU=7
      }
//=======================================================
      else if (estadoMenu == 7)
      {
        patenteExtra = campoTexto.texto;
        agregarPatenteASocio(nombreSocio, patenteExtra);
        guardarSocios();
        campoTexto = null;
        estadoMenu = 0;
       
      }
//======================================================
else if (estadoMenu == 10)
{
  codigoSocio = campoTexto.texto;
  
  // VERIFICAR SI EL CÓDIGO YA EXISTE
  if (codigoSocioExiste(codigoSocio))
  {
    mostrarEnPantalla("ERROR: Ya existe un socio con ese código");
    campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese otro código de socio");
    return;  // Vuelve a pedir el código
  }
  
  mostrarEnPantalla("Código del socio: " + codigoSocio);
  patenteExtra = "";
  campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese patente (ENTER vacío para terminar)");
  estadoMenu = 4;
}
    }
    return;
  }

//=================MENÚ PRINCIPAL====================
if (estadoMenu == 0)
{
  if (key == '1')
  {
    if (estacionamientoLleno)
    {
      mostrarCartelLleno = true;
      tiempoCartelLleno = millis();
      return;
    }

    estadoMenu = 1;
    patenteIngresada = "";
    campoTexto = new CampoTexto(width * 4/5 + 20, height - 80, width * 9/50 - 40, 40, "Ingrese patente del auto");
  }
  else if (key == '2')
  {
    estadoMenu = 2;
    campoTexto = new CampoTexto(
      width * 4/5 + 20,
      height - 80,
      width * 9/50 - 40,40,"Ingrese número de lugar (1-8)");
  }
  else if (key == '3')
  {
    estadoMenu = 3;
    campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese nombre del socio");
  }
  else if (key == '4')
  {
    estadoMenu = 6;
    campoTexto = new CampoTexto(width* 4/5 + 20, height - 80, width* 9/50 - 40, 40, "Ingrese nombre del socio a modificar");
  }
  else
  {
    mostrarEnPantalla("Opción inválida.");
  }
  }
}

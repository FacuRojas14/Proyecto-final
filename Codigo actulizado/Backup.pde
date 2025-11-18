// Guarda el estado actual del estacionamiento en archivo
void guardarBackup()
{
  String[] lineas = new String[8];
  for (int i = 0; i < 8; i++)
  {
    lineas[i] = lugares[i].toBackupString();
  }
  saveStrings("backup.txt", lineas);
  println("Backup guardado correctamente.");
}

// Carga el estado del estacionamiento al iniciar el programa
void cargarBackup()
{
  String[] lineas = loadStrings("backup.txt");
  if (lineas == null)
  {
    println("No se encontró backup previo, iniciando vacío.");
    backupEnviado = true;
    return;
  }
 
  for (int i = 0; i < min(lineas.length, 8); i++)
  {
    lugares[i].fromBackupString(lineas[i]);
  }
  actualizarEstadoEstacionamiento();
 
  // Contar lugares ocupados al cargar
  lugaresOcupadosAlCargar = 0;
  for (int i = 0; i < 8; i++)
  {
    if (lugares[i].ocupado)
    {
      lugaresOcupadosAlCargar++;
    }
  }
  
  // Enviar a Arduino la cantidad de lugares ocupados
  if (lugaresOcupadosAlCargar > 0)
  {
    miArduino.write("Ocupados:" + lugaresOcupadosAlCargar + "\n");
    println("Enviado a Arduino: " + lugaresOcupadosAlCargar + " lugares ocupados");
  }
 
  println(" Backup cargado correctamente.");
}

// Carga la lista de socios desde el archivo socios.txt
void cargarSocios()
{
  socios.clear();
  String[] lineas = loadStrings("socios.txt");
  if (lineas == null) return;
  
  for (String l : lineas)
  {
    String[] partes = split(l, ';');
    if (partes.length >= 3) socios.add(partes);
  }
}

// Guarda la lista de socios en el archivo socios.txt
void guardarSocios()
{
  String[] lineas = new String[socios.size()];
  for (int i = 0; i < socios.size(); i++) 
  {
    lineas[i] = join(socios.get(i), ';');
  }
  saveStrings("socios.txt", lineas);
}

// Agrega un nuevo socio con su código y patentes
void agregarSocio(String nombre, String codigoSocio, String patentes)
{
  // Crear array: [nombre, código, patente1, patente2, ...]
  String[] patentesList = split(patentes, '|');
  String[] nuevo = {nombre, codigoSocio};
 
  // Agregar todas las patentes al array
  for (String pat : patentesList)
  {
    nuevo = append(nuevo, pat.trim());
  }
 
  socios.add(nuevo);
  println(" Socio guardado: " + nombre + " | Código: " + codigoSocio + " | Patentes: " + (nuevo.length - 2));
}

// Agrega una patente adicional a un socio existente
void agregarPatenteASocio(String nombre, String nuevaPatente)
{
  for (String[] s : socios)
  {
    if (s[0].equalsIgnoreCase(nombre))
    {
      String[] actualizado = append(s, nuevaPatente);
      socios.set(socios.indexOf(s), actualizado);
      mostrarEnPantalla("Patente agregada correctamente a " + nombre);
      return;
    }
  }
  mostrarEnPantalla("No se encontró el socio con ese nombre.");
}


boolean codigoSocioExiste(String codigo)
{
  for (String[] s : socios)
  {
    if (s.length >= 2 && s[1].equalsIgnoreCase(codigo))
    {
      return true;
    }
  }
  return false;
}

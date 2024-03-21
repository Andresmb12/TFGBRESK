def filtrar_palabras_por_longitud(nombre_archivo):
    # Lista para almacenar las palabras filtradas
    palabras_filtradas = []

    # Abrir el archivo en modo lectura
    with open(nombre_archivo, 'r') as archivo:
        # Leer las líneas del archivo
        lineas = archivo.readlines()

        # Iterar sobre cada línea y filtrar las palabras
        for linea in lineas:
            # Eliminar los espacios en blanco al principio y al final de la línea
            palabra = linea.strip()

            # Verificar si la palabra tiene menos o igual de 8 letras
            if len(palabra) <= 8:
                # Agregar la palabra a la lista de palabras filtradas
                palabras_filtradas.append(palabra)

    # Abrir el archivo en modo escritura para sobrescribir su contenido
    with open(nombre_archivo, 'w') as archivo:
        # Escribir las palabras filtradas en el archivo
        archivo.write('\n'.join(palabras_filtradas))

# Nombre del archivo
nombre_archivo = '0_palabras_todas.txt'

# Llamar a la función para filtrar las palabras por longitud
filtrar_palabras_por_longitud(nombre_archivo)

import sys
from unidecode import unidecode

def quitar_tildes_y_palabras_de_una_letra(fichero):
    palabras_modificadas = []

    with open(fichero, 'r', encoding='utf-8') as f:
        for palabra in f:
            palabra = palabra.strip()
            if len(palabra) != 1:
                palabra_sin_tildes = unidecode(palabra)
                palabras_modificadas.append(palabra_sin_tildes)

    with open(fichero, 'w', encoding='utf-8') as f:
        f.write('\n'.join(palabras_modificadas))

    print("Tildes y palabras de una letra eliminadas. El archivo ha sido modificado correctamente.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Uso: python script.py archivo.txt")
        sys.exit(1)

    fichero = sys.argv[1]

    quitar_tildes_y_palabras_de_una_letra(fichero)
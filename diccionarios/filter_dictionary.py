# Este script me ha filtrado el diccionario creando otro fichero
# con una palabra por cada combinacion nº de letras, letra inicial
# gracias a ello, el bot no tendrá que buscar entre miles de palabras
# sino solo entre 180

def create_filtered_dictionary(input_file, output_file):
    word_cache = {} 
    with open(input_file, "r", encoding="utf-8") as f:
        for word in f:
            word = word.strip().lower()
            if 2 <= len(word) <= 8:
                starting_letter = word[0]
                size = len(word)

                # Verificar si la letra inicial existe en el diccionario
                if starting_letter not in word_cache:
                    word_cache[starting_letter] = {} # Crear un diccionario vacío para la letra inicial

                # Almacenar la palabra si no hay otra de la misma longitud para esa letra
                if size not in word_cache[starting_letter]:
                    word_cache[starting_letter][size] = word  

    with open(output_file, "w", encoding="utf-8") as f:
        for size in range(8, 1, -1):
            for letter in sorted(word_cache.keys()):
                if size in word_cache[letter]:  
                    f.write(word_cache[letter][size] + "\n")

input_file = "0_palabras_todas.txt"
output_file = "filtered_spanish_dictionary.txt"
create_filtered_dictionary(input_file, output_file)





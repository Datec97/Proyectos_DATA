""" PROYECTO: Herramienta de seguimiento de palabras clave en el buscador"""

""" Descripción: Se necesita conocer el orden de ranking de las palabras mas buscadas en el navegador, según un dominio."""
""" Estos datos se guardarán en una base de datos y se exportarán a excel! """
""" ######################################################################################################################### """

""" Ejercicio 1:  ""Creación del Menú de la app (en consola)"""

""" 
Debe contemplar las siguientes opciones:
[1] – Importar palabras clave
[2] – Mostrar palabras clave
[0] – Salir 
"""
## CREACIÓN DE FUNCIÓN muestra_menu() : 
def _menu():
    print('')
    print('-------- fuente: Kaggle --------')
    print('')
    print('[1] – Importar palabras clave')
    print('[2] – Mostrar palabras clave')
    print('[0] – Salir')
print




## Función de carga de palabras clave:
def load_keywds():
    ##generamos un array de elementos
    keywds = []
    ##Función para recorrer el fichero y trasnformar los saltos de linea a vacios ""
    try:
        with open('keywords.txt') as fichero:
            for kw in fichero:
                kw = kw.replace('\n', '')
                keywds.append(kw)
    except FileNotFoundError:
        print('No se encuentra el fichero keywords')
    return keywds


# Función que muestra las palabras clave. ------- #>
def muestra_keywds(keywds):
    contador_keywds = 0
    for kw in keywds:
        print(kw)
        contador_keywds += 1
        if contador_keywds == 20:
            contador_keywds = 0
            input('Mostrar más...')


# APP Principal
def run():
    keywords = []
    while True:
        _menu()
        opcion = input('Selecciona una opción > ')
        opcion = int(opcion)
        if opcion == 0:
            break
        elif opcion == 1:
            keywords = load_keywds()
        elif opcion == 2:
            muestra_keywds(keywords)
        else:
            print('Opción no válida')
if __name__ == '__main__':
    run()
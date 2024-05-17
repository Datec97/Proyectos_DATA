#Importación del archivo, que tiene la funcion-> "comprueba_keywords"
""" from ejercicio2.Function_Validador import Function_Validador """
""" PROYECTO: Herramienta de seguimiento de palabras clave en el buscador"""

""" Descripción: Se necesita conocer el orden de ranking de las palabras mas buscadas en el navegador, según un dominio."""
""" Estos datos se guardarán en una base de datos y se exportarán a excel! """
""" ######################################################################################################################### """

import requests
from bs4 import BeautifulSoup

def aparece_domain (link, dominio):
    encontrado = False

    fin = link.find('&')
    pagina = link[:fin]
    if dominio in pagina:
        encontrado = True
    return encontrado

def comprueba_keywords(kw, dominio):
    continuar = True
    start = 0
    posicion = 1
    encontrado = False
    while continuar and not encontrado:
        parametros = {'q': kw, 'start': start}
        resp = requests.get(f'https://www.google.com/search', params=parametros)
        if resp.status_code == 200:
            soup = BeautifulSoup(resp.text, 'lxml')
            div_principal = soup.find('div', {'id': 'main'})
            resultados = div_principal.find_all('div', class_='ZINbbc xpd O9g5cc uUPGi')
            for res in resultados:
                if res.div and res.div.a:
                    if aparece_domain(res.div.a['href'], dominio):
                        encontrado = True
                        break
                    else:
                        posicion += 1
            if not encontrado:
                footer = div_principal.find('footer')
                siguiente = footer.find('a', {'aria-label': 'Página siguiente'})
                if siguiente:
                    start += 10
                    if start == 100:
                        continuar = False
                else:
                    continuar = False
        else:
            continuar = False
    if not encontrado:
        posicion = 100
    return posicion



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
    print('[3] – validar palabras clave')
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
""" def run():
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
    run() """




    #funcion: vallidar_dominio

def run():
        keywords = []
        dominio = 'j2logo.com'

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
            elif opcion == 3:
                kw = input('Introduzca las palabras clave a comprobar > ')
                posicion = comprueba_keywords(kw, dominio)
                if posicion < 100:
                    print(f'Las keywords {kw} se han encontrado en la posición {posicion} para el dominio {dominio}')
                else:
                    print(f'De momento, las keywords {kw} no rankean para el dominio {dominio}')
            else:
                print('Opción no válida')
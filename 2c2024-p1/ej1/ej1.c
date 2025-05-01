#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej1.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - es_indice_ordenado
 */
bool EJERCICIO_1A_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - indice_a_inventario
 */
bool EJERCICIO_1B_HECHO = true;

/**
 * OPCIONAL: implementar en C
 */
bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador) {
	bool res = true;
	// creo un nuevo inventario con la vista que me dan
	item_t** inventarioSegunVista = malloc(tamanio * sizeof(item_t*));

	for(int i = 0; i < tamanio ; i++){
		inventarioSegunVista[i] = inventario[indice[i]];
	}

	// verifico que el orden sea correcto con el comparador
	for(int i = 0; i < tamanio - 1 ; i++){
		bool resComparacion = comparador(inventarioSegunVista[i], inventarioSegunVista[i+1]);
		res = res && resComparacion;
	}

	// libero memoria y devuelvo el resultado
	free(inventarioSegunVista);
	return res;
}

/**
 * OPCIONAL: implementar en C
 */
item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio) {
	// ¿Cuánta memoria hay que pedir para el resultado?
	item_t** resultado = malloc(tamanio * sizeof(item_t*));

	for(int i = 0; i < tamanio; i++){
		resultado[i] = inventario[indice[i]];
	}

	return resultado;
}

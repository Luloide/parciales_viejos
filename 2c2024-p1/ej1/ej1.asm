extern malloc

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ITEM_NOMBRE EQU 0
ITEM_FUERZA EQU 20
ITEM_DURABILIDAD EQU 24
ITEM_SIZE EQU 28

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.

global es_indice_ordenado
es_indice_ordenado:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; RDI = item_t**     inventario
	; RSI = uint16_t*    indice
	; DX = uint16_t     tamanio
	; RCX = comparador_t comparador
	;prologo
	push RBP
	mov RBP, RSP
	push RBX
	push R12 
	push R13
	push R14
	push R15
	sub RSP, 8; alineada

	;guardo mis parametros en regustros no volatiles
	mov RBX, RDI ;me guardo el inventario en otro lado asi pido la memoria necesaria para el nuevo inventario 
	mov R12, RSI ; guardo indice
	mov R13, RDX ; guardo tamanio
	mov R14, RCX

	;ahora pedir memoria para el nuevo inventario
	imul DX, ITEM_SIZE ; tamanio * item-size
	xor RDI, RDI
	mov DI, DX
	call malloc 
	mov R15, RAX
	xor R8, R8 ; i = 0

.nuevoInventarioRecorrer: ;guardo los valores del inventario al nuevo inventario segun la vista que me dieron
	cmp R8, R13 ; llegue al final de el arreglo
	je .comparar
	xor RDI, RDI
	mov R10, 2 ;dos bytes
	imul R10, R8 ; i*2
	mov DI, [R12 + R10] ; indice[i]
	imul DI, 8 ; RDI = indice i * 8 bytes
	mov R10, [RBX + RDI] ; R10 = inventario[indice[i]]
	mov R9, R8 ;R9 = i
	imul R9, 8; R9 = i * 8 bytes
	mov [R15 + R9], R10; inventarioSegunVIsta[indice[i]] = inventario[indice[i]]
	inc R8 ;i++
	jmp .nuevoInventarioRecorrer

.comparar:
	xor R8, R8 ; i = 0
	xor R9,R9 ; res = false
	dec R9; res = true
	dec R13

.recorroItemsYComparo:
	cmp R8, R13
	je .terminar
	; pongo los valores a comparar en los registros esperados
	mov RDX, R8
	imul RDX, 8 ; RDX = indice i * item size
	mov RDI, [R15 + RDX] ; RDI = inventarioSegunVista[i],
	add RDX, 8
	mov RSI, [R15 + RDX]; RSI = inventarioSegunVista[i+1],
	call R14
	and R9, RAX
	inc R8
	jmp .recorroItemsYComparo

.terminar:
	mov RAX, R9 ;retornar el res
	;mov RDI, R12;paso a free el puntero de inventario que cree y lo livero
	;call free 
	;epilogo
	add RSP, 8
	pop R15
	pop R14
	pop R13
	pop R12
	pop RBX
	pop RBP
	ret



;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**

global indice_a_inventario
indice_a_inventario:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; RDI = item_t**  inventario
	; RSI = uint16_t* indice
	; DX = uint16_t  tamanio

	;prologo
	push RBP
	mov RBP, RSP
	push RBX
	push R12 ;alineada
	push R13
	sub RSP, 8 ; alineada

	; guardo los registros no volatiles que voy a utilizar
	mov RBX, RDI
	mov R12, RSI 
	mov R13, RDX

	; primero calculo la cantidad de memoria que debo pedir
	mov RDI, RDX ; me guardo el tamao en el registro donde voy a llamar a malloc
	imul RDI, ITEM_SIZE ; tamanio * item size
	call malloc ; en RAX esta mi puntero a resultado
	xor R8,R8 ; i = 0

.loop:
	cmp R8, R13
	je .terminar
	xor RDI,RDI
	mov R10, 2 ; me guardo dos bytes
	imul R10, R8 ; i*2
	mov DI, [R12 + R10] ; indice[i]
	imul DI, 8 ; RDI = indice i * 8 bytes
	mov R10, [RBX + RDI] ; R10 = inventario[indice[i]]
	mov R9, R8 ;R9 = i
	imul R9, 8; R9 = i * 8 bytes
	mov [RAX + R9], R10; inventarioSegunVIsta[indice[i]] = inventario[indice[i]]
	inc R8 ;i++
	jmp .loop

.terminar:
	;epilogo
	add RSP, 8
	pop R13
	pop R12
	pop RBX
	pop RBP
	ret

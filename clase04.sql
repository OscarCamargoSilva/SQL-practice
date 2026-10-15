SELECT * FROM novedades; 

--Nivel 1: CASE sobre estaciones

--Ejercicio 1: Muestra nombre, validaciones y una columna demanda: 'Alta' (40.000 o más), 'Media' (20.000 a 39.999), 'Baja' (menos de 20.000) y 'Sin dato' si no hay validaciones. Ordena de mayor a menor. (30 filas; San Mateo debe decir 'Sin dato', no 'Baja')
SELECT nombre, validaciones_dia,
 	CASE WHEN validaciones_dia >= 40000 THEN 'Alta'
 		 WHEN validaciones_dia >= 20000 THEN 'Media'
 		 WHEN validaciones_dia < 20000 THEN 'Baja'
 		 ELSE 'Sin dato'
    END AS demanda
FROM estaciones
ORDER BY validaciones_dia DESC;



--Ejercicio 2: Cuenta cuántas estaciones hay en cada nivel de demanda y cuánto suman. Ordena Alta, Media, Baja, Sin dato (no alfabético). Pista: un CASE en el ORDER BY que convierta cada nivel en 1, 2, 3, 4. (4 filas: 7, 11, 11 y 1)
SELECT CASE WHEN validaciones_dia >= 40000 THEN 'Alta'
 		 WHEN validaciones_dia >= 20000 THEN 'Media'
 		 WHEN validaciones_dia < 20000 THEN 'Baja'
 		 ELSE 'Sin dato'
    END AS demanda, 
    COUNT(*) as num_estaciones, SUM(validaciones_dia) AS total
FROM estaciones
GROUP BY demanda
ORDER BY total DESC;

--Ejercicio 3: Clasifica las estaciones por fase de construcción según anio_apertura: 'Fase I' (2000 a 2002), 'Fase II' (2003 a 2006) y 'Fase III' (2007 en adelante). Por fase: número de estaciones y promedio de validaciones redondeado sin decimales. (3 filas)
SELECT CASE WHEN anio_apertura <= 2002 THEN 'Fase I'
			WHEN anio_apertura <= 2006 THEN 'Fase II'
			ELSE 'Fase III' END AS fase,
			COUNT(*), ROUND(AVG(validaciones_dia),0)
FROM estaciones
GROUP BY CASE WHEN anio_apertura <= 2002 THEN 'Fase I'
			WHEN anio_apertura <= 2006 THEN 'Fase II'
			ELSE 'Fase III' END;



SELECT CASE WHEN anio_apertura <= 2002 THEN 'Fase I'
			WHEN anio_apertura <= 2006 THEN 'Fase II'
			ELSE 'Fase III' END AS fase,
			COUNT(*), ROUND(AVG(validaciones_dia),0)
FROM estaciones
GROUP BY fase;

--Ejercicio 4: Por troncal: total de estaciones, número de portales y número de estaciones que no son portal, en tres columnas. Usa SUM(CASE ...) para las dos últimas, con tipo <> 'Portal' para la tercera. Luego mira la troncal G: ¿portales + no portales da el total? ¿Por qué no? (11 filas)
SELECT troncal, COUNT(*) AS num_estaciones, 
		SUM(CASE WHEN tipo = 'Portal' THEN 1 ELSE 0 END) AS num_portales,
		SUM(CASE WHEN tipo <> 'Portal' THEN 1 ELSE 0 END) AS num_no_portales
FROM estaciones
GROUP BY troncal;

-- En la troncal G se cuenta en las estaciones de la troncal, pero como los CASE estan usando la columna tipo, la estacion San Mateo tiene Null ese casilla

--Nivel 2: nulos y texto

--Ejercicio 5: Número de estaciones y total de validaciones por tipo, mostrando 'Sin dato' en lugar de NULL. (4 filas)
SELECT COALESCE(tipo, 'Sin dato'), COUNT(*) AS num_estaciones, SUM(validaciones_dia)
FROM estaciones
GROUP BY tipo;



--Ejercicio 6: De la tabla troncales, separa la letra ('B') y el nombre ('Autopista Norte') en dos columnas, y agrega cuántos caracteres tiene el nombre. Ordena por nombre más largo. (11 filas; la primera es Autopista Norte, con 15)
SELECT SPLIT_PART(troncal, ' - ', 1) AS letra, SPLIT_PART(troncal, ' - ', 2) AS troncal_nombre, 
		LENGTH(SPLIT_PART(troncal, ' - ', 2)) AS num_caracter
FROM troncales
ORDER BY num_caracter DESC;



--Ejercicio 7: De la tabla rutas, arma una etiqueta como B74 · Autopista Norte (35 buses), de la ruta con más buses a la de menos. Después, en otra consulta, comprueba que la primera letra de codigo siempre coincide con la letra de la troncal. (15 filas; y la comprobación debe contar 15)

SELECT *, codigo || ' · ' || troncal AS etiqueta
FROM rutas
ORDER BY buses DESC;


SELECT * FROM rutas
WHERE LEFT(troncal,1) = LEFT(codigo,1)
ORDER BY buses DESC;


--Ejercicio 8: Encuentra las estaciones cuyo nombre empieza por "Portal". ¿Coinciden con las de tipo = 'Portal'? Luego busca las que contienen "calle" en cualquier parte del nombre: pruébalo con LIKE '%calle%' y con ILIKE '%calle%'. (9; y luego 0 contra 5)
SELECT nombre FROM estaciones
WHERE nombre LIKE 'Portal%';

SELECT nombre FROM estaciones
WHERE tipo = 'Portal';


SELECT nombre FROM estaciones
WHERE nombre LIKE '%calle%';

SELECT nombre FROM estaciones
WHERE nombre ILIKE '%calle%';
--Son las mismas estaciones que empiezan por Portal y son de tipo portal 

--Nivel 3: la tabla novedades

--Ejercicio 9:Limpia las categorías. Paso a paso: (a) ¿cuántas categorías distintas hay tal como vienen? (b) ¿cuántas quedan con LOWER(TRIM(categoria))? (c) Usa el truco de los corchetes para ver cuál sobra y arréglalo con REPLACE. Al final, cuenta novedades por categoría limpia, de mayor a menor. (14 → 6 → 5 categorías; falla de puerta encabeza con 18)
SELECT * FROM novedades;

--(a)
SELECT DISTINCT(categoria) FROM novedades;


--(b)
SELECT DISTINCT(LOWER(TRIM(categoria))) FROM novedades;

--(c)
SELECT DISTINCT '[' || categoria || ']' FROM novedades;

SELECT *, REPLACE(LOWER(TRIM(categoria)), 'congestión', 'congestion') AS categoria_upd FROM novedades;


SELECT REPLACE(LOWER(TRIM(categoria)), 'congestión', 'congestion') AS categoria_upd, COUNT(*) AS num_novedades FROM novedades
GROUP BY categoria_upd 
ORDER BY num_novedades DESC;

--Ejercicio 10: Número de novedades por mes, en orden cronológico. ¿Va subiendo o bajando? (6 filas)
SELECT MONTH(fecha_hora) AS mes, COUNT(*) AS num_novedades
FROM novedades
GROUP BY mes
ORDER BY mes ASC;

--Ejercicio 11: Promedio de minutos_retraso: calcúlalo primero tal cual y luego con NULLIF para sacar los -1. ¿Cuánto cambia? Después hazlo por mes, con las dos columnas lado a lado. (1 fila, y luego 6 filas)
SELECT AVG(minutos_retraso) FROM novedades;

SELECT AVG(NULLIF(minutos_retraso, -1)) FROM novedades;

SELECT MONTH(fecha_hora) AS mes, ROUND(AVG(minutos_retraso),1) AS prom1, ROUND(AVG(NULLIF(minutos_retraso, -1)),1) AS prom2
FROM novedades
GROUP BY mes 
ORDER BY mes ASC;


--Ejercicio 12: Clasifica cada novedad por franja horaria según HOUR(fecha_hora): 'Pico mañana' (5 a 8), 'Valle' (9 a 15), 'Pico tarde' (16 a 19) y 'Noche' (el resto). Por franja: número de novedades y retraso promedio sin los -1. Extra: con ISODOW, compara entre semana contra fin de semana. (4 filas; y luego 2)
SELECT CASE WHEN HOUR(fecha_hora) <= 8 THEN 'Pico mañana'
			WHEN HOUR(fecha_hora) <= 15 THEN 'Valle'
			WHEN HOUR(fecha_hora) <= 19 THEN 'Pico tarde'
			ELSE 'Noche' END AS franja,
	   COUNT(*) AS num_novedades, ROUND(AVG(NULLIF(minutos_retraso,-1)),1) AS retraso_prom
FROM novedades
GROUP BY franja;

SELECT CASE WHEN ISODOW(fecha_hora) <= 5 THEN 'Entre semana'
			ELSE 'Fin de semana' END AS dia_semana,
	   COUNT(*) AS num_novedades, ROUND(AVG(NULLIF(minutos_retraso,-1)),1) AS retraso_prom
FROM novedades
GROUP BY dia_semana;
			

--Nivel 4: todo junto

--Ejercicio 13: Muestra las 30 estaciones con el número de novedades que tuvieron en marzo de 2026, incluidas las que tuvieron 0. Ordena de más a menos. Piensa bien dónde va el filtro de fecha (sección 2.0). (30 filas; 23 con 0)
SELECT e.nombre, COUNT(n.novedad_id)
FROM estaciones AS e
LEFT JOIN novedades AS n
ON e.estacion_id = n.estacion_id AND MONTH(n.fecha_hora) = 3 AND YEAR(n.fecha_hora) = 2026
GROUP BY e.estacion_id,e.nombre;



--Ejercicio 14: Por troncal, partiendo de troncales con LEFT JOIN a estaciones y luego a novedades: número de novedades, total de minutos de retraso medidos (sin los -1, y 0 si no hay), fecha de la última novedad (MAX, sin la hora) y días desde esa novedad hasta el 30 de junio de 2026. Ordena por minutos. (11 filas; B - Autopista Norte encabeza)

SELECT t.troncal, COUNT(n.novedad_id) AS num_novedades, COALESCE(SUM(NULLIF(n.minutos_retraso,1)),0) AS suma_retraso,
		MAX(DATE(n.fecha_hora)) AS ultima_novedad, date_diff('days', ultima_novedad, DATE '2026-06-30') AS dias_ult_novedad
FROM troncales AS t
LEFT JOIN estaciones AS e
ON t.troncal = e.troncal
LEFT JOIN  novedades AS n
ON e.estacion_id =n.estacion_id
GROUP BY t.troncal
ORDER BY suma_retraso DESC;

SELECT * FROM troncales
SELECT * FROM novedades
SELECT * FROM estaciones
--Ejercicio 15: Reporte para el jefe de operación: una fila por mes y columnas sin_medir (-1), leves (0 a 9 min), moderadas (10 a 29), graves (30 o más) y total. Comprueba que las cuatro primeras suman el total en cada mes. (6 filas)

SELECT MONTH(fecha_hora) AS mes, 
		SUM(CASE WHEN minutos_retraso = -1 THEN 1 ELSE 0 END) AS sin_medir,
		SUM(CASE WHEN minutos_retraso BETWEEN 0 AND 9 THEN 1 ELSE 0 END) AS leves,
		SUM(CASE WHEN minutos_retraso BETWEEN 10 AND 29 THEN 1 ELSE 0 END) AS moderadas,
		SUM(CASE WHEN minutos_retraso >= 30 THEN 1 ELSE 0 END) AS graves,
		COUNT(*) AS total 
FROM novedades
GROUP BY mes
ORDER BY mes;

--Detective: encuentra el error. Ejecuta cada una, mira el resultado raro y corrígela.

-- D1: la idea era clasificar la demanda en Alta / Media / Baja
SELECT CASE
           WHEN validaciones_dia >= 20000 THEN 'Media'
           WHEN validaciones_dia >= 40000 THEN 'Alta'
           ELSE 'Baja'
       END AS demanda,
       COUNT(*) AS estaciones
FROM estaciones
GROUP BY demanda;

--Los condicionales no estan puestos de manera excluyente
SELECT CASE
		   WHEN validaciones_dia >= 40000 THEN 'Alta'
           WHEN validaciones_dia >= 20000 THEN 'Media'
           ELSE 'Baja'
       END AS demanda,
       COUNT(*) AS estaciones
FROM estaciones
GROUP BY demanda;


-- D2: la idea era ver LAS 30 estaciones con su número de fallas de puerta (0 si no tienen)
SELECT e.nombre, COUNT(n.novedad_id) AS fallas
FROM estaciones AS e
LEFT JOIN novedades AS n ON n.estacion_id = e.estacion_id
WHERE LOWER(TRIM(n.categoria)) = 'falla de puerta'
GROUP BY e.nombre
ORDER BY fallas DESC;

--Cuando el condicional se aplica sobre la segunda tabla se debe especificar en el ON

SELECT e.nombre, COUNT(n.novedad_id) AS fallas
FROM estaciones AS e
LEFT JOIN novedades AS n ON n.estacion_id = e.estacion_id AND LOWER(TRIM(n.categoria)) = 'falla de puerta'
GROUP BY e.nombre
ORDER BY fallas DESC;

-- D3: ¿cuántas fallas de puerta hubo en el semestre?
SELECT COUNT(*) AS fallas
FROM novedades
WHERE categoria = 'Falla de puerta';

--La categoria 'Falla de puerta' esta escrita de diferentes maneras, entones es mejor normalizar

SELECT COUNT(*) AS fallas
FROM novedades
WHERE LOWER(TRIM(categoria)) = 'falla de puerta';




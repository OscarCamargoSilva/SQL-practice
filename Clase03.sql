--Nivel 1: INNER JOIN        


--Ejercicio 1: Muestra el nombre de cada estación, su troncal y la longitud_km de la troncal. Antes de ejecutar: ¿30 filas o menos? ¿Por qué? (29)
SELECT e.nombre AS estacion, e.troncal AS troncal, t.longitud_km AS longitud
FROM estaciones AS e
INNER JOIN troncales AS t
ON e.troncal = t.troncal;



--Ejercicio 2: Con el mismo JOIN: estaciones que abrieron después de que empezó su troncal (anio_apertura mayor que anio_inicio). Muestra nombre, troncal y los dos años. (2)
SELECT e.nombre, e.anio_apertura AS anio_estacion, t.anio_inicio AS anio_troncal
FROM estaciones AS e
INNER JOIN troncales AS t
ON e.troncal = t.troncal
WHERE anio_estacion > anio_troncal;


--Ejercicio 3: Muestra el nombre de cada estación con la zona de su localidad. ¿Qué estación desaparece y por qué? (29)
SELECT e.nombre, l.localidad
FROM estaciones AS e
INNER JOIN localidades AS l
ON e.localidad = l.localidad;


--Nivel 2: LEFT JOIN, FULL JOIN y lo que no tiene pareja


--Ejercicio 4: Repite el ejercicio 1 con LEFT JOIN. ¿Cuántas filas salen ahora? Luego filtra para ver solo la estación cuya troncal no está en troncales. (30, y después 1)
SELECT e.nombre AS estacion, e.troncal AS troncal, t.longitud_km AS longitud
FROM estaciones AS e
LEFT JOIN troncales AS t
ON e.troncal = t.troncal;


--Ejercicio 5: ¿Qué localidades de Bogotá no tienen ninguna estación en tu muestra? (6)
SELECT l.localidad
FROM localidades AS l
LEFT JOIN estaciones AS e
ON l.localidad = e.localidad
WHERE nombre IS NULL;


--Ejercicio 6: ¿Qué troncal de la tabla troncales no tiene estaciones en tu muestra? (1)
SELECT t.troncal
FROM troncales AS t
LEFT JOIN estaciones AS e
ON t.troncal = e.troncal
WHERE nombre IS NULL;


--Ejercicio 7: Haz un FULL JOIN entre estaciones y troncales. Predice primero el número de filas. Luego muestra solo las filas donde alguno de los dos lados quedó en NULL. (31, y después 2)
SELECT * FROM estaciones AS e
FULL JOIN troncales AS t
ON t.troncal = e.troncal;


--Nivel 3: JOIN + GROUP BY + HAVING


--Ejercicio 8: Por zona: número de estaciones y total de validaciones, de mayor a menor total. (4 filas)
SELECT l.zona, COUNT(*) AS num_estaciones, SUM(validaciones_dia) AS num_validaciones
FROM localidades AS l
JOIN estaciones AS e
ON l.localidad = e.localidad
GROUP BY l.zona
ORDER BY num_validaciones DESC;



--Ejercicio 9: Por troncal, partiendo de troncales con LEFT JOIN a estaciones: cuántas estaciones de la muestra tiene, cuántas tiene en total (estaciones_totales del archivo de troncales) y qué porcentaje cubre tu muestra, redondeado a 1 decimal. Hazlo primero con COUNT(*) y luego con COUNT(e.estacion_id). ¿Qué troncal cambia y por qué? (11 filas)
SELECT t.troncal, COUNT(*) AS estaciones_muestra, 
		t.estaciones_totales AS estaciones_totales, 	
		ROUND(100.0*COUNT(*)/t.estaciones_totales,1) AS porcentaje
FROM troncales AS t
LEFT JOIN estaciones AS e
ON t.troncal = e.troncal
GROUP BY t.troncal, estaciones_totales
ORDER BY porcentaje DESC;


SELECT t.troncal, COUNT(e.estacion_id) AS estaciones_muestra, 
		t.estaciones_totales AS estaciones_totales, 	
		ROUND(100.0*COUNT(*)/t.estaciones_totales,1) AS porcentaje
FROM troncales AS t
LEFT JOIN estaciones AS e
ON t.troncal = e.troncal
GROUP BY t.troncal, estaciones_totales
ORDER BY porcentaje DESC;

--Ejercicio 10: Contando solo las estaciones abiertas en 2003 o después: por zona, número de estaciones y total de validaciones, mostrando solo las zonas con 3 estaciones o más. Decide qué filtro va en WHERE y cuál en HAVING. (3 filas)

SELECT l.zona, COUNT(*) AS num_estaciones, SUM(e.validaciones_dia) AS validaciones
FROM localidades AS l
LEFT JOIN estaciones AS e
ON l.localidad = e.localidad
WHERE e.anio_apertura >= 2003
GROUP BY l.zona
HAVING num_estaciones >= 3
ORDER BY validaciones DESC;


--Ejercicio 11: Por localidad: población, total de validaciones y validaciones por cada 1.000 habitantes, redondeado a 1 decimal, de mayor a menor. Pista: poblacion no es una agregación, así que tiene que ir también en el GROUP BY. (13 filas)
SELECT l.localidad, l.poblacion, SUM(e.validaciones_dia) AS validaciones, 
		ROUND(SUM(1000.0*e.validaciones_dia/l.poblacion),1) AS validaciones_1000
FROM localidades AS l
LEFT JOIN estaciones AS e
ON l.localidad = e.localidad
GROUP BY l.localidad, l.poblacion
HAVING validaciones IS NOT NULL
ORDER BY validaciones_1000 DESC;



--Nivel 4: el error que cuesta caro

--Ejercicio 12: Une estaciones con rutas por troncal. Primero predice y cuenta las filas. Luego calcula SUM(e.validaciones_dia) sobre ese JOIN y compáralo con el total real de la clase 2 (SELECT SUM(validaciones_dia) FROM estaciones;). ¿Por qué es tan distinto? (54 filas)
SELECT * FROM estaciones AS e
JOIN rutas AS r
ON r.troncal = e.troncal;

SELECT SUM(e.validaciones_dia) FROM estaciones AS e
JOIN rutas AS r
ON r.troncal = e.troncal;

--Ejericio 13: Pregunta de negocio: ¿qué troncal mueve más validaciones por bus? Usa la técnica de la sección 2.5: resume rutas a una fila por troncal en una subconsulta, únela con estaciones y calcula por troncal el total de validaciones, el total de buses y la división redondeada sin decimales. (9 filas)



SELECT e.troncal, SUM(validaciones_dia), s.total_buses, ROUND(SUM(validaciones_dia)/total_buses,0) AS validacion_bus
FROM estaciones AS e
JOIN (SELECT troncal, SUM(buses) AS total_buses FROM rutas
GROUP BY troncal) AS s
ON e.troncal = s.troncal
GROUP BY e.troncal, s.total_buses
ORDER BY validacion_bus DESC;


--Ejercicio 14: Une las tres tablas estaciones, troncales y localidades con INNER JOIN y cuenta las filas. Luego repítelo con LEFT JOIN en los dos. Escribe en un comentario qué estaciones se pierden con INNER y en qué paso. (28 y 30)
SELECT * FROM estaciones AS e
JOIN troncales AS t
ON e.troncal = t.troncal
JOIN localidades AS l
ON e.localidad = l.localidad;


SELECT * FROM estaciones AS e
LEFT JOIN troncales AS t
ON e.troncal = t.troncal
LEFT JOIN localidades AS l
ON e.localidad = l.localidad;

--UNIVERSIDADES Y SAN MATEO

--Ejercicio 15: Con las tres tablas unidas: ¿qué troncales pasan por 2 zonas o más? Muestra la troncal y el número de zonas distintas. (3)



SELECT e.troncal, COUNT(DISTINCT l.zona) AS num_zonas
FROM estaciones AS e
JOIN localidades AS l
ON e.localidad = l.localidad
JOIN troncales AS t
ON e.troncal = t.troncal
GROUP BY e.troncal
HAVING num_zonas >= 2;

--Detective: encuentra el error. Ejecuta cada una, mira el error o el resultado raro, y corrígela.

-- D1
SELECT troncal, nombre, longitud_km
FROM estaciones
JOIN troncales ON estaciones.troncal = troncales.troncal;

--La columna troncal aparece en las dos tabalas con el mismo nombre, entonces el SELECT no sabe cuál mostrar, la mejor idea es usar alias
SELECT e.troncal, e.nombre, t.longitud_km
FROM estaciones AS e
JOIN troncales AS t ON e.troncal = t.troncal;


-- D2: la idea era ver TODAS las localidades con su número de portales (0 si no tienen)
SELECT l.localidad, COUNT(e.estacion_id) AS portales
FROM localidades AS l
LEFT JOIN estaciones AS e ON e.localidad = l.localidad
WHERE e.tipo = 'Portal'
GROUP BY l.localidad;


--El condicional se puede colocar en el ON para mostrar los valores en cero
SELECT l.localidad, COUNT(e.estacion_id) AS portales
FROM localidades AS l
LEFT JOIN estaciones AS e 
ON e.localidad = l.localidad
AND e.tipo = 'Portal'
GROUP BY l.localidad
ORDER BY portales DESC;


-- D3: alguien olvidó el ON. Cuenta las filas y explica el número
SELECT COUNT(*)
FROM estaciones, troncales;

--La longitud de estaciones es 30 y la de troncales 11,
--Se genera 11 filas de troncales por cada una de las 30 filas de estaciones, resultado 330
-- D3: 330 filas = 30 estaciones × 11 troncales. Sin condición, SQL empareja
--     cada fila con todas las de la otra tabla (producto cartesiano, o CROSS JOIN).
--     Arreglo: JOIN troncales AS t ON e.troncal = t.troncal → 29 filas.



-- Nivel 1: SELECT y ORDER BY

-- Ejercicio 1: Muestra todas las columnas de todas las estaciones.
SELECT * FROM estaciones;


-- Ejercicio 2: Muestra solo nombre y localidad.
SELECT nombre, localidad FROM estaciones;


-- Ejercicio 3: Muestra el nombre de las estaciones de la troncal A - Caracas
SELECT nombre  FROM estaciones WHERE troncal = 'A - Caracas';

-- Nivel 2: WHERE

--Ejercicio 4: Estaciones con más de 40.000 validaciones al día, de mayor a menor. (7)
SELECT * FROM estaciones
WHERE validaciones_dia > 40000
ORDER BY validaciones_dia DESC;

--Ejercicio 5: Todos los portales (tipo = 'Portal'), ordenados por validaciones de mayor a menor. (9)
SELECT * FROM estaciones
WHERE tipo = 'Portal'
ORDER BY validaciones_dia DESC;

--Ejercicio 6: Las 5 estaciones con más validaciones.

SELECT * FROM estaciones
ORDER BY validaciones_dia DESC 
LIMIT 5;


--Ejercicio 7: La lista de localidades, sin repetidos y en orden alfabético.

SELECT DISTINCT localidad FROM estaciones
ORDER BY localidad ASC;


--Nivel 3: combinar filtros

--Ejercicio 8: Estaciones de Usaquén o Chapinero con menos de 20.000 validaciones. Usa IN y AND. (2)
SELECT * FROM estaciones
WHERE localidad IN ('Usaquén', 'Chapinero') AND validaciones_dia < 20000;



--Ejercicio 9: Estaciones que abrieron entre 2003 y 2006, ordenadas por año y luego por nombre. (10)
SELECT * FROM estaciones
WHERE anio_apertura >= 2003 and anio_apertura <= 2006
ORDER BY anio_apertura, nombre ASC;

--Ejercicio 10:Estaciones cuyo nombre empieza por "Portal". (9)
SELECT * FROM estaciones
WHERE nombre LIKE '%Portal%';


--Ejercicio 11: Filas con datos faltantes en tipo o en validaciones_dia. (1)
SELECT * FROM estaciones
WHERE  tipo IS NULL OR validaciones_dia IS NULL;


--Nivel 4: pensar como analista

--Ejercicio 12: Las estaciones que ocupan los puestos 6 a 10 en validaciones. Usa OFFSET.
SELECT * FROM estaciones
ORDER BY validaciones_dia DESC 
Limit 5 OFFSET 5;

--Ejercicio 13: Pregunta de negocio: ¿cuál es la estación de tipo Sencilla más usada fuera de la troncal Caracas?
SELECT *  FROM estaciones
WHERE tipo = 'Sencilla' AND troncal NOT LIKE '%Caracas%'
ORDER BY validaciones_dia DESC
LIMIT 1;

--Ejercicio 14:Las 3 estaciones menos usadas. Revisa: ¿aparece San Mateo? ¿Por qué sí o por qué no?

SELECT * FROM estaciones
ORDER BY validaciones_dia ASC 
LIMIT 3;
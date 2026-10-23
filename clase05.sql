--Nivel 1: subconsulta que devuelve un valor

--Ejercicio 1: Muestra las estaciones que mueven más validaciones que el promedio del sistema, 
--de mayor a menor. Agrega una tercera columna promedio con el promedio redondeado 
--sin decimales (pista: la misma subconsulta, ahora en el SELECT). (14 filas; el promedio es 30.310)

SELECT nombre, validaciones_dia,
		ROUND((SELECT AVG(validaciones_dia) FROM estaciones),1) AS promedio
FROM estaciones
WHERE validaciones_dia > (SELECT AVG(validaciones_dia) FROM estaciones);



--Ejercicio 2: Encuentra la estación con más validaciones sin usar ORDER BY ni LIMIT. 
--Luego la de menos. Pregunta para pensar: ¿en qué caso esta forma es mejor 
--que ORDER BY ... LIMIT 1? (1 fila cada una)

SELECT * FROM estaciones 
WHERE validaciones_dia = (SELECT MAX(validaciones_dia) FROM estaciones);


SELECT * FROM estaciones 
WHERE validaciones_dia = (SELECT MIN(validaciones_dia) FROM estaciones);

--De esta manera en caso de que hayan filas con valores iguales los dos son mostrados, con LIMIT
--el sistema decide mostrar solo uno


--Nivel 2: subconsultas que devuelven listas

--Ejercicio 3: Con IN, cuenta cuántas estaciones tuvieron al menos una novedad. 
--Después, con NOT IN, lista las que nunca tuvieron, en orden alfabético.
-- ¿Suman 30? (16; y luego 14 filas)

SELECT COUNT(*) FROM estaciones
WHERE estacion_id IN (SELECT estacion_id FROM novedades);

SELECT COUNT(*) FROM estaciones
WHERE estacion_id NOT IN (SELECT estacion_id FROM novedades);


--Ejercicio 4: De la tabla localidades, muestra nombre, zona y población de las localidades 
--que tienen al menos un portal, de la más poblada a la menos. Después, las localidades 
--que no tienen ninguna estación. (9 filas; y luego 6, encabezadas por Ciudad Bolívar)

SELECT localidad, zona, poblacion FROM localidades
WHERE localidad IN (SELECT localidad FROM estaciones WHERE tipo = 'Portal')
ORDER BY poblacion DESC;

SELECT localidad, zona, poblacion FROM localidades
WHERE localidad NOT IN (SELECT localidad FROM estaciones WHERE tipo = 'Portal')
ORDER BY poblacion  DESC;


--Ejercicio 5: Con NOT EXISTS, encuentra las troncales de la tabla troncales que no tienen rutas. 
--Luego, las que no tienen estaciones en tu tabla estaciones. (2 filas; y luego 1)
SELECT * FROM troncales AS t
WHERE NOT EXISTS (SELECT 1 FROM rutas AS r WHERE t.troncal = r.troncal);


SELECT * FROM troncales AS t
WHERE NOT EXISTS (SELECT 1 FROM estaciones AS e WHERE t.troncal = e.troncal);

--Ejercicio 6: Lista las estaciones que mueven más validaciones que el promedio de su 
--propia troncal (subconsulta correlacionada), ordenadas por troncal. 
--Después mira la troncal G: ¿por qué Portal Sur no aparece si es la única de su 
--troncal con validaciones? (10 filas)


SELECT * FROM estaciones AS e1
WHERE e1.validaciones_dia > (SELECT AVG(validaciones_dia) FROM estaciones AS e2 
									WHERE e1.troncal = e2.troncal);



--Nivel 3: subconsulta en el FROM y WITH

--Ejercicio 7: ¿Cuántas novedades tiene en promedio cada estación? Calcúlalo de dos formas con una subconsulta
-- en el FROM: (a) solo con la tabla novedades; (b) partiendo de estaciones con LEFT JOIN, 
--para que las estaciones sin novedades cuenten como 0. ¿Cuál es la respuesta honesta a 
--la pregunta? (3,25 contra 1,73)

SELECT ROUND(AVG(num_novedades),2)  FROM 
		(SELECT estacion_id, COUNT(*) as num_novedades FROM novedades GROUP BY estacion_id) AS por_estacion;


SELECT ROUND(AVG(num_novedades),2)  FROM 
		(SELECT e.estacion_id, COUNT(n.novedad_id) AS num_novedades FROM estaciones AS e LEFT JOIN novedades AS n
			ON e.estacion_id = n.estacion_id
			GROUP BY e.estacion_id) AS por_estacion;



--Ejercicio 8: Reescribe la versión (b) del ejercicio 7 con WITH.
--Agrega el máximo y el mínimo de novedades por estación. (1 fila: 1,73 / 6 / 0)
WITH por_estacion AS (
		SELECT e.estacion_id, COUNT(n.novedad_id) AS num_novedades FROM estaciones AS e LEFT JOIN novedades AS n
			ON e.estacion_id = n.estacion_id
			GROUP BY e.estacion_id
)
SELECT ROUND(AVG(num_novedades),2), MAX(num_novedades), MIN(num_novedades )  FROM por_estacion;


--Ejercicio 9: Crea un CTE limpias con la tabla novedades ya limpia: la categoría como 
--la dejaste en el ejercicio 9 de la clase 4 y los minutos con NULLIF(minutos_retraso, -1). 
--Con un segundo CTE, resume por categoría: número de novedades y retraso promedio con un decimal. 
--En la consulta final, muestra solo las categorías cuyo retraso promedio supera el promedio general 
--(subconsulta escalar sobre limpias). (primero 5 filas; al final 3, encabezadas por manifestación con 66,5)
WITH nov_limp AS (SELECT REPLACE(LOWER(TRIM(categoria)), 'congestión', 'congestion') 
			AS categoria, NULLIF(minutos_retraso, -1) AS retraso FROM novedades),
     por_cat AS (SELECT categoria, COUNT(retraso) AS num_nov, ROUND(AVG(retraso),1) AS retraso_promedio FROM nov_limp
     			GROUP BY categoria)
SELECT * FROM por_cat
      WHERE retraso_promedio > (SELECT AVG(retraso) FROM nov_limp)
	  ORDER BY retraso_promedio DESC;


--Ejercicio 10: Reescribe el ejercicio 13 de la clase 3 (validaciones por bus) con dos CTE: 
--uno con validaciones por troncal desde estaciones y otro con buses por troncal desde rutas. 
--Únelos con LEFT JOIN para que salgan todas las troncales que tienen estaciones, incluso las
-- que no tienen rutas. (11 filas; A - Caracas encabeza con 3.779; E y J quedan con NULL)
WITH val_troncal AS (SELECT troncal, SUM(validaciones_dia) AS validaciones 
					        FROM estaciones
					        GROUP BY troncal),
	 bus_troncal AS (SELECT troncal, SUM(buses) as num_buses
	 						FROM rutas
	 						GROUP BY troncal)
SELECT val_troncal.troncal, validaciones, num_buses FROM val_troncal 
	LEFT JOIN bus_troncal 
	ON val_troncal.troncal = bus_troncal.troncal 
	ORDER BY validaciones DESC;
					        

--Nivel 4: todo junto

--Ejercicio 11: Para cada mes, ¿qué estación tuvo más novedades? Pasos: un CTE que cuente 
--novedades por mes y estación (con el nombre), otro que saque el máximo de cada mes, y una 
--consulta final que los una por mes y por número de novedades. Mira enero y junio: ¿qué pasa 
--cuando hay empate? (9 filas para 6 meses)
WITH nov_mes AS (SELECT MONTH(n.fecha_hora) AS mes, e.nombre as estacion, COUNT(*) AS num_nov
				 FROM novedades AS n
				 JOIN estaciones AS e
				 ON e.estacion_id = n.estacion_id
				 GROUP BY mes, estacion),
	 max_mes AS (SELECT mes, MAX(num_nov) AS max_nov
	 			 FROM nov_mes
	 			 GROUP BY mes)
SELECT n.mes, n.estacion, n.num_nov 
FROM nov_mes AS n
JOIN max_mes AS m
ON m.mes = n.mes
AND m.max_nov = n.num_nov
ORDER BY n.mes, n.estacion;
				

--Ejercicio 12: Índice de novedades por troncal: número de novedades del semestre por cada 100.000
-- validaciones diarias, redondeado a un decimal. Columnas: troncal, validaciones, novedades 
--(0 si no tiene) e índice. Resume validaciones y novedades por separado antes de unir
-- (sección 2.6). Ordena de mayor a menor índice. 
--(11 filas; L - Carrera 10 encabeza con 16,9; Autopista Norte suma 175.900 validaciones, no más)

WITH val_troncal AS (SELECT troncal, SUM(validaciones_dia) AS validaciones FROM estaciones
							GROUP BY troncal),
	 nov_troncal AS (SELECT e.troncal, COUNT(*) AS num_nov FROM estaciones AS e
	 						JOIN novedades AS n
	 						ON n.estacion_id = e.estacion_id
	 						GROUP BY e.troncal)
SELECT v.troncal, v.validaciones, COALESCE(n.num_nov,0) AS novedades, ROUND((COALESCE(n.num_nov,0)/v.validaciones)*100000,1) AS indice
FROM val_troncal AS v
LEFT JOIN nov_troncal AS n
ON v.troncal = n.troncal 
ORDER BY indice DESC;




--Detective: encuentra el error. Ejecuta cada una, mira el resultado raro y corrígela.

-- D1: la idea era ver, por troncal, sus validaciones diarias y su número de novedades
SELECT e.troncal,
       SUM(e.validaciones_dia) AS validaciones,
       COUNT(n.novedad_id)     AS novedades
FROM estaciones AS e
LEFT JOIN novedades AS n ON n.estacion_id = e.estacion_id
GROUP BY e.troncal
ORDER BY validaciones DESC;

-- B - Autopista Norte sale con 741.800 validaciones y en realidad son 175.900.
--Cada estación se repite una vez por cada novedad que tuvo (Portal Norte, 6 veces),
--así que el SUM cuenta sus validaciones 6 veces. El COUNT sí está bien.

WITH val_troncal AS (SELECT  troncal, SUM(validaciones_dia) AS val_tot 
							 FROM estaciones
							 GROUP BY troncal),
	 nov_troncal AS (SELECT e.troncal, COUNT(n.novedad_id) AS num_nov
	 						 FROM novedades AS n
	 						 JOIN estaciones AS e
	 						 ON n.estacion_id = e.estacion_id
	 						 GROUP BY e.troncal)
SELECT v.troncal, v.val_tot, n.num_nov
FROM val_troncal AS v
JOIN nov_troncal AS n
ON v.troncal = n.troncal
ORDER BY v.val_tot DESC;



-- D2: ¿cuántas estaciones son de un tipo que NO existe en la troncal G - NQS Sur?
SELECT COUNT(*) AS estaciones
FROM estaciones
WHERE tipo NOT IN (SELECT tipo FROM estaciones WHERE troncal = 'G - NQS Sur');

-- D2: da 0. La troncal G tiene Portal Sur ('Portal') y San Mateo (NULL), así que la
--     lista es ('Portal', NULL) y el NOT IN nunca es verdadero (sección 2.2).

SELECT COUNT(*) AS estaciones
FROM estaciones
WHERE tipo NOT IN (SELECT tipo FROM estaciones
                   WHERE troncal = 'G - NQS Sur' AND tipo IS NOT NULL);   -- 20
-- 20 = 15 sencillas + 5 intermedias.
-- Con NOT EXISTS te sale 21: también cuenta a San Mateo, porque su tipo NULL no es
-- igual a nada. Que San Mateo cuente o no es una decisión: en un reporte dirías
-- "20 estaciones, más 1 sin tipo registrado".

-- D3: dos versiones de lo mismo, las dos con error.
-- Versión 1: estaciones por encima del promedio
SELECT nombre
FROM estaciones
WHERE validaciones_dia > AVG(validaciones_dia);

-- "WHERE clause cannot contain aggregates". En el paso 2 (WHERE) el
--promedio todavía no existe (sección 2.0). 

SELECT nombre
FROM estaciones
WHERE validaciones_dia > (SELECT AVG(validaciones_dia) FROM estaciones);

-- Versión 2: todas las estaciones de las troncales que tienen un portal de más de 50.000 validaciones
SELECT nombre, troncal
FROM estaciones
WHERE troncal = (SELECT troncal FROM estaciones
                 WHERE tipo = 'Portal' AND validaciones_dia > 50000);

-- "More than one row returned by a subquery". Hay 4 portales de más de
--     50.000 (Norte, Suba, Américas y Usme), así que la subconsulta devuelve 4 troncales
--     y el = solo sabe comparar contra un valor.

SELECT nombre, troncal
FROM estaciones
WHERE troncal IN (SELECT troncal FROM estaciones
                 WHERE tipo = 'Portal' AND validaciones_dia > 50000);
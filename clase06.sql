--Nivel 1: OVER y PARTITION BY (calcular sin colapsar)

--Ejercicio 1: Para cada estación muestra nombre, validaciones, el total del sistema en una columna total 
--y el porcentaje que representa la estación (pct_sistema, un decimal). Ordena de mayor a menor.
-- ¿Por qué el total da 879.000 y no incluye a San Mateo? (30 filas; Portal Norte 7,8 %)


SELECT nombre, validaciones_dia, SUM(validaciones_dia) OVER () AS total, 
		ROUND(validaciones_dia/total*100,1) AS pct_sistema
FROM estaciones
ORDER BY pct_sistema DESC;


--Ejercicio 2: Para cada estación muestra su troncal, sus validaciones, el promedio de su 
--troncal sin decimales y la diferencia contra ese promedio. Después, con un WITH, deja solo 
--las que están por encima del promedio de su troncal. Compáralo con el ejercicio 6 de la 
--clase 5: ¿da lo mismo? (30 filas; luego 10)

SELECT nombre, troncal, validaciones_dia,
		ROUND(AVG(validaciones_dia) OVER (PARTITION BY troncal),0) AS prom_troncal,
		(validaciones_dia - prom_troncal) AS diferencia
FROM estaciones
ORDER BY diferencia DESC;

WITH muestra1 AS (SELECT nombre, troncal, validaciones_dia,
						ROUND(AVG(validaciones_dia) OVER (PARTITION BY troncal),0) AS prom_troncal,
						(validaciones_dia - prom_troncal) AS diferencia
					FROM estaciones)
SELECT * FROM muestra1 
WHERE diferencia > 0
ORDER BY diferencia DESC;

--Ejercicio 3: Para cada estación calcula qué porcentaje de las validaciones de su troncal
-- mueve (pct_troncal, un decimal). Luego muestra solo las que mueven más de la mitad de su 
--troncal sin ser la única que cuenta. (30 filas; luego 5, encabezadas por Ricaurte con 76,1 %)

SELECT nombre, ROUND(100*validaciones_dia/(SUM(validaciones_dia) OVER (PARTITION BY troncal)),1) AS pct_troncal
FROM estaciones;

WITH part AS (SELECT nombre, ROUND(100*validaciones_dia/(SUM(validaciones_dia) OVER (PARTITION BY troncal)),1) AS pct_troncal
				FROM estaciones)
SELECT * FROM part 
WHERE pct_troncal BETWEEN 50.1 AND 99.9
ORDER BY pct_troncal DESC;

--Nivel 2: rankings

--Ejercicio 4: Numera las estaciones por número de vagones, de más a menos, con las tres 
--funciones a la vez: ROW_NUMBER, RANK y DENSE_RANK. Antes de ejecutar, predice qué número 
--le pone cada función a la primera estación de 3 vagones y a la última de la tabla. Después 
--agrega validaciones_dia DESC como desempate en el ROW_NUMBER y mira qué cambia. 
--(30 filas; 7, 7 y 2; 30, 16 y 3)

SELECT nombre, vagones, 
ROW_NUMBER() OVER (ORDER BY vagones DESC) AS fila,
RANK() OVER (ORDER BY vagones DESC) AS ranqueo,
DENSE_RANK() OVER (ORDER BY vagones DESC) AS rank_denso
FROM estaciones;

SELECT nombre, vagones, validaciones_dia,
ROW_NUMBER() OVER (ORDER BY vagones DESC, validaciones_dia DESC) AS fila
FROM estaciones
ORDER BY fila;


--Ejercicio 5: Haz el ranking de estaciones por validaciones dentro de cada troncal con RANK, ordenado por 
--troncal y puesto. Mira la troncal G: ¿en qué puesto queda San Mateo? ¿En qué puesto quedaría 
--en PostgreSQL? Escribe la versión que funcionaría igual en los dos motores. (30 filas)

SELECT nombre, troncal,
		RANK() OVER (PARTITION BY troncal ORDER BY validaciones_dia DESC) AS ranqueo
FROM estaciones
ORDER BY troncal, ranqueo;


SELECT nombre,troncal,
       validaciones_dia,
       RANK() OVER (PARTITION BY troncal ORDER BY validaciones_dia DESC NULLS LAST) AS puesto
FROM estaciones
ORDER BY troncal, puesto;

--Ejercicio 6: Las 2 estaciones con más validaciones de cada troncal (sección 2.3). 
--¿Por qué no salen 22 filas si hay 11 troncales? Después deja por fuera las estaciones 
--sin dato de validaciones. (19 filas; luego 18)

WITH filtro1 AS (SELECT nombre, troncal,
						ROW_NUMBER() OVER (PARTITION BY troncal ORDER BY validaciones_dia DESC) AS puesto
				 FROM estaciones
				 ORDER BY troncal, puesto)
SELECT * FROM filtro1 
WHERE puesto <= 2;

WITH filtro1 AS (SELECT nombre, troncal,
						ROW_NUMBER() OVER (PARTITION BY troncal ORDER BY validaciones_dia DESC) AS puesto
				 FROM estaciones
				 WHERE validaciones_dia IS NOT NULL
				 ORDER BY troncal, puesto)
SELECT * FROM filtro1 
WHERE puesto <= 2;


--Ejercicio 7: Reescribe el ejercicio 11 de la clase 5 (la estación con más novedades de cada mes)
-- con un CTE que cuente novedades por mes y estación y un RANK por mes. ¿Cuántas filas da?
-- Cambia RANK por ROW_NUMBER: ¿cuántas da ahora, y qué información perdiste? 
--(9 filas; con ROW_NUMBER, 6)

WITH conteo AS (SELECT MONTH(n.fecha_hora) AS mes, e.nombre,
				 		COUNT(*) AS num_nov
				 FROM estaciones AS e 
				 JOIN novedades AS n 
				 ON n.estacion_id = e.estacion_id
				 GROUP BY mes, e.nombre),
      ranking AS (SELECT *, 
      					RANK() OVER (PARTITION BY mes ORDER BY num_nov DESC) AS puesto
      			  FROM conteo)
SELECT * FROM ranking
WHERE puesto = 1
ORDER BY mes ASC, num_nov DESC;



--Nivel 3: LAG y LEAD

--Ejercicio 8: Novedades por mes con: el número del mes anterior, la variación absoluta y la 
--variación porcentual con un decimal. Agrega con LEAD el número del mes siguiente. ¿Qué mes
-- tuvo el mayor salto porcentual? (6 filas; febrero +133,3 %; abril -40,0 %)


WITH pas1 AS (SELECT MONTH(fecha_hora) AS mes, 
					 COUNT(*) AS num_nov
			  FROM novedades
			  GROUP BY mes 
			  ORDER BY mes),
	 pas2 AS (SELECT *, 
	 		  LAG(num_nov) OVER (ORDER BY mes) AS mes_anterior
	 		  FROM pas1)
SELECT *, (num_nov - mes_anterior) AS diff_abs,
		 ROUND(100*(num_nov - mes_anterior)/mes_anterior,1) AS porcentaje 
FROM pas2;


--Ejercicio 9: Retraso promedio por mes (sin los -1, como en la clase 4, con un decimal) y su 
--diferencia contra el mes anterior. Si te salen números como 0.3000000000000007, redondea
-- también la diferencia. ¿En qué mes empeoró más el retraso? 
--(6 filas; junio +9,3 minutos, con 23,0)

WITH paso1 AS (SELECT MONTH(fecha_hora) AS mes,
					  ROUND(AVG(NULLIF(minutos_retraso,-1)),1) AS  promedio
			   FROM novedades
			   GROUP BY mes
			   ORDER BY mes)
SELECT *, 
	   ROUND((promedio - (LAG(promedio) OVER (ORDER BY mes))),1) AS diferencia
FROM paso1
ORDER BY mes;

--Ejercicio 10: ¿Cada cuántos días tiene una novedad cada estación? Con LAG partido por estación, 
--trae la fecha de la novedad anterior de la misma estación y calcula los días entre una y otra 
--(date_diff('day', anterior, fecha_hora), de la clase 4). Luego, para las estaciones con al 
--menos 2 novedades, muestra cuántas tienen y los días promedio entre novedades (un decimal), 
--de menos a más días. (12 filas; Portal Tunal encabeza con 16,3 días)

WITH paso1 AS (SELECT e.nombre, n.fecha_hora, 
					  LAG(n.fecha_hora) OVER (PARTITION BY e.nombre ORDER BY n.fecha_hora) AS ult_fecha
			   FROM novedades AS n
			   LEFT JOIN estaciones AS e
			   ON n.estacion_id = e.estacion_id
			   ORDER BY e.nombre, n.fecha_hora),
	 paso2 AS (SELECT *, date_diff('day', ult_fecha, fecha_hora) AS dias_dif 
	 		   FROM paso1)
SELECT nombre, ROUND(AVG(dias_dif),1) AS promedio, COUNT(nombre) AS num_nov
FROM paso2 
GROUP BY nombre
HAVING num_nov >= 2
ORDER BY promedio ASC;

--Nivel 4: acumulados y ventanas móviles

--Ejercicio 11: Novedades por mes con el acumulado del semestre y el porcentaje acumulado 
--(un decimal). ¿En qué mes se llegó a la mitad de las novedades del semestre? (6 filas; 
--abril llega a 26 y 50,0 %)

--Opcion 1
WITH paso1 AS (SELECT MONTH(fecha_hora) AS mes, COUNT(*) as num_nov
			   FROM novedades
			   GROUP BY mes
			   ORDER BY mes),
     paso2 AS (SELECT *,
     			      SUM(num_nov) OVER (ORDER BY mes) AS acumulado,
	   				  SUM(num_nov) OVER () AS total
	   			FROM paso1)
SELECT mes, num_nov,acumulado,  100*ROUND(acumulado/total,1) AS porc_acumulado
FROM paso2;


--Opcion 2
WITH por_mes AS (
    SELECT strftime(fecha_hora, '%Y-%m') AS mes,
           COUNT(*) AS novedades
    FROM novedades
    GROUP BY mes
)
SELECT mes,
       novedades,
       SUM(novedades) OVER (ORDER BY mes) AS acumulado,
       ROUND(SUM(novedades) OVER (ORDER BY mes) * 100.0
             / SUM(novedades) OVER (), 1) AS pct_acumulado
FROM por_mes
ORDER BY mes;

--Ejercicio 12: Agrega al ejercicio 11 el promedio móvil de 3 meses (un decimal). 
--¿Por qué enero da 3,0 y febrero 5,0? ¿Qué cuenta el promedio móvil de junio que no 
--cuenta el número de junio solo? (6 filas; junio 10,7)

WITH por_mes AS (
    SELECT strftime(fecha_hora, '%Y-%m') AS mes,
           COUNT(*) AS novedades
    FROM novedades
    GROUP BY mes
)
SELECT mes,
       novedades,
       SUM(novedades) OVER (ORDER BY mes) AS acumulado,
       ROUND(SUM(novedades) OVER (ORDER BY mes) * 100.0
             / SUM(novedades) OVER (), 1) AS pct_acumulado,
       ROUND(AVG(novedades) OVER (ORDER BY mes
       								 ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),1) AS prom_movil
FROM por_mes
ORDER BY mes;


--Ejercicio 13: Pareto de las estaciones. Ordena las estaciones con dato de validaciones de mayor
-- a menor y calcula el porcentaje acumulado del total. ¿Cuántas estaciones mueven la mitad 
--de los pasajeros? Usa el marco ROWS explícito. (29 filas; con 9 estaciones se pasa del 50 %: 
--52,0 % en Portal Tunal)

SELECT nombre, validaciones_dia,
	   100*(SUM(validaciones_dia) OVER (ORDER BY validaciones_dia DESC))/(SUM(validaciones_dia) OVER ()) AS acumulado
FROM estaciones
WHERE validaciones_dia IS NOT NULL
ORDER BY validaciones_dia DESC;


--Detective: encuentra el error. Ejecuta cada una, mira el resultado raro (o el error) y corrígela.

-- D1: la estación con más validaciones de cada troncal
SELECT nombre, troncal, validaciones_dia
FROM estaciones
WHERE ROW_NUMBER() OVER (PARTITION BY troncal ORDER BY validaciones_dia DESC) = 1;


--La funcion Where no puede tener funciones windows

WITH paso1 AS (SELECT nombre, troncal, validaciones_dia, 
				      ROW_NUMBER() OVER (PARTITION BY troncal ORDER BY validaciones_dia DESC) AS puesto
				FROM estaciones)	
SELECT nombre, troncal, validaciones_dia
FROM paso1 
WHERE puesto =1;

-- D2: acumulado de validaciones, empezando por las estaciones con más vagones
SELECT nombre,
       vagones,
       validaciones_dia,
       SUM(validaciones_dia) OVER (ORDER BY vagones DESC) AS acumulado
FROM estaciones
ORDER BY vagones DESC;

--las 6 estaciones de 4 vagones muestran el mismo acumulado (334.300) y las 9 de
-- 3 vagones, 655.400. Con ORDER BY y sin marco, el marco es RANGE: todas las filas
-- empatadas en vagones se suman juntas (sección 2.5). Arreglo: desempate o ROWS.
SELECT nombre,
       vagones,
       validaciones_dia,
       SUM(validaciones_dia) OVER (ORDER BY vagones DESC, validaciones_dia DESC
                                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS acumulado
FROM estaciones
ORDER BY vagones DESC, validaciones_dia DESC;

SELECT nombre,
       vagones,
       validaciones_dia,
       SUM(validaciones_dia) OVER (ORDER BY vagones DESC, validaciones_dia DESC) AS acumulado
FROM estaciones
ORDER BY acumulado ASC;

-- D3: ¿las congestiones suben o bajan mes a mes?
WITH congestion AS (
    SELECT strftime(fecha_hora, '%Y-%m') AS mes,
           COUNT(*) AS novedades
    FROM novedades
    WHERE REPLACE(LOWER(TRIM(categoria)), 'congestion', 'congestión') = 'congestión'
    GROUP BY mes
)
SELECT mes,
       novedades,
       LAG(novedades) OVER (ORDER BY mes)             AS mes_anterior,
       novedades - LAG(novedades) OVER (ORDER BY mes) AS variacion
FROM congestion
ORDER BY mes;


--en abril no hubo congestiones, así que no hay fila de abril. Mayo sale comparado
--     con "mes_anterior" 3, que es MARZO, y la variación -2 es falsa. Arreglo: arma la
--     lista completa de meses, únela con LEFT JOIN y pon 0 donde no hubo novedades.
WITH meses AS (
    SELECT DISTINCT strftime(fecha_hora, '%Y-%m') AS mes
    FROM novedades
),
congestion AS (
    SELECT strftime(fecha_hora, '%Y-%m') AS mes,
           COUNT(*) AS novedades
    FROM novedades
    WHERE REPLACE(LOWER(TRIM(categoria)), 'congestion', 'congestión') = 'congestión'
    GROUP BY mes
),
completa AS (
    SELECT m.mes,
           COALESCE(c.novedades, 0) AS novedades
    FROM meses AS m
    LEFT JOIN congestion AS c ON c.mes = m.mes
)
SELECT mes,
       novedades,
       LAG(novedades) OVER (ORDER BY mes) AS mes_anterior,
       novedades - LAG(novedades) OVER (ORDER BY mes) AS variacion
FROM completa
ORDER BY mes;

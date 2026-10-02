--Nivel 1: agregados sobre toda la tabla

--Ejercicio 1: ¿Cuántas estaciones hay? (30)
SELECT COUNT(*) FROM estaciones;

--Ejercicio 2: En una sola consulta: COUNT(*), COUNT(validaciones_dia) y COUNT(tipo). ¿Por qué no dan lo mismo?
SELECT COUNT(*), COUNT(validaciones_dia), COUNT(tipo) FROM estaciones;

--Ejercicio 3: Total de validaciones diarias de todo el sistema.
SELECT SUM(validaciones_dia) FROM estaciones;


--Ejercicio 4: Promedio (redondeado, sin decimales), mínimo y máximo de validaciones en una sola consulta. Comprueba a mano: ¿el promedio es el total del ejercicio 3 dividido entre 30 o entre 29?
SELECT ROUND(AVG(validaciones_dia),0), MIN(validaciones_dia), MAX(validaciones_dia) FROM estaciones;



--Ejercicio 5: ¿Cuántas troncales distintas hay? ¿Y cuántas localidades? (14 localidades)
SELECT COUNT(DISTINCT troncal), COUNT(DISTINCT localidad) FROM estaciones;


--Nivel 2: GROUP BY

--Ejercicio 6: La pregunta de la clase 1: total de validaciones por troncal, de mayor a menor. (11 filas)
SELECT troncal, SUM(validaciones_dia) AS suma FROM estaciones
GROUP BY troncal
ORDER BY suma DESC;

--Ejercicio 7: Número de estaciones por tipo. ¿Qué pasa con San Mateo? (4 filas)
SELECT tipo, COUNT(tipo) AS cantidad FROM estaciones
GROUP BY tipo;
-- Los NULL forman su propio grupo: San Mateo aparece como una fila con tipo vacío.

--Ejercicio 8: Por localidad: número de estaciones y total de validaciones, ordenado por total de mayor a menor.
SELECT localidad, COUNT(*) AS num_estaciones, SUM(validaciones_dia) AS total_validaciones FROM estaciones
GROUP BY localidad 
ORDER BY total_validaciones DESC;


--Ejercicio 9: Promedio de validaciones por tipo, redondeado, sin incluir el grupo vacío. (3 filas)
SELECT tipo, ROUND(AVG(validaciones_dia),0) as promedio FROM estaciones
WHERE validaciones_dia IS NOT NULL
GROUP BY tipo
ORDER BY promedio DESC;




--Ejercicio 10: ¿Cuántas estaciones abrieron cada año? Ordénalo por año. (7 filas)
SELECT anio_apertura, COUNT(nombre) AS numero_estaciones FROM estaciones
GROUP BY anio_apertura 
ORDER BY anio_apertura ASC;

--Nivel 3: HAVING

--Ejercicio 11: Troncales con más de 100.000 validaciones al día en total. (3)
SELECT troncal, SUM(validaciones_dia) AS total FROM estaciones
GROUP BY troncal
HAVING total>100000
ORDER BY total DESC;


--Ejercicio 12: Localidades con 3 estaciones o más. (6)
SELECT localidad, COUNT(nombre) AS numero FROM estaciones
GROUP BY localidad 
HAVING numero >= 3
ORDER BY numero DESC, localidad;



--Ejercicio 13: Contando solo las estaciones Sencilla: troncales que tienen 3 sencillas o más. (2)
SELECT troncal, COUNT(nombre) AS numero FROM estaciones
WHERE tipo = 'Sencilla'
GROUP BY troncal 
HAVING numero >= 3
ORDER BY numero DESC;


--Nivel 4: pensar como analista

--Ejercicio 14: Pregunta de negocio: ¿qué troncal tiene más validaciones por vagón? Calcula por troncal SUM(vagones), SUM(validaciones_dia) y la división de las dos, redondeada. Luego repítela agregando WHERE validaciones_dia IS NOT NULL. ¿Qué troncal cambia de puesto y por qué?
SELECT troncal, SUM(validaciones_dia) AS validaciones,SUM(vagones) AS numero_vagones, SUM(validaciones_dia)/SUM(vagones) AS promedio
FROM estaciones
GROUP BY troncal
ORDER BY promedio DESC
LIMIT 1;



SELECT troncal, SUM(validaciones_dia) AS validaciones,SUM(vagones) AS numero_vagones, SUM(validaciones_dia)/SUM(vagones) AS promedio
FROM estaciones
WHERE validaciones_dia IS NOT NULL 
GROUP BY troncal
ORDER BY promedio DESC
LIMIT 1;

-- En 14a, SUM(vagones) cuenta los 2 vagones de San Mateo, pero SUM(validaciones_dia)
-- no suma nada por ella (es NULL). Divides validaciones de 1 estación entre vagones
-- de 2 estaciones y G - NQS Sur sale castigada. Un NULL no da error: te da un
-- número equivocado en silencio. Por eso un analista revisa los NULL antes de concluir.


--Ejercicio 15: Para las estaciones que abrieron en 2005 o antes, por tipo: cuántas son, el total de validaciones y la validación máxima. Muestra solo los tipos con al menos 3 estaciones, del mayor total al menor. (3 filas)

SELECT tipo, COUNT(*) AS cantidad, SUM(validaciones_dia) AS validaciones, MAX(validaciones_dia) AS maximo_validaciones FROM estaciones
WHERE anio_apertura <= 2005
GROUP BY tipo 
HAVING cantidad >= 3
ORDER BY cantidad DESC;

--Detective: encuentra el error. Ejecuta cada una, lee el mensaje de error y corrígela.
-- D1
SELECT troncal, nombre, SUM(validaciones_dia)
FROM estaciones
GROUP BY troncal;

--Al agrupar por troncal, la columna nombre debe tener una funcion agregada
SELECT troncal, COUNT(nombre) , SUM(validaciones_dia)
FROM estaciones
GROUP BY troncal;


-- D2
SELECT troncal, SUM(validaciones_dia)
FROM estaciones
WHERE SUM(validaciones_dia) > 100000
GROUP BY troncal;

-- WHERE no puede tener funciones agregadas, se debe cambiar por HAVING, por lo que debe cambiar el orden
SELECT troncal, SUM(validaciones_dia)
FROM estaciones
GROUP BY troncal
HAVING SUM(validaciones_dia) > 100000;




DROP TABLE IF EXISTS universidad;
DROP TABLE IF EXISTS concurso;
DROP TABLE IF EXISTS participantes;


CREATE TABLE universidad (
  id INT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  país VARCHAR(50) NOT NULL,
  ciudad VARCHAR(50) NOT NULL,
  dirección VARCHAR(100) NOT NULL
);

-- Create table concurso
CREATE TABLE concurso (
  id INT PRIMARY KEY,
  universidad INT NOT NULL,
  participante INT NOT NULL,
  año INT NOT NULL,
  puntuación INT NOT NULL,
  puesto INT NOT NULL,
  FOREIGN KEY (universidad) REFERENCES universidad(id),
  FOREIGN KEY (participante) REFERENCES participantes(id)
);

-- Create table participantes
CREATE TABLE participantes (
  id INT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  apellidos VARCHAR(50) NOT NULL,
  fnac DATE NOT NULL
);

-- Populate table universidad
INSERT INTO universidad (id, nombre, país, ciudad, dirección) VALUES
(1, 'Universidad de Politécnica de Valencia', 'España', 'Valencia', 'Camí de Vera'),
(2, 'Universidad de Politécnica de Madrid', 'España', 'Madrid', 'Pº Juan XXIII, 11'),
(3, 'Universidad de Salamanca', 'España', 'Salamanca', 'Patio de Escuelas Menores'),
(4, 'Universidad de Granada', 'España', 'Granada', 'Cuesta del Hospicio'),
(5, 'Universidad de Sevilla', 'España', 'Sevilla', 'Calle San Fernando'),
(6, 'Universidad de Barcelona', 'España', 'Barcelona', 'Gran Via de les Corts Catalanes');
-- Populate table participantes
INSERT INTO participantes (id, nombre, apellidos, fnac) VALUES
(101, 'Pedro', 'S', '1972-02-29'),
(102, 'Pablo', 'C', '1981-02-01'),
(103, 'Inés', 'A', '1981-07-03'),
(104, 'Alberto', 'G', '1985-10-09'),
(105, 'Santiago', 'A', '1976-04-14'),
(106, 'Andrés', 'Aldaz', '2001-06-26');

-- Populate table concurso
INSERT INTO concurso (id, universidad, participante, año, puntuación, puesto) VALUES
(1000, 1, 101, 2019, 90, 1),
(1001, 1, 101, 2020, 90, 1),
(1002, 2, 102, 2020, 85, 2),
(1003, 3, 101, 2020, 80, 3),
(1004, 3, 103, 2020, 80, 4),
(1005, 4, 104, 2020, 75, 5),
(1006, 4, 104, 2020, 75, 6),
(1007, 4, 104, 2020, 75, 7),
(1008, 3, 105, 2020, 75, 8),
(1009, 6, 106, 2020, 75, 9);

--Nombre de las universidades que nunca se han presentado a un concurso de programación.
SELECT nombre
FROM universidad
WHERE id NOT IN (
    SELECT DISTINCT universidad
    FROM concurso
)

-- Nombres y apellidos de participantes que han representado a más de una universidad.
SELECT nombre, apellidos
FROM participantes
WHERE id IN (
    SELECT participante
    FROM concurso
    GROUP BY participante
    HAVING COUNT(DISTINCT universidad) > 1
)

--Año o años del concurso con más participantes.

SELECT año
FROM concurso
GROUP BY año
HAVING COUNT(DISTINCT participante) = (
    SELECT MAX(NumParticipantes)
    FROM (
        SELECT COUNT(DISTINCT participante) AS NumParticipantes
        FROM concurso
        GROUP BY año
    ) AS T1
)

--Nombre de la universidad con más participantes cuya edad todavía no supera los 24 años.

SELECT universidad.nombre
FROM participantes
JOIN concurso ON participantes.id = concurso.participante
JOIN universidad ON concurso.universidad = universidad.id
WHERE CAST(strftime('%Y', 'now') - strftime('%Y', fnac) AS INTEGER) < 24
GROUP BY universidad.nombre
ORDER BY COUNT(DISTINCT participantes.nombre) DESC
LIMIT 1;


--Nombre y apellidos de el/los participantes más jóvenes que han conseguido el primer puesto.
SELECT DISTINCT p.nombre, p.apellidos
FROM participantes p
JOIN concurso c ON p.id = c.participante
WHERE CAST(strftime('%Y', 'now') - strftime('%Y', p.fnac) AS INTEGER) = (
    SELECT MIN(CAST(strftime('%Y', 'now') - strftime('%Y', p.fnac) AS INTEGER))
    FROM participantes p
    JOIN concurso c ON p.id = c.participante
    WHERE c.puesto = 1
)
AND c.puesto = 1;

-- Universidades cuyos representantes jamás han obtenido un puesto inferior al 5o.
SELECT universidad.nombre AS universidad
FROM concurso
INNER JOIN participantes ON concurso.participante = participantes.id
INNER JOIN universidad ON concurso.universidad = universidad.id
WHERE concurso.puesto > 5
GROUP BY universidad.nombre



USE world;
SET FOREIGN_KEY_CHECKS = 0;
START TRANSACTION;

-- on supprime les anciens etats si ils existent deja
DELETE FROM countrylanguage WHERE CountryCode IN ('BRE','VAL','LYO','CAE','LIL');
DELETE FROM country WHERE Code IN ('BRE','VAL','LYO','CAE','LIL');


-- on sauvegarde la france avant de toucher a quoi que ce soit


SELECT Population, SurfaceArea, GNP, LifeExpectancy
INTO @population_france_originale, @surface_france_originale, @gnp_france_originale, @esperance_vie_france
FROM country WHERE Code='FRA';


-- ETAT BRETON


INSERT INTO country (Code, Name, Continent, Region, SurfaceArea, IndepYear, Population, LifeExpectancy, GNP, Capital)
VALUES ('BRE','Etat Breton','Europe','France',57114,2026,0,NULL,0,NULL);

UPDATE city SET CountryCode='BRE' WHERE District IN ('Bretagne','Normandie');

SET @population_bretagne = (SELECT SUM(Population) FROM city WHERE CountryCode='BRE');
UPDATE country SET Population=@population_bretagne WHERE Code='BRE';
UPDATE country SET Capital=(SELECT ID FROM city WHERE Name='Rennes' LIMIT 1) WHERE Code='BRE';

INSERT INTO countrylanguage VALUES ('BRE','Breton','T',100);


-- VAL DE LOIRE


INSERT INTO country (Code, Name, Continent, Region, SurfaceArea, IndepYear, Population, LifeExpectancy, GNP, Capital)
VALUES ('VAL','Republique du Val de Loire','Europe','France',39151,2026,0,NULL,0,NULL);

UPDATE city SET CountryCode='VAL' WHERE District='Centre';

SET @population_val_de_loire = (SELECT SUM(Population) FROM city WHERE CountryCode='VAL');
UPDATE country SET Population=@population_val_de_loire WHERE Code='VAL';
UPDATE country SET Capital=(SELECT ID FROM city WHERE Name='Tours' LIMIT 1) WHERE Code='VAL';


-- CITES ETAT

INSERT INTO country (Code, Name, Continent, Region, SurfaceArea, IndepYear, Population, Capital)
VALUES
('LYO','Cite Etat de Lyon','Europe','France',534,2026,0,NULL),
('CAE','Cite Etat de Caen','Europe','France',590,2026,0,NULL),
('LIL','Cite Etat de Lille','Europe','France',611,2026,0,NULL);

UPDATE city SET CountryCode='LYO' WHERE Name='Lyon';
UPDATE city SET CountryCode='CAE' WHERE Name='Caen';
UPDATE city SET CountryCode='LIL' WHERE Name='Lille';

UPDATE country SET Population=(SELECT Population FROM city WHERE Name='Lyon' LIMIT 1) WHERE Code='LYO';
UPDATE country SET Population=(SELECT Population FROM city WHERE Name='Caen' LIMIT 1) WHERE Code='CAE';
UPDATE country SET Population=(SELECT Population FROM city WHERE Name='Lille' LIMIT 1) WHERE Code='LIL';

UPDATE country SET Capital=(SELECT ID FROM city WHERE Name='Lyon' LIMIT 1) WHERE Code='LYO';
UPDATE country SET Capital=(SELECT ID FROM city WHERE Name='Caen' LIMIT 1) WHERE Code='CAE';
UPDATE country SET Capital=(SELECT ID FROM city WHERE Name='Lille' LIMIT 1) WHERE Code='LIL';


-- LIECHTENSTEIN


SET @surface_liechtenstein  = (SELECT SurfaceArea FROM country WHERE Code='LIE');
SET @surface_suisse         = (SELECT SurfaceArea FROM country WHERE Code='CHE');
SET @surface_lombardie      = (SELECT SurfaceArea FROM country WHERE Code='ITA') * 0.047;

SET @gnp_liechtenstein      = (SELECT GNP FROM country WHERE Code='LIE');
SET @gnp_suisse             = (SELECT GNP FROM country WHERE Code='CHE');
SET @gnp_lombardie          = (SELECT GNP FROM country WHERE Code='ITA') * 0.047;

UPDATE city SET CountryCode='LIE' WHERE CountryCode='CHE' OR District='Lombardia';

SET @population_liechtenstein = (SELECT SUM(Population) FROM city WHERE CountryCode='LIE');
UPDATE country SET Population  = @population_liechtenstein WHERE Code='LIE';
UPDATE country SET SurfaceArea = ROUND(@surface_liechtenstein + @surface_suisse + @surface_lombardie, 2) WHERE Code='LIE';
UPDATE country SET GNP         = ROUND(@gnp_liechtenstein + @gnp_suisse + @gnp_lombardie, 2) WHERE Code='LIE';
UPDATE country SET LifeExpectancy = 79.0 WHERE Code='LIE';


-- RECALCULE FRANCE


-- world stoke la population national pas celle des villes donc
-- on soustrait directement la pop des nouveau etats de la france
-- c plus coherant comme ca

SET @population_nouveaux_etats =
    (SELECT Population FROM country WHERE Code='BRE') +
    (SELECT Population FROM country WHERE Code='CAE') +
    (SELECT Population FROM country WHERE Code='VAL') +
    (SELECT Population FROM country WHERE Code='LIL') +
    (SELECT Population FROM country WHERE Code='LYO');

SET @surface_nouveaux_etats = 57114 + 39151 + 534 + 590 + 611;

UPDATE country SET
    GNP            = ROUND(Population / @population_france_originale * @gnp_france_originale, 2),
    LifeExpectancy = @esperance_vie_france
WHERE Code IN ('BRE','CAE','VAL','LIL','LYO');

SET @population_france_restante = @population_france_originale - @population_nouveaux_etats;
UPDATE country SET
    Population     = @population_france_restante,
    SurfaceArea    = @surface_france_originale - @surface_nouveaux_etats,
    GNP            = ROUND(@population_france_restante / @population_france_originale * @gnp_france_originale, 2),
    LifeExpectancy = @esperance_vie_france
WHERE Code='FRA';

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;

-- vérification finale

SELECT Code, Name, Population, SurfaceArea, GNP, LifeExpectancy
FROM country
WHERE Code IN ('FRA','BRE','VAL','LYO','CAE','LIL','LIE')
ORDER BY Code;
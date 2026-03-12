USE world;
SET FOREIGN_KEY_CHECKS = 0;
START TRANSACTION;

-- virer les anciens pays si deja crees

DELETE FROM countrylanguage WHERE CountryCode IN ('QON','NUS');
DELETE FROM country WHERE Code IN ('QON','NUS');

-- canada annexe des etats US

UPDATE city
SET CountryCode='CAN'
WHERE CountryCode='USA' AND District IN ('Michigan','Wisconsin','Illinois','Alaska','Washington');

-- calcul population annexé

SET @pop_can_annex = (SELECT SUM(Population) FROM city WHERE CountryCode='CAN' AND District IN ('Michigan','Wisconsin','Illinois','Alaska','Washington'));
SET @pop_can_avant = (SELECT Population FROM country WHERE Code='CAN');
SET @pop_usa_avant = (SELECT Population FROM country WHERE Code='USA');

-- maj population CAN et USA

UPDATE country SET Population = @pop_can_avant + @pop_can_annex WHERE Code='CAN';
UPDATE country SET Population = @pop_usa_avant - @pop_can_annex WHERE Code='USA';

-- surface CAN et USA
SET @surface_annexe = 250493+169635+149997+1717856+184827;
UPDATE country SET SurfaceArea = SurfaceArea + @surface_annexe WHERE Code='CAN';
UPDATE country SET SurfaceArea = SurfaceArea - @surface_annexe WHERE Code='USA';

-- gnp (PIB)  CAN et USA

SET @pib_usa_avant = 8510700; -- PIB USA avant colonisation
SET @pib_can_annexe = (@pop_can_annex / 278357000) * @pib_usa_avant;

UPDATE country SET GNP = GNP + @pib_can_annexe WHERE Code='CAN';
UPDATE country SET GNP = GNP - @pib_can_annexe WHERE Code='USA';

-- ésperance vie CAN apres annexion

SET @esperance_vie_canada = ROUND((31147000*79.4 + @pop_can_annex*77.1)/(31147000+@pop_can_annex),1);
UPDATE country SET LifeExpectancy = @esperance_vie_canada WHERE Code='CAN';

-- QON devient independant

INSERT INTO country
(Code, Name, Continent, Region, SurfaceArea, IndepYear, Population, LifeExpectancy, GNP, LocalName, GovernmentForm, Capital, Code2)
VALUES
('QON','Quebec-Ontario','North America','North America',1542056,2026,0,78.9,0,'Quebec-Ontario','Republic',NULL,'QO');

UPDATE city SET CountryCode='QON' WHERE CountryCode='CAN' AND District IN ('Quebec','Ontario');

SET @pop_qon = (SELECT SUM(Population) FROM city WHERE CountryCode='QON');
UPDATE country SET Population=@pop_qon WHERE Code='QON';
UPDATE country SET Capital=(SELECT ID FROM city WHERE Name='Montréal' AND CountryCode='QON' LIMIT 1) WHERE Code='QON';

-- gnp QON proportionnel

SET @pib_can_avant_qon = (SELECT GNP FROM country WHERE Code='CAN');
SET @pop_can_apres_qon = (SELECT Population FROM country WHERE Code='CAN');
SET @pib_qon = (@pop_qon/(@pop_qon + @pop_can_apres_qon))*@pib_can_avant_qon;
UPDATE country SET GNP=@pib_qon WHERE Code='QON';

-- maj CAN apres QON

UPDATE country SET 
Population=(SELECT SUM(Population) FROM city WHERE CountryCode='CAN'),
SurfaceArea=SurfaceArea - 1542056,
GNP = GNP - @pib_qon
WHERE Code='CAN';

-- USA conquiert Mexique , colombie , cuba , venuzuela 

UPDATE city SET CountryCode='USA' WHERE CountryCode IN ('MEX','CUB','VEN','COL');

-- maj USA population , surface, gnp et esperance

SET @pop_usa_apres_colonie = (SELECT SUM(Population) FROM city WHERE CountryCode='USA');
SET @surface_usa_apres_colonie = (SELECT SUM(SurfaceArea) FROM country WHERE Code IN ('USA','MEX','CUB','VEN','COL'));
SET @pib_usa_apres_colonie = (SELECT SUM(GNP) FROM country WHERE Code IN ('USA','MEX','CUB','VEN','COL'));
SET @esperance_vie_usa = ROUND((SELECT SUM(Population*LifeExpectancy)/SUM(Population) FROM country WHERE Code IN ('USA','MEX','CUB','VEN','COL')),1);

UPDATE country SET Population=@pop_usa_apres_colonie, SurfaceArea=@surface_usa_apres_colonie, GNP=@pib_usa_apres_colonie, LifeExpectancy=@esperance_vie_usa WHERE Code='USA';

-- fusion pays sud -> NUS

INSERT INTO country
(Code, Name, Continent, Region, SurfaceArea, IndepYear, Population, LifeExpectancy, GNP, LocalName, GovernmentForm, Capital, Code2)
VALUES
('NUS','Nouveaux États-Unis d''Amérique','South America','South America',0,2026,0,NULL,0,'NEUA','Federal Republic',NULL,'NU');

UPDATE city SET CountryCode='NUS' WHERE CountryCode IN ('ARG','CHL','PER','BOL','PRY','URY','ECU');

-- maj NUS population, surface, gnp, esp vie

SET @pop_nus = (SELECT SUM(Population) FROM city WHERE CountryCode='NUS');
SET @surf_nus = (SELECT SUM(SurfaceArea) FROM country WHERE Code IN ('ARG','CHL','PER','BOL','PRY','URY','ECU'));
SET @pib_nus = (SELECT SUM(GNP) FROM country WHERE Code IN ('ARG','CHL','PER','BOL','PRY','URY','ECU'));
SET @esperance_vie_nus = ROUND((SELECT SUM(Population*LifeExpectancy)/SUM(Population) FROM country WHERE Code IN ('ARG','CHL','PER','BOL','PRY','URY','ECU')),1);

UPDATE country SET Population=@pop_nus, SurfaceArea=@surf_nus, GNP=@pib_nus, LifeExpectancy=@esperance_vie_nus WHERE Code='NUS';

-- langue ou langague de NUS

INSERT INTO countrylanguage (CountryCode, Language, IsOfficial, Percentage)
SELECT 'NUS', Language, IsOfficial, Percentage FROM countrylanguage
WHERE CountryCode IN ('ARG','CHL','PER','BOL','PRY','URY','ECU')
ON DUPLICATE KEY UPDATE Percentage=GREATEST(countrylanguage.Percentage, VALUES(Percentage));

COMMIT;
SET FOREIGN_KEY_CHECKS=1;

-- vérification  final
SELECT
c.Code,
c.Name,
c.Population,
SUM(ci.Population) AS population_villes,
c.SurfaceArea,
c.GNP,
c.LifeExpectancy,
CASE WHEN c.Population=SUM(ci.Population) THEN 'Population OK' ELSE 'Population ERREUR' END AS test_population
FROM country c
LEFT JOIN city ci ON ci.CountryCode=c.Code
WHERE c.Code IN ('CAN','QON','USA','NUS')
GROUP BY c.Code;

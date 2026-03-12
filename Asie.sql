-- on Calcul de La Grande Corée

SELECT SUM(Population), SUM(SurfaceArea), SUM(GNP), 
       ROUND(SUM(Population * LifeExpectancy)/SUM(Population),1)
INTO @popGrandeCoree, @areaGrandeCoree, @gnpGrandeCoree, @lifeGrandeCoree
FROM country
WHERE Code IN ('PRK','KOR','CHN','JPN');

-- Création ou mise à jour de La Grande Corée

UPDATE country
SET Population = @popGrandeCoree,
    SurfaceArea = @areaGrandeCoree,
    GNP = @gnpGrandeCoree,
    LifeExpectancy = @lifeGrandeCoree
WHERE Code = 'GRK';

-- Si la grande coree  n'existe pas encore, on peut l’insérer

INSERT INTO country (Code, Name, Population, SurfaceArea, GNP, LifeExpectancy)
SELECT 'GRK','La Grande Corée', @popGrandeCoree, @areaGrandeCoree, @gnpGrandeCoree, @lifeGrandeCoree
WHERE NOT EXISTS (SELECT 1 FROM country WHERE Code='GRK');

--  remettre anciennes nations à 0 ou supprimer

UPDATE country
SET Population = 0, SurfaceArea = 0, GNP = 0, LifeExpectancy = NULL
WHERE Code IN ('PRK','KOR','CHN','JPN');

-- Transfert des villes vers La Grande Corée

UPDATE city SET CountryCode='GRK' 
WHERE CountryCode IN ('PRK','KOR','CHN','JPN');

-- Vérification finale
SELECT Code, Name, Population, SurfaceArea, GNP, LifeExpectancy
FROM country
WHERE Code IN ('GRK','PRK','KOR','CHN','JPN');

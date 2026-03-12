-- Script du BONUS : World → NewWorld


USE NewWorld;

-- Migration des pays depuis World.Country

INSERT IGNORE INTO Pays (code_pays, nom, population, PNB, surface, esperance_vie)
SELECT 
    Code,
    Name,
    Population,
    GNP,
    SurfaceArea,
    LifeExpectancy
FROM World.Country;

-- Migration des villes depuis World.City

INSERT IGNORE INTO Ville (id_ville, FK_code_pays, nom, population)
SELECT 
    ID,
    CountryCode,
    Name,
    Population
FROM World.City;

-- Mise à jour des capitale

UPDATE Pays p
JOIN World.Country c ON p.code_pays = c.Code
SET p.FK_id_capital = c.Capital
WHERE c.Capital IS NOT NULL;

-- Migration des langues depuis World.CountryLanguage

INSERT IGNORE INTO Langue (nom)
SELECT DISTINCT Language
FROM World.CountryLanguage;

-- Migration des liaisons Pays /Langues dans Dialogues

INSERT IGNORE INTO Dialogues (FK_id_langues, FK_code_pays, est_officielle, pourcentage)
SELECT 
    l.id_langue,
    cl.CountryCode,
    IF(cl.IsOfficial = 'T', TRUE, FALSE),
    cl.Percentage
FROM World.CountryLanguage cl
JOIN Langue l ON l.nom = cl.Language;

-- mise en place des armées 
INSERT IGNORE INTO Armee (FK_code_pays)
SELECT code_pays FROM Pays;

--mise en place  des ressources 
INSERT IGNORE INTO Ressource (FK_code_pays)
SELECT code_pays FROM Pays;







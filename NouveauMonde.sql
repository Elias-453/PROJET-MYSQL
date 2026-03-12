
-- Script de création de la base de données NewWorld
-- Cohérent avec le MCD et le MLD de SupSimulation

CREATE DATABASE IF NOT EXISTS NewWorld CHARACTER SET utf8mb4;
USE NewWorld;

-- SET utf8mb4 permet de stocker les caracteres spéciaux comme les accents par exemple

-- ENTITÉS PRINCIPALES


CREATE TABLE Pays (
    code_pays       CHAR(3)         NOT NULL,
    nom             VARCHAR(100)    NOT NULL,
    population      INT             DEFAULT 0,
    PNB             DECIMAL(15,2)   DEFAULT 0,
    surface         FLOAT,
    esperance_vie   FLOAT,
    FK_id_capital   INT,
    PRIMARY KEY (code_pays)
);

CREATE TABLE Ville (
    id_ville        INT             NOT NULL AUTO_INCREMENT,
    FK_code_pays    CHAR(3)         NOT NULL,
    nom             VARCHAR(100)    NOT NULL,
    population      INT             DEFAULT 0,
    PRIMARY KEY (id_ville),
    FOREIGN KEY (FK_code_pays) REFERENCES Pays(code_pays)
);

ALTER TABLE Pays ADD FOREIGN KEY (FK_id_capital) REFERENCES Ville(id_ville);

CREATE TABLE Armee (
    id_armee                INT     NOT NULL AUTO_INCREMENT,
    FK_code_pays            CHAR(3) NOT NULL UNIQUE,
    nb_soldat               INT     DEFAULT 0,
    nb_avions               INT     DEFAULT 0,
    nb_tank                 INT     DEFAULT 0,
    nb_ogive_nucleaire      INT     DEFAULT 0,
    nb_defense_aerienne     INT     DEFAULT 0,
    nb_sous_marins          INT     DEFAULT 0,
    nb_drone                INT     DEFAULT 0,
    nb_missile_balistique   INT     DEFAULT 0,
    PRIMARY KEY (id_armee),
    FOREIGN KEY (FK_code_pays) REFERENCES Pays(code_pays)
);

CREATE TABLE Langue (
    id_langue   INT          NOT NULL AUTO_INCREMENT,
    nom         VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_langue)
);

CREATE TABLE Ressource (
    id_ressource    INT     NOT NULL AUTO_INCREMENT,
    FK_code_pays    CHAR(3) NOT NULL UNIQUE,
    petrole         FLOAT   DEFAULT 0,
    GAZ             FLOAT   DEFAULT 0,
    OR_reserve      FLOAT   DEFAULT 0,
    cuivre          FLOAT   DEFAULT 0,
    uranium         FLOAT   DEFAULT 0,
    fer             FLOAT   DEFAULT 0,
    charbon         FLOAT   DEFAULT 0,
    PRIMARY KEY (id_ressource),
    FOREIGN KEY (FK_code_pays) REFERENCES Pays(code_pays)
);

CREATE TABLE Alliance (
    id_alliance     INT          NOT NULL AUTO_INCREMENT,
    nom             VARCHAR(100) NOT NULL,
    nb_membre       INT          DEFAULT 0,
    statut          VARCHAR(50),
    date_creation   DATE,
    type            VARCHAR(50),
    PRIMARY KEY (id_alliance)
);

CREATE TABLE Guerre (
    id_guerre   INT          NOT NULL AUTO_INCREMENT,
    nom         VARCHAR(150),
    date_debut  DATE         NOT NULL,
    date_fin    DATE,
    statut      VARCHAR(20)  DEFAULT 'en_cours',
    description TEXT,
    PRIMARY KEY (id_guerre)
);


-- TABLES DE LIAISON


CREATE TABLE Dialogues (
    FK_id_langues   INT     NOT NULL,
    FK_code_pays    CHAR(3) NOT NULL,
    est_officielle  BOOLEAN DEFAULT FALSE,
    pourcentage     FLOAT,
    PRIMARY KEY (FK_id_langues, FK_code_pays),
    FOREIGN KEY (FK_id_langues) REFERENCES Langue(id_langue),
    FOREIGN KEY (FK_code_pays)  REFERENCES Pays(code_pays)
);

CREATE TABLE Membre_alliance (
    FK_code_pays    CHAR(3) NOT NULL,
    FK_id_alliance  INT     NOT NULL,
    date_adhesion   DATE,
    role            VARCHAR(50),
    PRIMARY KEY (FK_code_pays, FK_id_alliance),
    FOREIGN KEY (FK_code_pays)   REFERENCES Pays(code_pays),
    FOREIGN KEY (FK_id_alliance) REFERENCES Alliance(id_alliance)
);

CREATE TABLE Participation (
    FK_code_pays    CHAR(3) NOT NULL,
    FK_id_guerre    INT     NOT NULL,
    role            VARCHAR(50),
    finalite        VARCHAR(50),
    PRIMARY KEY (FK_code_pays, FK_id_guerre),
    FOREIGN KEY (FK_code_pays) REFERENCES Pays(code_pays),
    FOREIGN KEY (FK_id_guerre) REFERENCES Guerre(id_guerre)
);

CREATE TABLE Conquete_militaire (
    FK_code_pays    CHAR(3) NOT NULL,
    FK_id_ville     INT     NOT NULL,
    date_conquete   DATE    NOT NULL,
    PRIMARY KEY (FK_code_pays, FK_id_ville),
    FOREIGN KEY (FK_code_pays) REFERENCES Pays(code_pays),
    FOREIGN KEY (FK_id_ville)  REFERENCES Ville(id_ville)
);


-- INSERTIONS


INSERT INTO Pays (code_pays, nom, population, PNB, surface, esperance_vie)
VALUES ('FRA', 'France', 67000000, 2715518.00, 551695.0, 82.4),
       ('DEU', 'Allemagne', 83000000, 4223116.00, 357114.0, 81.2),
       ('ESP', 'Espagne', 47000000, 1425341.00, 505990.0, 83.5);

INSERT INTO Ville (FK_code_pays, nom, population)
VALUES ('FRA', 'Paris', 2187526),
       ('DEU', 'Berlin', 3669491),
       ('ESP', 'Madrid', 3305408);

UPDATE Pays SET FK_id_capital = 1 WHERE code_pays = 'FRA';
UPDATE Pays SET FK_id_capital = 2 WHERE code_pays = 'DEU';
UPDATE Pays SET FK_id_capital = 3 WHERE code_pays = 'ESP';

INSERT INTO Armee (FK_code_pays, nb_soldat, nb_avions, nb_tank, nb_sous_marins, nb_drone)
VALUES ('FRA', 200000, 250, 400, 10, 300),
       ('DEU', 180000, 200, 350, 6, 250),
       ('ESP', 120000, 150, 300, 4, 150);

INSERT INTO Langue (nom)
VALUES ('Français'), ('Allemand'), ('Espagnol');

INSERT INTO Ressource (FK_code_pays, petrole, GAZ, uranium, charbon)
VALUES ('FRA', 100.5, 10.2, 7500.0, 500.0),
       ('DEU', 50.0, 80.0, 100.0, 1200.0),
       ('ESP', 30.0, 20.0, 50.0, 300.0);

INSERT INTO Alliance (nom, nb_membre, statut, date_creation, type)
VALUES ('OTAN', 30, 'active', '1949-04-04', 'militaire'),
       ('Union Européenne', 27, 'active', '1993-11-01', 'économique');

INSERT INTO Guerre (nom, date_debut, statut, description)
VALUES ('Guerre des Ressources', '2025-01-15', 'en_cours', 'Conflit pour le contrôle des ressources naturelles');

INSERT INTO Dialogues (FK_id_langues, FK_code_pays, est_officielle, pourcentage)
VALUES (1, 'FRA', TRUE, 97.5),
       (2, 'DEU', TRUE, 95.0),
       (3, 'ESP', TRUE, 99.0);

INSERT INTO Membre_alliance (FK_code_pays, FK_id_alliance, date_adhesion, role)
VALUES ('FRA', 1, '1949-04-04', 'fondateur'),
       ('DEU', 1, '1955-05-09', 'membre'),
       ('ESP', 2, '1986-01-01', 'membre');

INSERT INTO Participation (FK_code_pays, FK_id_guerre, role, finalite)
VALUES ('FRA', 1, 'agresseur', NULL),
       ('DEU', 1, 'defenseur', NULL);

INSERT INTO Conquete_militaire (FK_code_pays, FK_id_ville, date_conquete)
VALUES ('FRA', 2, '2025-03-10');

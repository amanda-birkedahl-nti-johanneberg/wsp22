CREATE TABLE "rum" (
	"id"	            INTEGER PRIMARY KEY AUTOINCREMENT,
	"typ"	            INTEGER NOT NULL DEFAULT 0,
	"antal"	            INTEGER NOT NULL DEFAULT 1,
	"ppn"	            INTEGER NOT NULL DEFAULT 1000,
	"bild"	            TEXT DEFAULT '/img/small.jpg',
    "bild_alt"	        TEXT DEFAULT 'BIld på litet rum',
	"beskrivning"	    TEXT DEFAULT 'Beskrivning av rummet',
	"bakgrund"	        TEXT DEFAULT '#c1af8e',
	"punkter"	        TEXT DEFAULT '["Punkt 1"]'
);

CREATE TABLE "users" (
	"id"	            INTEGER PRIMARY KEY AUTOINCREMENT,
	"pwDigest"	        TEXT NOT NULL,
	"namn"	            TEXT NOT NULL UNIQUE,
	"admin"	            INTEGER DEFAULT 0
);

CREATE TABLE "betyg" (
	"bokning_id"	    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	"user_id"	        INTEGER,
	"betyg"	            INTEGER NOT NULL DEFAULT 5,
	"text"	            TEXT NOT NULL DEFAULT "",
	"rum_id"	        INTEGER NOT NULL,
	FOREIGN KEY("user_id") REFERENCES "users"("id") ON DELETE SET NULL,
	FOREIGN KEY("rum_id") REFERENCES "rum"("id") ON DELETE CASCADE,
	FOREIGN KEY("bokning_id") REFERENCES "bokningar"("bokning_id") ON DELETE CASCADE
);

CREATE TABLE "bokningar" (
	"bokning_id"	    INTEGER PRIMARY KEY AUTOINCREMENT,
	"rum_id"	        INTEGER,
	"user_id"	        INTEGER,
	"antal_personer"	INTEGER DEFAULT 1,
	"antal_nights"	    INTEGER DEFAULT 1,
	"antal_rum"	        NUMERIC DEFAULT 1,
	"start_datum"	    TEXT,
	"slut_datum"	    TEXT,
	"status"	        INTEGER DEFAULT 0,
	FOREIGN KEY("user_id") REFERENCES "users"("id") ON DELETE SET NULL,
	FOREIGN KEY("rum_id") REFERENCES "rum"("id") ON DELETE SET NULL
);

INSERT INTO rum (typ, bild, bild_alt, beskrivning, bakgrund, punkter) VALUES
    (0, '/img/small.jpg', 'Bild på litet hotellrum', 'Litet hotellrumm', '#c1af8e', '["Mysigt", "2 Sängplatser"]'),
    (1, '/img/medium.jpg', 'Bild på mediumstort hotellrum', 'Mellan hotellrum', '#c1af8e', '["Större", "TV ingår!"]'),
    (2, '/img/large.jpg', 'Bild på large hotellrum', 'Stort hotellrumm', '#c1af8e', '["Stort", "Frukost och lunch ingår!"]'),
    (3, '/img/svit.jpg', 'Bild på svit', 'Exklusivt rum', '#c1af8e', '["Gjort för kungligheter", "Extra allt!"]');
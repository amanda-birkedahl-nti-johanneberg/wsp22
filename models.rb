require 'extralite'
require 'json'

def rum_lista
  [
    { id: 0, typ: 0, bild: '/img/small.jpg', alt: 'Bild på litet hotellrum', beskrivning: 'Lorem ipsum',
      bakgrund: '#c1af8e', punkter: ['Info 1', 'Info 2'] },
    { id: 1, typ: 1, bild: '/img/medium.jpg', alt: 'Bild på mediumstort hotellrum', beskrivning: 'Lorem ipsum',
      bakgrund: '#c1af8e', punkter: ['Info 1', 'Info 2'] },
    { id: 2, typ: 2, bild: '/img/large.jpg', alt: 'Bild på large hotellrum', beskrivning: 'Lorem ipsum',
      bakgrund: '#c1af8e', punkter: ['Info 1', 'Info 2'] },
    { id: 3, typ: 3, bild: '/img/svit.jpg', alt: 'Bild på svit', beskrivning: 'Lorem ipsum', bakgrund: '#c1af8e',
      punkter: ['Info 1', 'Info 2'] }
  ]
end

def db
  Extralite::Database.new './db/hotell.db'
end

def populate
  stmnt = db.prepare 'insert into rum(typ, bild, bild_alt, beskrivning, bakgrund, punkter, antal, ppn) values (?, ?, ?, ?, ?, ?, 1, 1000)'

  rum_lista.each do |rum|
    stmnt.query(rum[:typ], rum[:bild], rum[:alt], rum[:beskrivning], rum[:bakgrund], JSON.generate(rum[:punkter]))
  end
end

def room_type(typ)
  case typ
  when 0
    'Small'
  when 1
    'Medium'
  when 2
    'Large'
  when 3
    'Suite'
  else
    'Okänd'
  end
end

def get_rooms
  stmnt = 'select * from rum'
  alla_rum = db.query(stmnt)
  alla_rum.map do |rum|
    rum[:punkter] = JSON.parse(rum[:punkter])
  end

  alla_rum
end

def get_room(id)
  # hämta endast 1 rad
  rad = db.query_single_row('select * from rum where id = ?', id)

  rad[:punkter] = JSON.parse(rad[:punkter])
  rad
end

def uppdatera_rum(id, rum)
  rum['punkter'] = JSON.generate(rum['punkter'])

  p rum

  # db.query('update rum set beskrivning = ? where id = ?', rum['beskrivning'], id)

  stmt = db.prepare('update rum set typ = ?, bild = ?, bild_alt = ?, beskrivning = ?, bakgrund = ?, punkter = ?, antal = ?, ppn = ? where id = ?')

  stmt.query(rum['typ'],
             rum['bild'], rum['bild_alt'], rum['beskrivning'], rum['bakgrund'], rum['punkter'], rum['antal'], rum['ppn'], id)
end

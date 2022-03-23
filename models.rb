require 'extralite'
require 'json'

def db
  Extralite::Database.new './db/hotell.db'
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

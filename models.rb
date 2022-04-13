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
  stmt = db.prepare('update rum set typ = ?, bild = ?, bild_alt = ?, beskrivning = ?, bakgrund = ?, punkter = ?, antal = ?, ppn = ? where id = ?')

  stmt.query(rum['typ'],
             rum['bild'], rum['bild_alt'], rum['beskrivning'], rum['bakgrund'], rum['punkter'], rum['antal'], rum['ppn'], id)
end

def boka_rum(rum_id, user_id, params)
  gaster = params[:guests]
  natter = params[:nights]
  rum = params[:rooms]

  db.query('insert into bokningar (user_id, antal_personer, rum_id, antal_rum, antal_nights, start_datum, slut_datum) values($1,$2,$3,$4,$5)',
           user_id, gaster, rum_id, rum, natter)
end

def get_bookings(user_id, typ = nil)
  db.query("select r.typ, r.ppn, rum_id, antal_rum, antal_nights, antal_personer, start_datum, slut_datum, status, bokning_id

            from bokningar b
            left join rum r on b.rum_id = r.id
            #{user_id.nil? ? '' : 'where user_id = :id'}
            #{typ.nil? ? '' : 'where status = :typ'}", id: user_id, typ: typ)
end

def user_can_cancel(bokning_id, user)
  booker = db.query_single_value('select user_id from bokningar where bokning_id = ?', bokning_id)
  booker == user
end

def cancel_booking(id)
  db.query('update bokningar set status = 3 where bokning_id = ?', id)
end

def get_user_hash(namn)
  db.query_single_value('select pwDigest from users where namn = ?', namn)
end

def skapa_konto(namn, hash)
  db.query('insert into users (namn, pwDigest) values ($1, $2)', namn, hash)
end

def logga_in(namn)
  user = db.query_single_row('select namn, admin, id from users where namn = $1', namn)
  return if user.nil?

  session[:user] = user
end

def get_user(id)
  db.query_single_row('select namn, admin, id from users where id = $1', id)
end

def admin?(user)
  return false if user.nil?

  db.query_single_value('select admin from users where id = ?', user[:id]) == 1
end

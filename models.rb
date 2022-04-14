require 'extralite'
require 'json'

# alla hjälpfunktioner
module Models


  # Databaskopplingen
  #
  # @return [Extralite::Database]
  def db
    Extralite::Database.new './db/hotell.db'
  end

  # Hämtar alla rum
  #
  # @return [Array] en lista av alla rum
  def get_rooms
    stmnt = 'select * from rum'
    alla_rum = db.query(stmnt)
    alla_rum.map do |rum|
      rum[:punkter] = JSON.parse(rum[:punkter])
    end

    alla_rum
  end

  # Hämtar ett rum med dess id
  #
  # @param [Integer] id rummets id
  def get_room(id)
    # hämta endast 1 rad
    rad = db.query_single_row('select * from rum where id = ?', id)

    rad[:punkter] = JSON.parse(rad[:punkter])
    rad
  end

  # Uppdaterar ett rum med dess id och json
  #
  # @param [Integer] id
  # @param [Hash] rum
  # @option rum [String] typ
  # @option rum [String] bild
  # @option rum [String] bild_alt
  # @option rum [String] beskrivning
  # @option rum [String] bakgrund
  # @option rum [Array] punkter
  # @option rum [Integer] antal
  # @option rum [Integer] ppn pris per natt
  #
  def uppdatera_rum(id, rum)
    rum['punkter'] = JSON.generate(rum['punkter'])
    stmt = db.prepare('update rum set typ = ?, bild = ?, bild_alt = ?, beskrivning = ?, bakgrund = ?, punkter = ?, antal = ?, ppn = ? where id = ?')

    stmt.query(rum['typ'],
              rum['bild'], rum['bild_alt'], rum['beskrivning'], rum['bakgrund'], rum['punkter'], rum['antal'], rum['ppn'], id)
  end

  # Bokar ett rum åt en användare
  #
  # @param [Integer] rum_id
  # @param [Integer] user_id
  # @param [Hash] params
  # @option params [Integer] guests
  # @option params [Integer] nights
  # @option params [Integer] rooms
  def boka_rum(rum_id, user_id, params)
    gaster = params[:guests]
    natter = params[:nights]
    rum = params[:rooms]

    db.query('insert into bokningar (user_id, antal_personer, rum_id, antal_rum, antal_nights) values($1,$2,$3,$4,$5)',
            user_id, gaster, rum_id, rum, natter)
  end

  # Hämtar bokningar för en viss användare och/eller typ
  #
  # @param [Integer] user_id?
  # @param [Integer] typ?
  def get_bookings(user_id, typ = nil)
    db.query("select r.typ, r.ppn, rum_id, antal_rum, antal_nights, antal_personer,
                    start_datum, slut_datum, status, bokning_id,
                    u.namn as user_namn, u.id as user_id, r.bild as rum_bild

              from bokningar b
              left join rum r on b.rum_id = r.id
              left join users u on b.user_id = u.id
              #{user_id.nil? ? '' : 'where user_id = :id'}
              #{typ.nil? ? '' : 'where status = :typ'}", id: user_id, typ: typ)
  end

  # Bestämmer om en användare kan avboka ett rum
  #
  # @param [Integer] booking_id
  # @param [Integer] user
  #
  # @return [Boolean] kan_avboka?
  def user_can_cancel(bokning_id, user)
    booker, status = db.query_ary('select user_id, status from bokningar where bokning_id = ?', bokning_id)[0]
    (booker == user && status.zero?) || admin?({ id: user })
  end

  # Bestämmer om en användare kan betygsätta en bokning
  #
  # @param [Integer] booking_id
  # @param [Hash] user
  # @option user [Integer] id
  #
  # @return [Boolean] kan_betygsätta?
  def user_can_rate(bokning_id, user)
    booker, status = db.query_ary('select user_id, status from bokningar where bokning_id = ?', bokning_id)[0]
    booker == user[:id] && status == 2
  end

  # Avbryter en bokning
  # @param [Integer] id
  def cancel_booking(id)
    db.query('update bokningar set status = 3 where bokning_id = ?', id)
  end

  # Slutför en bokning
  # @param [Integer] id
  def slutfor_booking(id)
    db.query('update bokningar set status = 2 where bokning_id = ?', id)
  end

  # Betygsätter ett rum
  #
  # @param [Integer] room boknings_id
  # @param [Integer] user
  # @param [String] text
  # @param [String] betyg
  def rate_room(room, user, text, betyg)
    db.query('insert into betyg (bokning_id, user_id, text, betyg) values(?, ?, ?, ?)', room, user, text, betyg)
    db.query('update bokningar set status = 4 where bokning_id = ?', room)
  end

  # Hämtar en recension
  #
  # @param [Integer] bokning_id
  #
  # @return [Hash] betyg
  # @option betyg [String] text
  # @option betyg [String] betyg
  def get_rating(bokning_id)
    user = session[:user][:id]

    db.query_single_row('select text, b.betyg from betyg b where user_id = ? and bokning_id = ?', user, bokning_id)
  end

  # Hämtar en användares lösenord-hash
  #
  # @param [String] namn
  #
  # @return [String] hash
  def get_user_hash(namn)
    db.query_single_value('select pwDigest from users where namn = ?', namn)
  end

  # skapar ett konto
  #
  # @param [String] namn
  # @param [String] hash
  def skapa_konto(namn, hash)
    db.query('insert into users (namn, pwDigest) values ($1, $2)', namn, hash)
  end

  # loggar in en användare
  #
  # @param [String] namn
  def logga_in(namn)
    user = db.query_single_row('select namn, admin, id from users where namn = $1', namn)
    return if user.nil?

    session[:user] = user
  end

  # hämtar en användare
  #
  # @param [Integer] id
  # @return [Hash] user
  # @option user [Integer] id
  # @option user [Integer] admin
  # @option user [String] namn
  def get_user(id)
    db.query_single_row('select namn, admin, id from users where id = $1', id)
  end

  # bestämmer om inloggad användare finns
  # @return [Boolean]
  def auth?
    return false if session[:user].nil?

    true
  end

  # bestämmer om  användare är admin
  # @param [Hash] user
  # @option user [Integer] id
  # @return [Boolean]
  def admin?(user)
    return false if user.nil?

    db.query_single_value('select admin from users where id = ?', user[:id]) == 1
  end
end
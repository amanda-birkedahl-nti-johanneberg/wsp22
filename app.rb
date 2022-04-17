# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'bcrypt'

require_relative 'models'
require_relative 'utils'

configure :development do
  register Sinatra::Reloader
end

enable :sessions

include Models
include Utils

# Visar förstasidan
#
get '/' do
  slim :"statiska/index"
end

# Visar en lista av boende och låter användaren boka rum
#
# @see Models#get_rooms
get '/boende' do
  @boende = get_rooms # Hämta alla boende från databas

  slim :"boende/index"
end

# Visar sidan för att redigera rum
#
# @param [String] :id, rummets id
get '/boende/:id/redigera' do |id|
  rum = get_room(id)

  # Omvandla 'rgb(rr,gg,bb)' till hex-kod för chrome gör all hex till rbg >:(
  @color_as_hex = rbg_to_hex(rum[:bakgrund])
  slim :"boende/redigera", locals: { rum: rum }
end

# Uppdaterar ett rum och omdirigerar till '/boende'
#
# @param [String] body, ett rum omvandlat till json
# @param [String] :id, rummets id
#
# @see Model#create_article
post '/boende/:id/redigera' do |id|
  nytt_rum = JSON.parse(request.body.read)
  uppdatera_rum(id.to_i, nytt_rum)

  redirect '/boende'
end

# Bokar ett rum om användaren är inloggad
#
# @param [String] :id, rummets id
# @param [Integer] gaster, antalet gäster
# @param [Integer] nights, antalet nätter
# @param [Integer] rooms, antalet rum
post '/boende/:id/boka' do |id|
  redirect '/konto' unless auth?

  boka_rum(id.to_i, session[:user][:id], params)

  redirect '/konto'
end

# Visar restaurangsidan
#
get '/restaurang' do
  slim :"statiska/restaurang"
end

# Visar spasidan
#
get '/spa' do
  slim :"statiska/spa"
end

# Visar after-ski sidan
#
get '/after_ski' do
  slim :"statiska/after_ski"
end

# Visar användarens konto om den är inloggad, annars visa inloggningssidan
#
get '/konto' do
  return slim :"konto/logga-in" if session[:user].nil?

  @user = session[:user]
  @bokningar = get_bookings(session[:user][:id])
  slim :"konto/visa", locals: { is_me: true }
end

before '/konto/:id' do
  redirect '/konto' unless admin?(session[:user])
end

# Visa en annan användares konto, om admin är inloggad
#
get '/konto/:id' do |id|
  return redirect '/konto' unless auth? && admin?(session[:user])
  @user = get_user(id.to_i)
  @bokningar = get_bookings(id.to_i)
  slim :"konto/visa", locals: { is_me: id.to_i == session[:user][:id] }
end

# Loggar in om lösenord och användarman stämmer
#
# @param [String] pass, lösenord
# @param [String] namn, användarnamn
post '/konto' do
  password = params[:pass]
  namn = params[:namn]

  result = verify_creds(namn, password)

  unless result[:error].nil?
    session[:error_msg] = "Du måste ange användarnamn och lösenord"
    return redirect '/konto'
  end

  hash = get_user_hash(namn)

  matchar = BCrypt::Password.new(hash) == password
  if matchar
    logga_in(namn)
  else 
    session[:error_msg] = "Användarnamnet eller lösenordet är fel"
  end
  redirect '/konto'
end

# Skapar konto och loggar in om användaren skapas
#
# @param [String] pass, lösenord
# @param [String] namn, användarnamn
post '/konto/skapa' do
  password = params[:pass]
  namn = params[:namn]

  result = verify_creds(namn, password)
  exists = user_exists(namn)

  unless exists
    session[:error_msg] = "Användaren existerar redan"
    return redirect '/konto'
  end

  unless result[:error].nil?
    session[:error_msg] = "Du måste ange användarnamn och lösenord"
    return redirect '/konto'
  end
  
  hash = BCrypt::Password.create(password)
  
  result = skapa_konto(namn, hash)

  logga_in(namn)

  redirect '/konto'
end

# Loggar ut
post '/konto/signout' do
  session&.destroy
  redirect '/'
end

# Ändrar status på en bokning till 'Avbruten', om användaren kan avbryta
#
post '/bokning/:id/avbryt' do |id|
  return redirect '/konto' unless user_can_cancel(id.to_i, session[:user][:id])

  cancel_booking(id.to_i)
  redirect('/konto')
end

# Låter en admin slutflöra en bokning om den är klar
#
post '/bokning/:id/slutfor' do |id|
  return redirect '/konto' unless auth?
  return redirect '/konto' unless admin?(session[:user])

  slutfor_booking(id.to_i)
  redirect('/admin')
end

# Publicerar ett betyg om användaren har bott klart
#
# @param [String] :id, bokningens id
# @param [String] text, betygets kommentar
# @param [Integer] betyg, betyget
post '/bokning/:id/betyg' do |id|
  bokning_id = id.to_i

  return redirect '/konto' unless auth?
  return redirect '/konto' unless user_can_rate(bokning_id, session[:user])

  text = params[:text]
  betyg = params[:rating].to_i
  user_id = session[:user][:id]
  rate_room(bokning_id, user_id, text, betyg)
  redirect '/konto'
end

# Visar adminsidan om admin är inloggad
get '/admin' do
  return redirect '/konto' unless auth? && admin?

  status = params[:status].nil? ? nil : params[:status].to_i

  @bokningar = get_bookings(nil, status)
  slim :"konto/admin"
end

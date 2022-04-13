# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'bcrypt'

require_relative 'models'
require_relative 'methods'

configure :development do
  register Sinatra::Reloader
end

enable :sessions

# Förstasidan
get '/' do
  slim :"statiska/index"
end

# Lista med boende
get '/boende' do
  @boende = get_rooms # Hämta alla boende från databas

  slim :"boende/index"
end

get '/boende/:id/redigera' do |id|
  rum = get_room(id)

  # Omvanda 'rgb(rr,gg,bb)' till hex-kod för chrome gör allt till rbg >:(
  @color_as_hex = rbg_to_hex(rum[:bakgrund])
  slim :"boende/redigera", locals: { rum: rum }
end

post '/boende/:id/redigera' do |id|
  nytt_rum = JSON.parse(request.body.read)
  uppdatera_rum(id, nytt_rum)

  redirect '/boende'
end

post '/boende/:id/boka' do |id|
  redirect '/konto' if session[:user].nil?

  p [id, session[:user], params]

  boka_rum(id, session[:user][:id], params)

  redirect '/konto'
end

get '/restaurang' do
  slim :"statiska/restaurang"
end

get '/spa' do
  slim :"statiska/spa"
end

get '/after_ski' do
  slim :"statiska/after_ski"
end

get '/konto' do
  return slim :"konto/logga-in" if session[:user].nil?

  @user = session[:user]
  @bokningar = get_bookings(session[:user][:id])
  slim :"konto/visa", locals: { is_me: true }
end

before '/konto/:id' do
  redirect '/konto' unless admin?(session[:user])
end
get '/konto/:id' do |id|
  @user = get_user(id.to_i)
  @bokningar = get_bookings(id.to_i)
  slim :"konto/visa", locals: { is_me: id.to_i == session[:user][:id] }
end

post '/konto' do
  # TODO: verifiera kredentialer
  password = params[:pass]
  namn = params[:namn]
  hash = get_user_hash(namn)

  matchar = BCrypt::Password.new(hash) == password
  logga_in(namn) if matchar

  redirect '/konto'
end

post '/konto/skapa' do
  # TODO: verifiera kredentialer
  password = params[:pass]
  namn = params[:namn]
  hash = BCrypt::Password.create(password)
  skapa_konto(namn, hash)

  logga_in(namn)

  redirect '/konto'
end

post '/konto/signout' do
  session&.destroy
  redirect '/'
end

post '/bokning/:id/avbryt' do |id|
  return unless user_can_cancel(id.to_i, session[:user][:id])

  cancel_booking(id.to_i)
  redirect('/konto')
end

get '/admin' do
  redirect '/konto' unless session[:user] && session[:user][:admin] == 1

  status = params[:status].nil? ? nil : params[:status].to_i

  @bokningar = get_bookings(nil, status)
  slim :"konto/admin"
end

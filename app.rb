# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?

require_relative 'models'
require_relative 'methods'

configure :development do
  register Sinatra::Reloader
end

# Förstasidan
get '/' do
  slim :index
end

# Lista med boende
get '/boende' do
  @boende = get_rooms # Hämta alla boende från databas

  slim :boende
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

get '/restaurang' do
  slim :restaurang
end

get '/spa' do
  slim :spa
end

get '/after_ski' do
  slim :after_ski
end

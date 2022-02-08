# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader" if development?

configure :development do
  register Sinatra::Reloader
end

get "/" do
  slim :index
end

rumLista = [
  { id: 0, typ: "Small", bild: "/img/small.jpg", alt: "Bild på litet hotellrum", beskrivning: "Lorem ipsum", bakgrund: "#c1af8e", punkter: ["Info 1", "Info 2"] },
  { id: 1, typ: "Medium", bild: "/img/medium.jpg", alt: "Bild på mediumstort hotellrum", beskrivning: "Lorem ipsum", bakgrund: "#c1af8e", punkter: ["Info 1", "Info 2"] },
  { id: 2, typ: "Large", bild: "/img/large.jpg", alt: "Bild på large hotellrum", beskrivning: "Lorem ipsum", bakgrund: "#c1af8e", punkter: ["Info 1", "Info 2"] },
  { id: 3, typ: "Svit", bild: "/img/svit.jpg", alt: "Bild på svit", beskrivning: "Lorem ipsum", bakgrund: "#c1af8e", punkter: ["Info 1", "Info 2"] },
]

get "/boende" do
  slim :boende, locals: { boende: rumLista }
end

get "/boende/:id/redigera" do |id|
  rum = rumLista.find { |i| i[:id] == id.to_i }
  slim :redigera_boende, locals: { rum: rum }
end

get "/restaurang" do
  slim :restaurang
end
get "/spa" do
  slim :spa
end
get "/after_ski" do
  slim :after_ski
end

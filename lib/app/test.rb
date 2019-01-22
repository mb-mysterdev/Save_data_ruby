ines (62 sloc) 1.83 KB
class Scrapper
	require 'rubygems'
	require 'nokogiri'
	require 'open-uri'
	require_relative './mairie'

	# url : adresse du site web à "scrapper" 
	# tab_data : tableau d'objet Mairie
	attr_accessor :url, :tab_data

	# constructeur 
	def initialize(url)
		@url = url
		@tab_data = []
	end

	# récupére les données ici du site web
	def scrapping
		page = Nokogiri::HTML(open(@url))
		
		# récupération des villes du département
		name_ville = []
		page.xpath('//p/a').each do |e|
			name_ville << e.text
		end
		
		# récupération des emails du département 
		domaine = "http://www.annuaire-des-mairies.com/"
		urls = []

		page.xpath('//p/a/@href ').each do |e|
			urls << domaine + e.to_s[1..-1]
		end

		# récolte des maries		
		urls.each_with_index do |e, i|
			page_mail = Nokogiri::HTML(open(e))
			mail = page_mail.xpath("/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]").text
			
			@tab_data << Mairie.new(name_ville[i], mail)
		end
	end

	# écrit les données de tab_data dans un fichier json
	def save_as_json
		temp_hash = Hash.new

		@tab_data.each { |e| temp_hash[e.city] = e.email }

		File.open("./db/emails.json","w") do |f|
			f.write(temp_hash.to_json)
		end
	end

	# écrit les données de tab_data dans un fichier spreadsheet
	def save_as_spreadsheet
		session = GoogleDrive::Session.from_config("config.json")
		ws = session.spreadsheet_by_key("1Brxuayw8758at9Od33v8M-PfZ7rD0cYT1Ln7UCezfEI").worksheets[0]

		# Changes content of cells.
		@tab_data.each_with_index  do | mairie, num_ligne |
			ws[num_ligne += 1, 1] = mairie.city 
			ws[num_ligne, 2] = mairie.email
		end
		# Changes are not sent to the server until you call ws.save().
		ws.save

		# Reloads the worksheet to get changes by other clients.
		ws.reload
	end

	# écrit les données de tab_data dans un fichier csv
	def save_as_csv

	end
 

	def perform

	end

end
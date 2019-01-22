# frozen_string_literal: true

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'pry'
require 'google_drive'
require 'csv'
# Beginning of Class
class TownHallScrapper
  # On crée un hash content les noms et les emails afin de pouvoir jouer sur les {keys => values}
  def initialize
    @towns_hash = get_townhall_urls.inject(:merge)
  end

  # Aller sur le site grace au URL et récuperer les emails des mairies
  def get_townhall_email(townhall_url)
    page_1 = Nokogiri::HTML(open(townhall_url))
    url_page = page_1.xpath('//tbody/tr[4]/td[2]')
  end

  def get_townhall_urls
    page = Nokogiri::HTML(open('http://annuaire-des-mairies.com/val-d-oise.html'))
    # Récupérer les noms des villes dans une array
    array_names = []
    # Récupérer les emails des villes dans une array
    array_emails = []
    # Récupérer les emails et les noms des villes dans une array
    array_name_emails = []
    basic_url = 'http://annuaire-des-mairies.com'

    # Aller sur le site grace au URL et récuperer les noms des mairies
    title = page.xpath('//p/a').each do |tit|
      array_names << tit.text
      @name_town = array_names
    end

    # Aller sur le site grace au url dans le href et récuperer les emails
    page.xpath('//p/a/@href').each do |url|
      url_without_dot = url.to_s[1..-1]
      urls = basic_url.to_s + url_without_dot.to_s
      array_emails1 = get_townhall_email(urls)
      array_emails2 = array_emails1[0].text
      array_emails << array_emails2
      @email_town = array_emails
    end

    # Créer une boucle pour former une array de hash contenant les noms en key et les emails en value
    for n in 0...array_names.length
      hash = { array_names[n] => array_emails[n] }
      array_name_emails << hash
    end
    array_name_emails
  end

  # Ouvrir le file (emails.json) et stocker les résultats a l'interieur
  def save_as_JSON
    File.open('../../db/emails.json', 'w') do |town|
      town.write(get_townhall_urls.to_json)
    end
  end

  def save_as_spreadsheet
    session = GoogleDrive::Session.from_config('config.json')
    # Coller la clé de l'url de votre spreadsheet personnel afin de lancer la méthode
    ws = session.spreadsheet_by_key('1h1Lt72TwZN8sbHknwTF5pOikLVVtcRNDfz0fHlxyBtc').worksheets[0]
    ws[2, 1] = 'Name of Towns'
    ws[2, 2] = 'Email'
    i = 3
    @towns_hash.each do |k, v|
      ws[i, 1] = k
      ws[i, 2] = v
      i += 1
    end
    ws.save
  end

  # Ouvrir le file (emails.csv) et stocker les résultats a l'interieur
  def save_as_csv
    CSV.open('../../db/emails.csv', 'w') do |csv|
      @towns_hash.each do |k, v|
        csv << [k, v]
      end
    end
  end
end # End Class

begin
  get_townhall_urls
rescue StandardError => e
  puts 'erreur'
end

binding.pry

puts 'end of file'

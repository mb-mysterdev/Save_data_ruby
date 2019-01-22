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
    title_indiv = []
    get = []
    array_name_emails = []
    lol = 'http://annuaire-des-mairies.com'

    title = page.xpath('//p/a').each do |tit|
      title_indiv << tit.text
      @name_town = title_indiv
    end

    page.xpath('//p/a/@href').each do |url|
      urlol = url.to_s[1..-1]
      urls = lol.to_s + urlol.to_s
      get1 = get_townhall_email(urls)
      get2 = get1[0].text
      get << get2
      @email_town = get
    end

    for n in 0...title_indiv.length
      hash = { title_indiv[n] => get[n] }
      array_name_emails << hash
    end
    array_name_emails
  end


  def save_as_JSON
    File.open('../../db/emails.json', 'w') do |town|
      town.write(get_townhall_urls.to_json)
    end
  end

  def save_as_spreadsheet
    session = GoogleDrive::Session.from_config('config.json')
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

# frozen_string_literal: true

require_relative '../lib/app/scrapper'

describe 'Mon programme de scrapping Crypto fonctionne-t-il ?' do
  it 'Le programme doit me retourner un array' do
    expect(get_townhall_urls.is_a?(rray)).to eq(true)
  end

  it 'Le tableau doit contenir à minima 100 Mairies' do
    expect(get_townhall_urls.length > 100).to eq(true)
  end

  it 'Le programme doit contenir la mairie ABLEIGES' do
    expect(get_townhall_urls.join.include?('ABLEIGES')).to eq(true)
  end

  it "Le programme doit associer à la mairie ABLEIGES l'adresse mail mairie.ableiges95@wanadoo.fr " do
    expect(get_townhall_urls[0]['ABLEIGES']).to eq('mairie.ableiges95@wanadoo.fr')
  end
end

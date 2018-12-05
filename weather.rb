require 'faraday'
require 'nokogiri'
require 'date'
require 'byebug'

class Weather

  def give_info(action, city)
    if cities_links.include? city
      if action == '-av_min'
        @avg = 4
        puts temperatures(city, 'min')
      elsif action == '-av_max'
        @avg = 5
        puts temperatures(city, 'max')
      elsif action == '-today'
        @values = { min: 4, max: 5, wind: 9, symb_del_tiempo: 10 }
        puts temperature(city)
      else
        puts 'Por favor inserte una opción correcta:  [av_max | av_min | today]'
      end
    else
      puts "Por favor inserte un municipio existente. > #{city} < no es un municipio de Barcelona "
    end
  end

  private

  def parse(link)
    link << '&affiliate_id=zdo2c683olan'
    response = Faraday.get link
    xml_doc = Nokogiri::XML(response.body)
  end

  def day_adjusted
    #the days in the API start as Saturday = 1 and Date.today starts as monday = 1
    day = Date.today.cwday.to_i
    if (1..5).to_a.include? day
      day + 2
    else
      day - 5
    end
  end

  def cities_links
    # all the links to the cities's details
    cities = {}
    xml_doc = parse('http://api.tiempo.com/index.php?api_lang=es&division=102')
    xml_doc.xpath('//data').each do |path|
      cities[path.xpath('name').text] = path.xpath('url').text
    end
    cities
  end

  def temperatures(city, kind)
    # array of temperatures (min or max)
    xml_doc = parse(cities_links[city])
    temperatures_arr = []
    xml_doc.xpath("//var[icon=#{@avg}]/data/forecast").each do |forecast|
      temperatures_arr << forecast.xpath('@value').text.to_i
    end
    average(temperatures_arr, kind)
  end

  def temperature(city)
    # data about today's temperature (min and max)
    temp_info = {}
    xml_doc = parse(cities_links[city])
    temp_info[:min_temp] = xml_doc.xpath("//var[icon=#{@values[:min]}]/data/forecast[@data_sequence = '#{day_adjusted}']/@value").text.to_i
    temp_info[:max_temp] = xml_doc.xpath("//var[icon=#{@values[:max]}]/data/forecast[@data_sequence = '#{day_adjusted}']/@value").text.to_i
    temp_info[:winds] = xml_doc.xpath("//var[icon=#{@values[:wind]}]/data/forecast[@data_sequence = '#{day_adjusted}']/@value").text
    temp_info[:detailes_explan] = xml_doc.xpath("//var[icon=#{@values[:symb_del_tiempo]}]/data/forecast[@data_sequence = '#{day_adjusted}']/@value").text
    "Hoy, la temperatura mínima es #{temp_info[:min_temp]}C y la temperatura máxima es #{temp_info[:max_temp]}C. Con #{temp_info[:winds]} y #{temp_info[:detailes_explan]}"
  end

  def average(temp, kind)
    # average of array of temperatures (min or max)
    avg = (temp.inject(0) { |sum, x| sum + x }.to_f / temp.count).round(2)
    "El promedio #{kind} de esta semana es: #{avg}C"
  end

end

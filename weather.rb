require 'faraday'
require 'nokogiri'
require 'date'

class Weather

  def initialize(request, city)
    get_city(city, request)
  end

  private

  def get_city(city, request)
    if get_cities_links.include? city
      get_citys_weather_info(city)
      get_info(request)
    else
      puts "Por favor inserte un municipio existente. > #{city} < no es un municipio de Barcelona"
    end
  end

  def get_info(request)
    if request == '-av_min'
      id = 4
      puts get_average_data(id)
    elsif request == '-av_max'
      id = 5
      puts get_average_data(id)
    elsif request == '-today'
      ids = { min: 4, max: 5, wind: 9, symb_del_tiempo: 10 }
      puts get_todays_data(ids)
    else
      puts 'Por favor inserte una opción correcta:  [-av_max | -av_min | -today]'
    end
  end

  def parse(link)
    link << '&affiliate_id=zdo2c683olan'
    response = Faraday.get link
    xml_doc = Nokogiri::XML(response.body)
  end

  def get_cities_links
    # all the links to the cities's details
    cities = {}
    xml_doc = parse('http://api.tiempo.com/index.php?api_lang=es&division=102')
    xml_doc.xpath('//data').each do |path|
      cities[path.xpath('name').text] = path.xpath('url').text
    end
    cities
  end

  def get_citys_weather_info(city)
    # parse all the info
    @xml_doc ||= parse(get_cities_links[city])
  end

  def get_average_data(id)
    # get average data result (min or max)
    temperatures_arr = []
    kind_temperature = @xml_doc.xpath("//var[icon=#{id}]/name").text
    @xml_doc.xpath("//var[icon=#{id}]/data/forecast").each do |forecast|
      temperatures_arr << forecast.xpath('@value').text.to_i
    end
    avg = average(temperatures_arr)
    "La #{kind_temperature} de esta semana en promedio es: #{avg}C"
  end

  def get_todays_data(ids)
    #data for a specific day (day adjusted)
    temp_info = {}
    @xml_doc.xpath("//var").each do |var_line|
      temp_info[var_line.xpath('icon').text.to_i] = [var_line.xpath('name').text, var_line.xpath("data/forecast[@data_sequence = '#{day_adjusted}']/@value").text]
    end
    "Hoy, con #{temp_info[ids[:wind]][1]} y #{temp_info[ids[:symb_del_tiempo]][1]}, la #{temp_info[ids[:min]][0]} es #{temp_info[ids[:min]][1]}C y la #{temp_info[ids[:max]][0]} es #{temp_info[ids[:max]][1]}C."
  end

  def day_adjusted
    #the days in the API start as Saturday = 1 and Date.today starts as monday = 1
    day = Date.today.cwday.to_i
    (1..5).to_a.include? day ? day + 2 : day - 5
    day
  end

  def average(temp)
    # average of an array of temperatures (min or max)
    avg = (temp.inject(0) { |sum, x| sum + x }.to_f / temp.count).round(2)
  end

end

require "open-uri"
require "net/http"
require "cgi"
require "oga"
require "csv"
require "json"
require "set"
require "geoutm"

class MaskStore
  NH_PROVINCE_CODES = %w(11 26 27 28 29 30 31 36 41 42 43 44 45 46 47 48 50)
  NH_DISTRICTS_URL = "http://www.nhhanaro.co.kr/nahh_70001.do?prov_c_type=ul&prov_c="
  NH_HANARO_LIST_URL = "http://www.nhhanaro.co.kr/nahh_70002.do?siteId=nahh001"
  NH_HANARO_URL = "http://www.nhhanaro.co.kr/nahh_70303.do?boardId=61&siteId=nahh001&id=nahh001_010100000000&na_bzplc="
  # prov_c=11&ccw_c=215&na_bzplc=8808983690209
  NH_HANARO_HEADERS = %w(id name phone address longitude latitude)

  POSTOFFICE_LIST_URL = "http://www.koreapost.go.kr/extra/user/searchTopList.do"
  POSTOFFICE_PROVINCE_CODES = %w(se gi bs cc jj kb jb kw jn)
  POSTOFFICE_URL = "http://www.koreapost.go.kr/extra/user/:id/gps/searchMapInfo.do"
  MASKSTORE_HEADERS = %w(id name phone address longitude latitude)
  PROVINCE_NAMES = %w(서울특별시 부산광역시 대구광역시 인천광역시 광주광역시 대전광역시 울산광역시 세종특별자치시 경기도 강원도 충청북도 충청남도 전라북도 전라남도 경상북도 경상남도 제주특별자치도)
  PROVINCE_CODES = %w(11 26 27 28 29 30 31 36 41 42 43 44 45 46 47 48 50)
  PROVINCES = Hash[PROVINCE_NAMES.zip(PROVINCE_CODES)]
  PH_DISTRICT_URL = "https://www.e-gen.or.kr/common_code/gugun_code_list.do?code="
  PH_LOCAL_URL = "https://www.e-gen.or.kr/common_code/dong_code_list.do?code="
  PHARMACY_LIST_URL = "http://www.e-gen.or.kr/egen/retrieve_pharmacy_list.do?lat=:latitude&lon=:longitude&emogdesc=&day=&holidayY=&radius=3&order=distance&currentPageNum=:pagenumber"

  PROXY_URL = "https://app.swaggerhub.com/proxy?proxy-token=nehbixc&url="
  MASKSTORE_GEO_URL = "https://8oi9s0nnth.apigw.ntruss.com/corona19-masks/v1/storesByGeo/json?lat=:latitude&lng=:longitude&m=:radius"
  MASKSTORE_GEO_HEADERS = %w(type code name addr lat lng remain_stat stock_at created_at)

  MASKSTORES_URL = "https://8oi9s0nnth.apigw.ntruss.com/corona19-masks/v1/stores/json?page=:page_no&perPage=:store_count"
  MASKSTORE_HEADERS = %w(type code name addr lat lng)
  MASKSTORE_STOCKS_URL = "https://8oi9s0nnth.apigw.ntruss.com/corona19-masks/v1/sales/json?page=:page_no&perPage=:store_count"
  MASKSTORE_STOCK_HEADERS = %w(code remain_stat stock_at created_at)


  def list_nh_provinces
    NH_PROVINCE_CODES.each do |province|
      puts province
      open("#{NH_DISTRICTS_URL}#{province}") do |f|
        f.each_line{ |line| puts nh_parse_list(line).inspect }
      end
    end
  end

  def nh_hanaro_list_by(province_id:, district_id:)
    uri = URI("#{NH_HANARO_LIST_URL}")
    res = Net::HTTP.post_form(uri, prov_c: province_id, ccw_c: district_id)
    res.body
  end

  def nh_parse_list text
    list = []
    (text || "").split("@"){ |x| puts x; list << x.split("#") }
    list
  end

  def nh_districts
    districts = []
    NH_PROVINCE_CODES.each do |province|
      open("#{NH_DISTRICTS_URL}#{province}") do |f|
        f.each_line do |line|
          nh_parse_list(line).each{ |x| districts << { province_id: province, district_id: x[0], district_name: x[1] } }
        end
      end
    end
    districts
  end

  def nh_hanaro_list
    doc = Oga.parse_html(open("#{NH_HANARO_URL}8808983690209"))
    count = 1
    doc.css(".area_result_zone > li").each do |hanaro|
      break if count > 10
      hanaro_id = hanaro["id"][7..-1]
      hanaro_name = new_line_strip(hanaro.text)
      puts hanaro_id, hanaro_name
      hanaro_info = nh_hanaro_info(hanaro_id: hanaro_id)
      hanaro_info["id"] = hanaro_id
      hanaro_info["name"] = hanaro_name
      puts hanaro_info
      count += 1
    end
  end

  def nh_hanaro_list_to_csv(filename:)
    doc = Oga.parse_html(open("#{NH_HANARO_URL}8808983690209"))
    CSV.open(filename, "w", write_headers: true, headers: NH_HANARO_HEADERS) do |csv|
      doc.css(".area_result_zone > li").each do |hanaro|
        hanaro_id = hanaro["id"][7..-1]
        hanaro_name = new_line_strip(hanaro.text)
        puts hanaro_id, hanaro_name
        hanaro_info = nh_hanaro_info(hanaro_id: hanaro_id)
        hanaro_info["id"] = hanaro_id
        hanaro_info["name"] = hanaro_name
        csv << hanaro_info
        puts hanaro_info
      end
    end
  end

  def nh_hanaro_info(hanaro_id:)
    doc = Oga.parse_html(open("#{NH_HANARO_URL}#{hanaro_id}"))
    info = {}
    doc.css(".storeinfo .style1 > dd > ul > li").each do |x|
      nop, key, value = new_line_strip(x.text).match(/^\[(.*)\](.*)/).to_a
      if key =~ /주소/
        key = "address"
      elsif key =~ /전화/
        key = "phone"
      end
      info[key] = value
    end
    nop, longitude, latitude = doc.at_css("#mapFrame").attribute("src").value.match(/locXcdn=([\d\.]*)&locYcdn=([\d\.]*)/).to_a if doc.at_css("#mapFrame")
    info["longitude"] = longitude
    info["latitude"] = latitude
    info
  end

  def new_line_strip text
    text.gsub(/\s\s+|[\r\n\t]/,'').strip
  end


  def postoffice_list_by(province_id:)
    uri = URI("#{POSTOFFICE_LIST_URL}")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri)
    req["X-Requested-With"] = "XMLHttpRequest"
    req["Content-Type"] = "application/x-www-form-urlencoded"
    req["Origin"] = "http://www.koreapost.go.kr"
    req["Referer"] = "http://www.koreapost.go.kr/extra/user/110/gps/gpsUserView.do"
    req.body = "searchTopId=#{province_id}&searchYN=Y&searchFacil=1&searchText=%25%25&subwayYN=N"
    res = http.request(req)
    JSON.parse(res.body)
  end

  def postoffice_list
    POSTOFFICE_PROVINCE_CODES.each do |province|
      # puts postoffice_list_by(province_id: province)["searchTopCount"]
      offices = postoffice_list_by(province_id: province)
      count = 1
      offices["searchTopList"].each do |office|
        break if count > 10
        info = {}
        info["id"] = office["postId"]
        info["name"] = office["postNm"]
        info["latitude"] = office["postLat"]
        info["logitude"] = office["postLon"]
        info.merge!(postoffice_info(postoffice_id: office["postId"].to_s))
        puts info.inspect
        count += 1
      end
    end
  end

  def postoffice_list_to_csv(filename:)
    CSV.open(filename, "w", write_headers: true, headers: MASKSTORE_HEADERS) do |csv|
      POSTOFFICE_PROVINCE_CODES.each do |province|
	offices = postoffice_list_by(province_id: province)
	offices["searchTopList"].each do |office|
	  info = {}
	  info["id"] = office["postId"]
	  info["name"] = office["postNm"]
	  info["latitude"] = office["postLat"]
	  info["longitude"] = office["postLon"]
	  info.merge!(postoffice_info(postoffice_id: office["postId"].to_s))
	  puts info.inspect
          csv << info
	end
      end
    end
  end

  def postoffice_info(postoffice_id:)
    doc = Oga.parse_html(open(POSTOFFICE_URL.gsub(/:id/,postoffice_id)))
    info = {}
    info["address"] = doc.css("dd")[0].text_nodes[0].text.gsub(/^: /,'').strip
    info["phone"] = doc.css("dd")[1].text.gsub(/^: /,'').strip
    info
  end

  def pharmacy
    CSV.foreach("geolocal.csv", headers: true) do |local|
      puts local.inspect
      current_page = 1
      last_page = 1
      while current_page <= last_page do
        jsonstring = ""
        open("#{PHARMACY_LIST_URL.gsub(/:longitude/,local['longitude']).gsub(/:latitude/,local['latitude']).gsub(/:pagenumber/,current_page.to_s)}"  ) do |f|
          f.each_line{ |x| jsonstring << x  }
        end
        ph_json = JSON.parse(jsonstring)
        last_page = ph_json["paging"]["lastPageNum"]
        ph_json["list"].each do |pharmacy|
          info = {}
          info["id"] = pharmacy["EMOGCODE"]
          info["name"] = pharmacy["TITLE"]
          info["phone"] = pharmacy["TEL"]
          info["address"] = pharmacy["ADDRROAD"]
          info["longitude"] = pharmacy["LON"]
          info["latitude"] = pharmacy["LAT"]
          # puts info.inspect
        end
        current_page += 1
      end
      break
    end
  end

  def pharmacy_by_geo_to_csv(filename:)
    CSV.open(filename, "w", write_headers: true, headers: MASKSTORE_HEADERS) do |csv|
      count = 1
      CSV.foreach("geolocal.csv", headers: true) do |local|
	print count, ",", local.inspect; puts
	current_page = last_page = 1
	while current_page <= last_page do
          print current_page, ",", last_page; puts
	  jsonstring = ""
	  open("#{PHARMACY_LIST_URL.gsub(/:longitude/,local['longitude']).gsub(/:latitude/,local['latitude']).gsub(/:pagenumber/,current_page.to_s)}"  ) do |f|
	    f.each_line{ |x| jsonstring << x  }
	  end
	  ph_json = JSON.parse(jsonstring)
	  last_page = ph_json["paging"]["lastPageNum"]
	  ph_json["list"].each do |pharmacy|
	    info = {}
	    info["id"] = pharmacy["EMOGCODE"]
	    info["name"] = pharmacy["TITLE"]
	    info["phone"] = pharmacy["TEL"]
	    info["address"] = pharmacy["ADDRROAD"]
	    info["longitude"] = pharmacy["LON"]
	    info["latitude"] = pharmacy["LAT"]
            csv << info
	  end
	  current_page += 1
	end
        count += 1
      end
    end
  end

  def pharmacy_from(filename:)
    count = 1
    pharmacy_set = Set.new
    CSV.foreach(filename, headers: true) do |pharmacy|
      unless pharmacy_set.include? pharmacy['id']
        pharmacy_set.add(pharmacy['id'])
        puts MASKSTORE_HEADERS.map{ |key| pharmacy[key] }.join(",")
      end
      count += 1
    end
    print count, ",", pharmacy_set.size; puts
  end

  def pharmacy_list_to_csv(input_filename:, output_filename:)
    count = 1
    pharmacy_set = Set.new
    File.open(output_filename, "w") do |f|
      f.puts MASKSTORE_HEADERS.join(",")
      CSV.foreach(input_filename, headers: true) do |pharmacy|
	unless pharmacy_set.include? pharmacy['id']
	  pharmacy_set.add(pharmacy['id'])
	  f.puts MASKSTORE_HEADERS.map{ |key| pharmacy[key] }.join(",")
          print "." if pharmacy_set.size % 100 == 0
          puts if pharmacy_set.size % 8_000 == 0
	end
	count += 1
      end
      print count, ",", pharmacy_set.size; puts
    end
  end

  def geolocal_list
    geolist = {}
    File.open("geolocal.tmp") do |f|
      f.each_line do |line|
        line.split("|")[0...-1].map{ |x| x.split(",") }.each do |y|
          geolist[y[0]] = [y[1], y[2]]
        end
      end
    end
    puts "id,name,longitude,latitude"
    File.open("local.lst") do |f|
      count = 1
      f.each_line do |local|
        if geolist[local.strip]
          print count, ",", local.strip, ",", geolist[local.strip][1], ",", geolist[local.strip][0]
          puts
          count += 1
        end
      end
    end
  end

  def sample_list_to_csv(input_filename:, output_filename:)
    count = 1
    sample_set = Set.new
    File.open(output_filename, "w") do |f|
      f.puts MASKSTORE_GEO_HEADERS.join(",")
      CSV.foreach(input_filename, headers: true) do |sample|
	unless sample_set.include? sample['code']
	  sample_set.add(sample['id'])
	  f.puts MASKSTORE_GEO_HEADERS.map{ |key| sample[key] }.join(",")
          print "." if sample_set.size % 100 == 0
          puts if sample_set.size % 8_000 == 0
	end
	count += 1
      end
      print count, ",", sample_set.size; puts
    end
  end

  def local_list
    list = []
    districts = {}
    PROVINCES.each do |province_name, province_id|
      JSON.parse(open("#{PH_DISTRICT_URL}#{province_id}").string).each do |district|
        districts["#{province_name} #{district['name']}"] = district['code']
      end
    end
    districts.each do |district_name, district_id|
      puts district_name, district_id
      localstring = ""
      open("#{PH_LOCAL_URL}#{district_id}"){ |f| f.each_line{ |x| localstring << x } }
      JSON.parse(localstring).each do |local|
        list << "#{district_name} #{local['name']}"
      end
    end
    list
  end

  def local_list_to_file(filename:)
    File.open(filename, "w") do |f|
      local_list.each{ |x| f.puts x }
    end
  end

  def find_by_geo(latitude:, longitude:)
    jsonstring = ""
    open(MASKSTORE_GEO_URL.gsub(/:latitude/,latitude.to_s).gsub(/:longitude/,longitude.to_s).gsub(/:radius/,"1000")) do |f|
      f.each_line{ |x| jsonstring << x }
    end
    JSON.parse(jsonstring)
  end

  def maskstore_geo_list_to_csv(filename:)
    count = 1
    CSV.open(filename, "w", write_headers: true, headers: MASKSTORE_GEO_HEADERS) do |csv|
      CSV.foreach("geolocal.csv", headers: true) do |local|
        puts local.inspect
        retry_count = 0
        begin
          find_by_geo(latitude: local["latitude"], longitude: local["longitude"])["stores"].each do |store|
            csv << store
          end
        rescue Exception => e
          sleep 0.2
          retry_count += 1
          retry if retry_count < 5
          puts local["name"], e.message
        end
        count += 1
      end
    end
  end

  def geo_to_utm(input_filename:, output_filename:)
    out = []
    headers = nil
    File.open(input_filename){ |f| headers = f.readline.strip.split(',') }
    headers << "north" << "east"
    CSV.open(output_filename, "w", write_headers: true, headers: headers) do |csv|
      CSV.foreach(input_filename, headers: true) do |local|
        info = local.to_hash
        utm = GeoUtm::LatLon.new(local['latitude'].to_f, local['longitude'].to_f).to_utm
        info['north'], info['east'] = utm.n, utm.e
        csv << info
      end
    end
    out
  end

  def maskstores(page_no:, store_count: )
    jsonstring = ''
    open(MASKSTORES_URL.gsub(/:page_no/,page_no.to_s).gsub(/:store_count/, store_count.to_s)) do |f|
      f.each_line{ |x| jsonstring << x }
    end
    JSON.parse(jsonstring)
  end

  def maskstore_list_to_csv(filename: )
    CSV.open(filename, 'w', write_headers: true, headers: MASKSTORE_HEADERS) do |csv|
      1.upto(maskstores(page_no: 1, store_count: 500)['totalPages']) do |n|
        puts n
        maskstores(page_no: n, store_count: 500)['storeInfos'].each do |store|
          print '.'
          csv << store
        end
        puts
      end
    end
  end

  def stocks(page_no:, store_count: )
    jsonstring = ''
    open(MASKSTORE_STOCKS_URL.gsub(/:page_no/,page_no.to_s).gsub(/:store_count/,store_count.to_s)) do |f|
      f.each_line{ |x| jsonstring << x }
    end
    JSON.parse(jsonstring)
  end

  def stock_list_to_csv(filename: )
    CSV.open(filename, 'w', write_headers: true, headers: MASKSTORE_STOCK_HEADERS) do |csv|
      1.upto(stocks(page_no: 1, store_count: 500)['totalPages']) do |n|
        puts n
        stocks(page_no: n, store_count: 500)['sales'].each do |stock|
          print '.'
          csv << stock
        end
      end
    end
  end

end

if ARGV.length > 0
  @maskstore = MaskStore.new
  @maskstore.nh_hanaro_list_to_csv(filename: "maskstore-nh-hanaro.csv") if ARGV[0].include? "n"
  @maskstore.postoffice_list_to_csv(filename: "maskstore-postoffice.csv") if ARGV[0].include? "p"
  @maskstore.pharmacy_list_to_csv(input_filename: "maskstore-pharmacy-by-geo.csv", output_filename: "maskstore-pharmacy.csv") if ARGV[0].include? "h"
  if ARGV[0].include? "m"
    @maskstore.maskstore_geo_list_to_csv(filename: ARGV[1] || "maskstore-geo.csv")
  end
  if ARGV[0].include? "s"
    @maskstore.stock_list_to_csv(filename: ARGV[1] || "stock.csv")
  end
else
  puts "ruby maskstore.rb n|p"
  puts "n: list nonhyup hanaro mart"
  puts "p: list postoffice"
  puts "h: list pharmacy"
  puts "m: list maskstore-geo"
end


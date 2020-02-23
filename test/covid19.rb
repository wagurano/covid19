require "open-uri"
require "oga"
require "csv"

class Covid19
  CONFIRMED_PERSON_URL = "http://ncov.mohw.go.kr/bdBoardList.do?pageIndex=&ncv_file_seq=&file_path=&file_name=&brdId=1&brdGubun=12&search_item=1&search_content="
  CLINICS_URL = "http://www.mohw.go.kr/react/popup_200128.html"
  SAMPLING = "*(검체채취 가능)"
  STATUS_HEADERS = {
    ko: %w(환자 인적사항 감염경로 확진일자 입원기관 접촉자수(격리조치중)),
    en: %w(id desc infection confirmed_at hospital contact) 
  }
  CLINIC_HEADERS = {
    ko: %w(연번 시도 시군구 선별진료소 전화번호 검체가능),
    en: %w(id province district clinic phone sampling)
  }
  
  
  def status_confirmed(person_id: )
    doc = Oga.parse_html(open("#{CONFIRMED_PERSON_URL}#{person_id}"))
    infos = []
    doc.css('.info_s > li').each do |info|
      infos << info.css('span')[1].children.map{ |x| x.text.gsub(/[\t *\t|\r\n\t]/,'') }.join()
    end
    Hash[STATUS_HEADERS[:ko].zip(infos)]
  end

  def route_confirmed(person_id: )
    doc = Oga.parse_html(open("#{CONFIRMED_PERSON_URL}#{person_id}"))
    infos = []
    doc.css('.info_mtxt > ul > li').each do |info|
      infos << info.text
    end
    infos
  end

  def last_confirmed_person_id
    doc = Oga.parse_html(open("#{CONFIRMED_PERSON_URL}"))
    infos = []
    doc.css('.info_s > li').each do |info|
      infos << info.css('span')[1].children.map{ |x| x.text.gsub(/[\t *\t|\r\n\t]/,'') }.join()
      break
    end
    infos[0].to_i
  end

  def list_the_confirmed(from:, to:)
    from.upto(to).each do |id|
      puts status_confirmed(person_id: id)
    end
  end

  def list_the_confirmed_to_csv(from:, to:, filename:)
    CSV.open(filename, "w", write_headers: true, headers: STATUS_HEADERS[:ko]) do |csv|
      from.upto(to).each do |id|
        csv << status_confirmed(person_id: id)
      end
    end
  end

  def list_routes_of_the_confirmed(from:, to:)
    from.upto(to).each do |id|
      puts route_confirmed(person_id: id)
    end
  end

  def list_routes_of_the_confirmed_to_file(from:, to:, foldername: )
    from.upto(to).each do |id|
      File.open("#{foldername}/#{id}.txt", "w") do |f|
        f.puts route_confirmed(person_id: id)
      end
    end
  end

  def list_clinics
    doc = Oga.parse_html(open(CLINICS_URL, encoding: Encoding::UTF_8))
    clinics = []
    count = 1
    doc.css(".tb_center > tr").each do |row|
      clinic = [count] 
      row.css("td").each{ |x| clinic << x.text }
      if clinic[3].include? SAMPLING
        clinic[3].gsub!(SAMPLING,'').strip!
        clinic << "Y"
      else
        clinic << "N"
      end
      clinics << Hash[CLINIC_HEADERS[:ko].zip(clinic)]
      count += 1
    end
    clinics
  end

  def list_clinics_to_csv(filename:) 
    doc = Oga.parse_html(open(CLINICS_URL, encoding: Encoding::UTF_8))
    count = 1
    CSV.open(filename, "w", write_headers: true, headers: CLINIC_HEADERS[:ko]) do |csv|
      doc.css(".tb_center > tr").each do |row|
	clinic = [count] 
	row.css("td").each{ |x| clinic << x.text }
	if clinic[3].include? SAMPLING
	  clinic[3].gsub!(SAMPLING,'').strip!
	  clinic << "Y"
	else
	  clinic << "N"
	end
	csv << Hash[CLINIC_HEADERS[:ko].zip(clinic)]
	count += 1
      end
    end
  end
end

if ARGV.length > 0
  @covid = Covid19.new
  @covid.list_the_confirmed_to_csv(from: 1, to: @covid.last_confirmed_person_id, filename: "covid19-confirmed-list-kr.csv") if ARGV[0].include? "c"
  @covid.list_routes_of_the_confirmed_to_file(from: 1, to: @covid.last_confirmed_person_id, foldername: "routes") if ARGV[0].include? "r"
  @covid.list_clinics_to_csv(filename: "covid19-clinic-list-kr.csv") if ARGV[0].include? "k"
else
  puts "ruby covid19.rb c|r|k"
  puts "c: list the confirmed"
  puts "r: list routes of the confirmed"
  puts "k: list clinics"
end


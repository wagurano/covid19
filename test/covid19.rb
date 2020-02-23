require "open-uri"
require "oga"
require "csv"

class Covid19
  CONFIRMED_PERSON_URL = "http://ncov.mohw.go.kr/bdBoardList.do?pageIndex=&ncv_file_seq=&file_path=&file_name=&brdId=1&brdGubun=12&search_item=1&search_content="
  STATUS_HEADERS = {
    ko: %w(환자 인적사항 감염경로 확진일자 입원기관 접촉자수(격리조치중)),
    en: %w(id desc infection confirmed_at hospital contact) 
  }
  
  def fetch_confirmed_person_url(person_no: )
    doc = Oga.parse_html(open("#{CONFIRMED_PERSON_URL}#{person_no}"))
    infos = []
    doc.css('.info_s > li').each do |info|
      infos << info.css('span')[1].children.map{ |x| x.text.gsub(/[\t *\t|\r\n\t]/,'') }.join()
    end
    infos
  end

  def fetch_confirmed_person_route_url(person_no: )
    doc = Oga.parse_html(open("#{CONFIRMED_PERSON_URL}#{person_no}"))
    infos = []
    doc.css('.info_mtxt > ul > li').each do |info|
      infos << info.text
    end
    infos
  end

  def last_confirmed_person_url
    doc = Oga.parse_html(open("#{CONFIRMED_PERSON_URL}"))
    infos = []
    doc.css('.info_s > li').each do |info|
      infos << info.css('span')[1].children.map{ |x| x.text.gsub(/[\t *\t|\r\n\t]/,'') }.join()
      break
    end
    infos[0].to_i
  end



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
end

@covid = Covid19.new
@covid.list_the_confirmed_to_csv(from: 1, to: @covid.last_confirmed_person_id, filename: "covid19-confirmed-list-kr.csv")
@covid.list_routes_of_the_confirmed_to_file(from: 1, to: @covid.last_confirmed_person_id, foldername: "routes")


require "minitest/autorun"
require "covid19"

class TestCovid19 < Minitest::Test
  def setup
    @covid = Covid19.new
  end

  def test_fetch_confirmed_person_url
    assert_equal %w(31 여(한국,'59) 확인중(확인중) 2.18 대구의료원 1160(1160)), @covid.fetch_confirmed_person_url(person_no: 31)
  end

  def test_fetch_confirmed_person_route_url
    id_2_text = ["(1월 22일) 저녁 김포공항을 통해 귀국(우한 출발 상하이 경유)하던 중 검역 과정에서 발열(37.8도)과 인후통이 있었으며 호흡기 증상은 없어 ‘능동감시 대상자’로 분류, 환자에게는 증상 변화 시 신고 방법 등을 안내하고 관할 보건소에 통보. 환자는 공항에서 택시를 이용해 자택으로 이동하였고 이후 자택에서만 머물렀음"]
    assert_equal id_2_text,  @covid.fetch_confirmed_person_route_url(person_no: 2)

    id_31_texts = [
      "대구 수성구 보건소에서 검사 실시 후 양성 확인, 국가지정입원치료병상(대구의료원) 격리",
      "의료기관(새로난한방병원, 대구 수성구)에 2월 7일부터 입원치료 중 2월 10일경부터 발열이 있었다고 하며, 2월 14일 실시한 영상 검사상 폐렴 소견을 확인하여 항생제 치료 등을 실시하던 중, 2월 17일 대구 수성구 보건소를 방문하여 실시한 진단검사 결과 2월 18일 확진되어, 현재 국가지정입원치료 병상(대구의료원)에 격리입원 중", "환자는 2019년 12월 이후 현재까지 외국을 방문한 적이 없었다고 진술하였으며, 감염원, 감염경로와 접촉자에 대해서는 즉각대응팀, 관할 지자체가 함께 역학조사를 진행 중", "환자는 2월 7일부터 17일까지 대구 수성구 소재 의료기관(새로난한방병원)에 입원하였으며, 현재까지 해당 의료기관에서 접촉자 128명*이 확인되었다.이 중 병원에 입원 중이던 재원환자 32명은 대구의료원으로 이송되었고, 나머지 접촉자에 대해서는 자가격리 등 조치 중",
      "(2월 6일) 9시 30분경 자차 이용하여 대구 동구 소재 회사 출근",
      "(2월 7일) 자차 이용하여 17시경 대구 수성구 소재 의료기관(새로난 한방병원) 방문하여 외래 진료, 자차 이용하여 자택 귀가, 21시경 자차 이용하여 대구 수성구 소재 의료기관(새로난한방병원) 입원",
      "(2월 8일) 대구 수성구 소재 의료기관(새로난한방병원) 입원 중",
      "(2월 9일) 7시 30분경 자차 이용하여 대구 남구 소재 교회(신천지예수교 증거장막성전 다대오지파대구교회, 대명로 81) 방문, 9시 30분경 자차 이용하여 수성구 소재 의료기관(새로난한방병원)으로 이동",
      "(2월 10~14일) 대구 수성구 소재 의료기관(새로난한방병원) 입원 중",
      "(2월 15일) 11시 50분경 택시 이용하여 대구 동구 소재 호텔(퀸벨호텔 8층) 방문, 점심 식사 후 택시 이용하여 수성구 소재 의료기관(새로난한방병원)으로 이동",
      "(2월 16일) 7시 20분경 택시 이용하여 대구 남구 소재 교회(신천지예수교 증거장막성전 다대오지파대구교회) 방문, 9시 20분경 택시 이용하여 수성구 소재 의료기관(새로난한방병원)으로 이동",
      "(2월 17일) 15시 30분경 지인 차량 이용하여 수성구보건소 방문, 17시경 택시 이용하여 수성구 소재 의료기관(새로난한방병원) 으로 이동 중 다시 보건소로 이동, 18시경 국가지정입원치료병상(대구의료원)으로 이송"
    ]
    assert_equal id_31_texts, @covid.fetch_confirmed_person_route_url(person_no: 31)

    assert_equal [], @covid.fetch_confirmed_person_route_url(person_no: 82)
  end

  def test_last_person_no
    assert_equal 82, @covid.last_confirmed_person_url()
  end

  def test_list_routes
    skip
    puts "list status"
    1.upto(82).each do |num|
      puts "====> #{num}"
      puts @covid.fetch_confirmed_person_url(person_no: num)
    end
    
    puts "list routes"
    1.upto(82).each do |num|
      puts "====> #{num}"
      puts @covid.fetch_confirmed_person_route_url(person_no: num)
    end
  end

  def test_run
    # puts @covid.status_confirmed(person_id: 1)
    # puts @covid.route_confirmed(person_id: 1)
    # @covid.list_the_confirmed(from: 1, to: @covid.last_confirmed_person_id)
    # @covid.list_the_confirmed_to_csv(from: 1, to: @covid.last_confirmed_person_id, filename: "a.csv")
    
    # @covid.list_routes_of_the_confirmed(from: 1, to: 3)
    @covid.list_routes_of_the_confirmed_to_file(from: 1, to: 3, foldername: "routes")
  end

end

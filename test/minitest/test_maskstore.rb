require "minitest/autorun"
require "maskstore"

class TestMaskStore < Minitest::Test
  def setup
    @maskstore = MaskStore.new
  end

  def test_nh_hanaro_list
    skip
    assert @maskstore.list_nh_provinces
    assert @maskstore.nh_hanaro_list_by(province_id: "11", district_id: "110")
    assert @maskstore.nh_hanaro_list_by(province_id: "11", district_id: "440")
  end

  def test_parse_nhlist_text
    skip
    # assert_equal [["8808983690971", "서서울농협 하나로마트 사직점", "0", "0", "1", "0"]], @maskstore.nh_parse_list("8808983690971#서서울농협 하나로마트 사직점#0#0#1#0@")
    # assert_equal [ [ "110", "종로구"], ["140", "중구"], ["170", "용산구"] ], @maskstore.nh_parse_list("110#종로구@140#중구@170#용산구@")
    # assert_equal [], @maskstore.nh_parse_list("8808983740249#대정농협 하나로마트#0#0#1#0@8808983740263#대정농협 하나로마트 무릉점#0#0#0#0@8808983740270#대정농협 하나로마트 보성점#0#0#0#0@8808983740348#서귀포농협 하나로마트 법환점#0#0#0#0@8808983740393#서귀포농협 하나로마트 천지간이점#0#0#1#0@8808983740331#서귀포농협 하나로마트 토평점#0#0#0#0@8808983740508#성산일출봉농협 하나로마트#0#0#1#0@8808983740515#성산일출봉농협 하나로마트 성산포점#0#0#1#0@8808983740294#안덕농협 하나로마트 사계점#0#0#1#0@8808983740300#안덕농협 하나로마트 창천점#0#0#1#0@8808983740430#위미농협 하나로마트#0#0#0#0@8808983740416#위미농협 하나로마트 신례점#0#0#1#0@8808983740614#위미농협 하나로마트 하례2리점#0#0#1#0@8808983740423#위미농협 하나로마트 하례점#0#0#1#0@8808983324654#제주감귤농협 일출봉관광체험타운#0#0#0#0@8808983740454#제주남원농협 하나로마트#0#0#1#0@8808983300122#제주안덕농협 하나로마트#0#0#0#0@8808983740607#중문농협 하나로마트 본점#0#0#1#0@8808983740478#표선농협 하나로마트#0#0#0#0@8808983740485#표선농협 하나로마트 가시점#0#0#1#0@8808983740492#표선농협 하나로마트 성읍점#0#0#1#0@8808983740409#효돈농협 하나로마트#0#0#0#0@")
  end

  def test_new_line_strip
    skip
    assert_equal "가남농협 하나로마트",  @maskstore.new_line_strip("\r\n                                            \r\n                                                가남농협 하나로마트\r\n                                            \r\n                                            \r\n")
  end

  def test_hanaro_info
    skip
    # assert @maskstore.nh_hanaro_info(hanaro_id: "8808983420110")
    assert @maskstore.nh_hanaro_info(hanaro_id: "8808990646701")
  end

  def test_postoffice_list
    skip
    # assert @maskstore.postoffice_list_by(province_id: "se")
    assert @maskstore.postoffice_list
  end

  def test_postoffice_info
    skip
    assert @maskstore.postoffice_info(postoffice_id: "10023")
  end

  def test_pharmarcy
    skip
    assert @maskstore.pharmacy
  end

  def test_local_list
    skip
    assert @maskstore.local_list
  end

  def test_local_list_to_file
    skip
    assert @maskstore.local_list_to_file(filename: "a.txt")
  end

  def test_find_by_geo
    skip
    # assert_equal "https://app.swaggerhub.com/proxy?proxy-token=nehbixc&url=https%3A%2F%2F8oi9s0nnth.apigw.ntruss.com%2Fcorona19-masks%2Fv1%2FstoresByGeo%2Fjson%3Flat%3D37.5698424359%26lng%3D126.9780944774%26m%3D1000", @maskstore.find_by_geo(latitude: 37.5698424359, longitude: 126.9780944774)
    # assert_equal JSON.parse('{ "count": 45 }')["count"], @maskstore.find_by_geo(latitude: 37.5698424359, longitude: 126.9780944774)["count"]
    assert_equal %w(addr code created_at lat lng name remain_stat stock_at type), @maskstore.find_by_geo(latitude: 37.5698424359, longitude: 126.9780944774)['stores'].first.keys
  end

  def test_maskstore_geo_list
    skip
    # assert @maskstore.maskstore_geo_list_to_csv(filename: "a.csv")
  end

  def test_maskstore_geo_to_utm
    skip
    # assert_equal ["37.4819251305595", "127.057440206035"], @maskstore.geo_to_utm(filename: "geolocal.csv")
    # assert_equal [4150108.17601028, 328246.99697792367], @maskstore.geo_to_utm(filename: "geolocal.csv")
    # assert_equal [4150108.17601028, 328246.99697792367], @maskstore.geo_to_utm(input_filename: "geolocal.csv", output_filename: "utm_geolocal.csv")
  end

  def test_maskstores
    skip
    assert @maskstore.maskstores(page_no: 1, store_count: 500)
  end

  def test_stocks
    skip
    assert @maskstore.stocks(page_no: 1, store_count: 500)
  end

  def test_run
    # assert @maskstore.nh_districts
    # assert @maskstore.nh_hanaro_list
    # assert @maskstore.nh_hanaro_list_to_csv(filename: "a.csv")
    # assert @maskstore.postoffice_list_to_csv(filename: "a.csv")
    # assert @maskstore.pharmacy_by_geo_to_csv(filename: "a.csv")
    # assert @maskstore.pharmacy_from(filename: "a.csv")
    # assert @maskstore.pharmacy_list_to_csv(input_filename: "a.csv", output_filename: "b.csv")
    # assert @maskstore.sample_list_to_csv(input_filename: "a.csv", output_filename: "b.csv")
    # assert @maskstore.maskstore_geo_list_to_csv(filename: "a.csv")
    # assert @maskstore.maskstore_list_to_csv(filename: 'a.csv')
    assert @maskstore.stock_list_to_csv(filename: 'a.csv')
  end

end

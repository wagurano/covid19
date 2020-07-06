require "minitest/autorun"
require "covid19"

class TestCovid19 < Minitest::Test
  def setup
    @covid = Covid19.new
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

  def test_list_clinics
    skip
    assert @covid.list_clinics
  end

  def test_to_geo
    assert @covid.to_geo
  end

  def test_list_status_confirmed_wuhanviruskr
    skip
    assert @covid.list_status_confirmed_wuhanviruskr
  end

  def test_run
    # puts @covid.status_confirmed(person_id: 1)
    # puts @covid.route_confirmed(person_id: 1)
    # @covid.list_the_confirmed(from: 1, to: @covid.last_confirmed_person_id)
    # @covid.list_the_confirmed_to_csv(from: 1, to: @covid.last_confirmed_person_id, filename: "a.csv")
    
    # @covid.list_routes_of_the_confirmed(from: 1, to: 3)
    # @covid.list_routes_of_the_confirmed_to_file(from: 1, to: 3, foldername: "routes")

    # @covid.list_clinics_to_csv(filename: "a.csv")

    # @covid.list_the_confirmed_wuhanviruskr_to_csv(filename: "a.csv")
    # @covid.list_routes_of_the_confirmed_wuhanviruskr
    # @covid.list_routes_of_the_confirmed_wuhanviruskr_to_file(foldername: "wuhanviruskr")
  end

end

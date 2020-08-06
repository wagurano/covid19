require 'csv'

headers = %w(type code name addr lat lng remain_stat)
Dir['maskstore-2*.csv'].each do |f|
  puts f
  CSV.open("remains-#{f}", 'w', write_headers: true, headers: headers) do |csv|
    count = 1
    CSV.foreach(f, headers: true) do |store|
      print "." if count % 50 == 0
      csv << store.to_hash
      puts if count % 4_000 == 0
      count += 1
    end
  end
end

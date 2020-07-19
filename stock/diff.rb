require 'csv'

def diff_csv_file(filename)
  id, status = "", ""
  CSV.foreach(filename) do |x|
    if id == x[0]
      if status == x[2]
      else 
        puts x.to_a.join(',')
        status = x[2]
      end
    else
      puts x.to_a.join(',')
      id, status = x[0], x[2]
    end
  end
end

def diff
  id, status = "", ""
  ARGF.each do |line|
    x = line.split(",")
    if id == x[0]
      if status == x[2]
      else 
        puts x.to_a.join(',')
        status = x[2]
      end
    else
      puts x.to_a.join(',')
      id, status = x[0], x[2]
    end
  end
end

diff

cd #{project_path}
#{ruby_path} test/maskstore.rb s stock-`TZ='Asia/Seoul' date +%Y%m%d%H%M%S`.csv

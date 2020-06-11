cd #{project_path} 
tar -czf stock-`date '+%Y%m%d'`.tar.gz  stock-`date '+%Y%m%d'`*.csv && rm stock-`date '+%Y%m%d'`*.csv 

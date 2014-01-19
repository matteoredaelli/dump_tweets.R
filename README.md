dump_tweets.R
=============

VERSION

0.4-SNASPHOT - january 2014

INSTALLATION

1) you have to register an application at  Twitter API 
2) copy config-sample.R to config.R and update it with your settings
3) use teh file setup_db.sql to create a new mysql database and table

  ex. (if you use linux) mysql -u root < setup_db.sql

USAGE


Rscript search.R -h

Rscript search.R

Rscript search.R -q "opensource OR opensource"

Rscript users.R -h

Rscript users.R

Rscript users.R -L 

Rscript users.R -T

Rscript hashtags.R -h


Regards

matteo DOT redaelli AT gmail DOT com




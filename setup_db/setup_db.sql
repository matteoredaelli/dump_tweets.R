DROP DATABASE IF EXISTS twitter;

CREATE DATABASE twitter
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;

use twitter;

source setup_db_00.sql;
source setup_db_01.sql;
source setup_db_02.sql;
source setup_db_03.sql;


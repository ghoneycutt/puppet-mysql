# Remove the test database
DROP DATABASE IF EXISTS test;

# For monitoring
CREATE DATABASE IF NOT EXISTS monitoring;

USE monitoring;

CREATE TABLE IF NOT EXISTS data (
  id INT UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT,
  text CHAR(80),
  PRIMARY KEY(id)
);

REPLACE INTO data SET id = 1, text = 'test_data';

GRANT SELECT on monitoring.* TO 'monitoring'@'%' IDENTIFIED BY 'badpassword';


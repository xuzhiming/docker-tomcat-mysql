-- # create databases

CREATE DATABASE IF NOT EXISTS `test`;
CREATE DATABASE IF NOT EXISTS `primary`;
CREATE DATABASE IF NOT EXISTS `secondary`;

-- # create root user and grant rights
CREATE USER 'test'@'%' IDENTIFIED BY 'root';
GRANT ALL ON *.* TO 'test'@'%';
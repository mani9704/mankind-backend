CREATE DATABASE IF NOT EXISTS `mankind_matrix_db`;

CREATE USER IF NOT EXISTS 'matrix_user'@'%' IDENTIFIED BY 'matrix_pass';

GRANT ALL PRIVILEGES ON `mankind_matrix_db`.* TO 'matrix_user'@'%';

FLUSH PRIVILEGES;
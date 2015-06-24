CREATE DATABASE IF NOT EXISTS slack_summary;

USE slack_summary;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT,
  slack_id VARCHAR(32) NOT NULL,
  name VARCHAR(32),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS articles (
  id INT AUTO_INCREMENT,
  user_id INT,
  channel_id VARCHAR(32),
  title VARCHAR(64),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS messages (
  id INT AUTO_INCREMENT,
  channel_id VARCHAR(32),
  ts CHAR(17),
  text VARCHAR(5000),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS articles_messages (
  article_id INT,
  message_id INT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME,
  PRIMARY KEY (article_id, message_id)
);

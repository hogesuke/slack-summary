CREATE DATABASE IF NOT EXISTS slack_summary;

USE slack_summary;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT,
  slack_user_id VARCHAR(12) NOT NULL,
  name VARCHAR(21),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS articles (
  id INT AUTO_INCREMENT,
  user_id INT,
  slack_team_id VARCHAR(12),
  slack_channel_id VARCHAR(12),
  title VARCHAR(128),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS messages (
  id INT AUTO_INCREMENT,
  user_id INT,
  slack_team_id VARCHAR(12),
  slack_channel_id VARCHAR(12),
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

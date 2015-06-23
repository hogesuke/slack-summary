CREATE DATABASE IF NOT EXISTS slack_summary;

USE slack_summary;

-- todo created_datetime -> created_at
-- todo updated_at もいる

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT,
  slack_id VARCHAR(32) NOT NULL,
  name VARCHAR(32),
  created_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS articles (
  id INT AUTO_INCREMENT,
  user_id INT,
  channel_id VARCHAR(32),
  title VARCHAR(64),
  created_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS messages (
  id INT AUTO_INCREMENT,
  channel_id VARCHAR(32),
  ts CHAR(17),
  text VARCHAR(5000),
  created_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS articles_messages (
  article_id INT,
  message_id INT,
  created_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (article_id, message_id)
);

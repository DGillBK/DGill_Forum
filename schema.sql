-- DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS topic;
DROP TABLE IF EXISTS post;
DROP TABLE IF EXISTS comment;


-- CREATE TABLE user (
--   id SERIAL PRIMARY KEY,
--   name VARCHAR UNIQUE NOT NULL,  
--   email VARCHAR UNIQUE NOT NULL,
--   password_digest VARCHAR NOT NULL
--   profile_pic VARCHAR
-- );

CREATE TABLE topic (
  id SERIAL PRIMARY KEY,
  title VARCHAR NOT NULL,  
  image_url VARCHAR NOT NULL,
  vote INTEGER DEFAULT 0,
  author VARCHAR NOT NULL
  -- user_id INTEGER REFERENCES user(id)
);

CREATE TABLE post (
  id SERIAL PRIMARY KEY,
  title VARCHAR NOT NULL,  
  description VARCHAR NOT NULL,
  image_url VARCHAR NOT NULL,
  vote INTEGER DEFAULT 0,
  author VARCHAR NOT NULL,
  -- user_id INTEGER REFERENCES user(id),
  topic_id INTEGER REFERENCES topic(id)
);

CREATE TABLE comment (
  id SERIAL PRIMARY KEY,
  description VARCHAR NOT NULL,
  vote INTEGER DEFAULT 0,
  author VARCHAR NOT NULL,
  -- user_id INTEGER REFERENCES user(id),
  post_id INTEGER REFERENCES post(id)
);







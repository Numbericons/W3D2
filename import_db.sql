PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname VARCHAR(255) NOT NULL,
    lname VARCHAR(255) NOT NULL
);


CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    body VARCHAR(255) NOT NULL,
    author_id INTEGER,

    FOREIGN KEY (author_id) REFERENCES users(id)
);


CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    question_id INTEGER,
    user_id INTEGER,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);


CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    question_id INTEGER,
    user_id INTEGER,
    body VARCHAR(255) NOT NULL,
    subject_question VARCHAR(255) NOT NULL,
    parent_id INTEGER,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (parent_id) REFERENCES replies(id)
);


CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    question_id INTEGER,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO 
    users (fname, lname)
VALUES
    ('Bill', 'Brasky'),
    ('Sarah', 'Chalk'),
    ('Terrence','Phillip'),
    ('Dealers', 'Choice'),
    ('Frodo', 'Baggins'),
    ('Bilbo', 'Baggins');

INSERT INTO
    questions (title, body, author_id)
VALUES
    ('Kitchen', 'Why is it so messy?', (SELECT id FROM users WHERE fname = 'Bill' AND lname = 'Brasky')),
    ('Kitchen', 'Why is it so clean?', (SELECT id FROM users WHERE fname = 'Sarah' AND lname = 'Chalk'));

INSERT INTO
    question_follows (question_id, user_id)
VALUES
    ((SELECT id FROM questions WHERE body = 'Why is it so messy?'), (SELECT id FROM users WHERE fname = 'Bill' AND lname = 'Brasky')),
    ((SELECT id FROM questions WHERE body = 'Why is it so messy?'), (SELECT id FROM users WHERE fname = 'Frodo' AND lname = 'Baggins')),
    ((SELECT id FROM questions WHERE body = 'Why is it so messy?'), (SELECT id FROM users WHERE fname = 'Bilbo' AND lname = 'Baggins')),
    ((SELECT id FROM questions WHERE body = 'Why is it so clean?'), (SELECT id FROM users WHERE fname = 'Terrence' AND lname = 'Phillip')),
    ((SELECT id FROM questions WHERE body = 'Why is it so clean?'), (SELECT id FROM users WHERE fname = 'Sarah' AND lname = 'Chalk'));

INSERT INTO
    replies (question_id, user_id, body, subject_question, parent_id)
VALUES
    ((SELECT id FROM questions WHERE body = 'Why is it so messy?'),
    (SELECT id FROM users WHERE fname = 'Sarah' AND lname = 'Chalk'),
    'Stop whining',
    (SELECT title FROM questions WHERE title = 'Kitchen'), NULL
    ),

    ((SELECT id FROM questions WHERE body = 'Why is it so messy?'),
    (SELECT id FROM users WHERE fname = 'Bill' AND lname = 'Brasky'),
    'As if',
    (SELECT title FROM questions WHERE title = 'Kitchen'), 1
    ),
    
    ((SELECT id FROM questions WHERE body = 'Why is it so messy?'),
    (SELECT id FROM users WHERE fname = 'Sarah' AND lname = 'Chalk'),
    'Good one nerd',
    (SELECT title FROM questions WHERE title = 'Kitchen'), 1
    );

INSERT INTO
    question_likes (user_id, question_id)
VALUES
    ((SELECT id FROM users WHERE fname = 'Sarah' AND lname = 'Chalk'),
    (SELECT id FROM questions WHERE body = 'Why is it so clean?')),
    ((SELECT id FROM users WHERE fname = 'Terrence' AND lname = 'Phillip'),
    (SELECT id FROM questions WHERE body = 'Why is it so clean?')),
    ((SELECT id FROM users WHERE fname = 'Bilbo' AND lname = 'Baggins'),
    (SELECT id FROM questions WHERE body = 'Why is it so messy?')),
    ((SELECT id FROM users WHERE fname = 'Frodo' AND lname = 'Baggins'),
    (SELECT id FROM questions WHERE body = 'Why is it so messy?')),
    ((SELECT id FROM users WHERE fname = 'Bill' AND lname = 'Brasky'),
    (SELECT id FROM questions WHERE body = 'Why is it so messy?'));

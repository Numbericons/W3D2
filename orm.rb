require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
    include Singleton

    def initialize
        super('user_questions.db')
        self.type_translation = true
        self.results_as_hash = true
    end
end

class Question
    def self.find_by_user_id(id)
        data = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT * FROM questions WHERE id = ?
        SQL
        data.map { |datum| Question.new(datum)}
    end

    def self.most_followed(n=1)
        QuestionFollow.most_followed_questions(n)
    end

    def self.most_liked(n)
        QuestionLike.most_liked_questions(n)
    end

    attr_accessor :id, :title, :body, :author_id

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @author_id = options['author_id']
    end

    def author
        data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
            SELECT * FROM users WHERE id = ?
        SQL
        data.map { |datum| User.new(datum)}
    end
    
    def replies
        Reply.find_by_question_id(id)
    end

    def followers
        QuestionFollow.followers_for_question_id(@id)
    end

    def likers
        QuestionLike.likers_for_question_id(@id)
    end

    def num_likes
        QuestionLike.num_likes_for_question_id(@id)
    end
end

class User
    def self.find_by_name(fname, lname)
        data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
            SELECT * FROM users WHERE fname = ? AND lname = ?
        SQL
        data.map { |datum| User.new(datum)}
    end

    attr_accessor :fname, :lname

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def authored_questions
        Question.find_by_user_id(@id)
    end

    def authored_replies
        Reply.find_by_user_id(@id)
    end

    def followed_questions
        QuestionFollow.followers_for_user_id(@id)
    end

    def liked_questions
        QuestionLike.liked_questions_for_user_id(@id)
    end

    def average_karma
        # data = QuestionsDatabase.instance.execute(<<-SQL)
        #     SELECT * FROM users WHERE fname = ? AND lname = ?
        # SQL
    end
end

class Reply
    def self.find_by_user_id(user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT * FROM replies WHERE user_id = ?
        SQL
        data.map { |datum| Reply.new(datum)}
    end

    def self.find_by_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT * FROM replies WHERE question_id = ?
        SQL
        data.map { |datum| Reply.new(datum)}
    end

    attr_accessor :id, :question_id, :user_id, :body, :subject_question, :parent_id

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
        @body = options['body']
        @subject_question = options['subject_question']
        @parent_id = options['parent_id']
    end

    def author
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT * FROM users WHERE id = ?
        SQL
        data.map { |datum| User.new(datum)}
    end

    def question
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT * FROM questions WHERE id = ?
        SQL
        data.map { |datum| Question.new(datum)}
    end

    def parent_reply
        raise "i ain't got no parents" if parent_id.nil?
        data = QuestionsDatabase.instance.execute(<<-SQL, parent_id)
            SELECT * FROM replies WHERE parent_id = ?
        SQL
        data.map { |datum| Reply.new(datum)}
    end

    def child_replies
        #raise "i ain't got no parents" if parent_id.nil?
        data = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT * FROM replies WHERE parent_id = ?
        SQL
        data.map { |datum| Reply.new(datum)}
    end
end

class QuestionFollow
    def self.followers_for_user_id(user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT * 
            FROM questions
            JOIN question_follows ON questions.id = question_follows.question_id
            WHERE user_id = ?
        SQL
        data.map { |datum| Question.new(datum)}
    end

    def self.followers_for_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT * 
            FROM users
            JOIN question_follows ON users.id = question_follows.user_id
            WHERE question_id = ?
        SQL
        data.map { |datum| User.new(datum)}
    end

    def self.most_followed_questions(n)
        data = QuestionsDatabase.instance.execute(<<-SQL, n)
            SELECT *, COUNT(question_id)
            FROM questions q
            JOIN question_follows qf ON q.id = qf.question_id
            GROUP BY question_id
            ORDER BY COUNT(question_id) desc
            LIMIT ?
        SQL
        data.map { |datum| Question.new(datum)}
    end

    attr_accessor :id, :question_id, :user_id

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end
end

class QuestionLike
    def self.likers_for_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT *
            FROM users
            JOIN question_likes ON users.id = question_likes.user_id
            WHERE question_id = ?
        SQL
        data.map { |datum| User.new(datum)}
    end

    def self.num_likes_for_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT question_id, COUNT(*) AS num_likes
            FROM users
            JOIN question_likes ON users.id = question_likes.user_id
            WHERE question_id = ?
            GROUP BY question_id
        SQL
        data.last
    end

    def self.liked_questions_for_user_id(user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT *
            FROM question_likes
            JOIN questions ON questions.id = question_likes.question_id
            WHERE user_id = ?
        SQL
        data.map { |datum| Question.new(datum)}
    end

    def self.most_liked_questions(n)
        data = QuestionsDatabase.instance.execute(<<-SQL, n)
            SELECT *, COUNT(*) AS num_likes
            FROM question_likes
            JOIN questions ON questions.id = question_likes.question_id
            GROUP BY question_id
            ORDER BY num_likes DESC
            LIMIT ?
        SQL
        data.map { |datum| Question.new(datum)}
    end

    attr_accessor :id, :question_id, :user_id

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end
end
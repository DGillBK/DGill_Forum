module Travel
  class Server < Sinatra::Base


    enable :sessions

    @@db = PG.connect({dbname: "trav_forum"})

    def current_user
      if session["user_id"]
        @user ||= @@db.exec_params(<<-SQL, [session["user_id"]]).first
          SELECT * FROM users WHERE id = $1
        SQL
      else
        # THE USER IS NOT LOGGED IN
        @user = { "name" => 'NOT!'}
      end
    end

    get "/signout" do
      session["user_id"] = false
      redirect "/"
    end

    get "/signup" do
      erb :signup
    end

    post "/signup" do

      password_digest = BCrypt::Password.create(params["password"])

      new_user = @@db.exec_params(<<-SQL, [params["name"], params["email"], password_digest])
        INSERT INTO users (name, email, password_digest)
        VALUES ($1, $2, $3) RETURNING id;
      SQL

      session["user-id"]=new_user.first["id"].to_i

      erb :signup_success
    end

    get "/login" do
      erb :login
    end

    post "/login" do
      @user = @@db.exec_params("SELECT * FROM users WHERE name = $1", [params[:login_name]]).first
      if @user
        if BCrypt::Password.new(@user["password_digest"]) == params[:login_password]
          session["user_id"] = @user["id"]
          redirect "/"
        else
          @error = "Invalid Password"
          erb :login
        end
      else
        @error = "Invalid Username"
        erb :login
      end
    end

    def top_topics
      @@db.exec("SELECT * FROM topic ORDER BY vote desc LIMIT 5");
    end

    get '/' do #get all topics
      
      # text displayed at the top of the page
      @intro = "WHERE SHOULD WE GO?"
      # fetch all the topics
      @topics = @@db.exec("SELECT * FROM topic ORDER BY vote DESC").to_a
      
      # iterates through each topic, finds the count of posts it has from the post table, adds that to the topic hash. 
      @topics.each do |topic|
        count = @@db.exec("SELECT * FROM post where topic_id = #{topic['id']}").to_a.length
        topic['count'] = count
      end

      erb :topics
    end

    post '/topic' do
      # store all the params posted as variables
      title = params["title"]
      image_url = params["image_url"]
      author = params["author"]

      # Insert the parameters into the data base and save the new values in @topic variable for later use
      @topic = @@db.exec_params("INSERT INTO topic (title, image_url, author) VALUES ($1, $2, $3) RETURNING id",[ title, image_url, author ])

      # redirect to the new topic we just inserted
      redirect '/topic/' + @topic.first['id']
    end


    put '/topic' do
      # store params as variables for easy use
      topic_id = params['topic_id']

      # update the post vote count by adding 1 to it
      @@db.exec_params("UPDATE topic SET vote = vote + 1 WHERE id = $1", [topic_id])

      # redirect back to the post 
      redirect '/'
    end


    get '/topic/:id' do #get one topic and all posts
      # text at top of the page
      @intro = "WHAT SHOULD WE DO?"
      # store the params as variables for easier use
      id= params[:id]
      # get the info about this topic
      @topic = @@db.exec("SELECT * FROM topic WHERE id = #{id}")
      # get all the posts for this topic
      @posts = @@db.exec("SELECT * FROM post WHERE topic_id = #{id} ORDER BY vote DESC").to_a
      erb :topic
    end


    get '/post/:id' do #gets one post on a topic and all comments
      # text at top of the page 
      @intro = "LET'S GO!"
      # get all the info about this post
      @post = @@db.exec("SELECT * FROM post WHERE id = #{params["id"]}")
      # get all the comments for this post
      @comments = @@db.exec("SELECT * FROM comment WHERE post_id = #{params["id"]} ORDER BY vote DESC").to_a

      # turn on mark down thing - think
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

      # change the comment from mark to html
      @comments.each do |comment|
        comment['description'] = markdown.render(comment['description'])
      end
      erb :post
    end

    post '/post' do
      # store all params as variables for easy use
      topic_id = params['topic_id']
      @intro = "LET'S GO!"      
      title = params["title"]
      description = params["description"]
      image_url = params["image_url"]
      author = params["author"]

      # insert new post and save the info in @post variable for later use
      @post = @@db.exec_params("INSERT INTO post (topic_id, title, description, image_url, author) VALUES ($1, $2, $3, $4, $5) RETURNING id",[ topic_id, title, description, image_url, author ])

      # use post variable to redirect to the post we just inserted
      redirect '/post/' + @post.first['id']
    end

    put '/post' do
      # store params as variables for easy use
      topic_id = params['topic_id']
      post_id = params['post_id']

      # update the post vote count by adding 1 to it
      @@db.exec_params("UPDATE post SET vote = vote + 1 WHERE id = $1", [post_id])

      # redirect back to the post 
      redirect '/topic/' + topic_id
    end

    post '/comment' do
      # store paramas as variables for easy use
      post_id = params['post_id']
      author = params['author']
      description = params['description']

      # text at top of the page
      @intro = "WHAT CHU SAY?!"

      # insert new comment into the db
      @@db.exec_params("INSERT INTO comment ( post_id, author, description ) VALUES ( $1, $2, $3)",[post_id, author, description])

      # redirect back to the post this comment is for
      redirect '/post/' + post_id
    end
    
    
    put '/comment' do
      # store params as variables for easy use
      post_id = params['post_id']
      comment_id = params['comment_id']

      # update the comment vote count by adding 1 to it
      @@db.exec_params("UPDATE comment SET vote = vote + 1 WHERE id = $1", [comment_id])

      # redirect back to the post 
      redirect '/post/' + post_id
    end




    private

  end
end

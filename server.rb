module Travel
  class Server < Sinatra::Base

    get '/' do #get all topics
      db = database_connection 
      # text displayed at the top of the page
      @intro = "WHERE SHOULD WE GO?"
      # fetch all the topics
      @topics = db.exec("SELECT * FROM topic").to_a      
      erb :topics
    end

    post '/topic' do
      db = database_connection
      # store all the params posted as variables
      title = params["title"]
      image_url = params["image_url"]
      author = params["author"]

      # Insert the parameters into the data base and save the new values in @topic variable for later use
      @topic = db.exec_params("INSERT INTO topic (title, image_url, author) VALUES ($1, $2, $3) RETURNING id",[ title, image_url, author ])

      # redirect to the new topic we just inserted
      redirect '/topic/' + @topic.first['id']
    end
# _________________topic vote_______________________

    put '/topic' do
      db = database_connection

      # store params as variables for easy use
      topic_id = params['topic_id']

      # update the post vote count by adding 1 to it
      db.exec_params("UPDATE topic SET vote = vote + 1 WHERE id = $1", [topic_id])

      # redirect back to the post 
      redirect '/'
    end
# ___________________________________________________

    get '/topic/:id' do #get one topic and all posts
      db = database_connection
      # text at top of the page
      @intro = "WHAT SHOULD WE DO?"
      # store the params as variables for easier use
      id= params[:id]
      # get the info about this topic
      @topic = db.exec("SELECT * FROM topic WHERE id = #{id}")
      # get all the posts for this topic
      @posts = db.exec("SELECT * FROM post WHERE topic_id = #{id}").to_a
      erb :topic
    end


    get '/post/:id' do #gets one post on a topic and all comments
      db = database_connection
      # text at top of the page 
      @intro = "LET'S GO!"
      # get all the info about this post
      @post = db.exec("SELECT * FROM post WHERE id = #{params["id"]}")
      # get all the comments for this post
      @comments = db.exec("SELECT * FROM comment WHERE post_id = #{params["id"]} ORDER BY vote DESC").to_a
      erb :post
    end

    post '/post' do
      db = database_connection
      # store all params as variables for easy use
      topic_id = params['topic_id']
      @intro = "LET'S GO!"      
      title = params["title"]
      description = params["description"]
      image_url = params["image_url"]
      author = params["author"]

      # insert new post and save the info in @post variable for later use
      @post = db.exec_params("INSERT INTO post (topic_id, title, description, image_url, author) VALUES ($1, $2, $3, $4, $5) RETURNING id",[ topic_id, title, description, image_url, author ])

      # use post variable to redirect to the post we just inserted
      redirect '/post/' + @post.first['id']
    end

    put '/post' do
      db = database_connection

      # store params as variables for easy use
      topic_id = params['topic_id']
      post_id = params['post_id']

      # update the post vote count by adding 1 to it
      db.exec_params("UPDATE post SET vote = vote + 1 WHERE id = $1", [post_id])

      # redirect back to the post 
      redirect '/topic/' + topic_id
    end

    post '/comment' do
      db = database_connection
      # store paramas as variables for easy use
      post_id = params['post_id']
      author = params['author']
      description = params['description']

      # text at top of the page
      @intro = "WHAT CHU SAY?!"

      # insert new comment into the db
      db.exec_params("INSERT INTO comment ( post_id, author, description ) VALUES ( $1, $2, $3)",[post_id, author, description])

      # redirect back to the post this comment is for
      redirect '/post/' + post_id
    end
    
    
    put '/comment' do
      db = database_connection

      # store params as variables for easy use
      post_id = params['post_id']
      comment_id = params['comment_id']

      # update the comment vote count by adding 1 to it
      db.exec_params("UPDATE comment SET vote = vote + 1 WHERE id = $1", [comment_id])

      # redirect back to the post 
      redirect '/post/' + post_id
    end




    private

    def database_connection
      PG.connect(dbname: 'trav_forum')
    end

  end
end

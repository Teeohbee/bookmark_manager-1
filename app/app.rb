require 'sinatra/base'
require 'sinatra/flash'
require_relative 'data_mapper_setup'

class App < Sinatra::Base
  enable :sessions
  register Sinatra::Flash
  set :session_secret, 'super secret'

  get '/' do
    erb :root
  end

  get '/links' do
    @links = Link.all
    erb :index
  end

  get '/links/new' do
    erb :new_link
  end

  post '/links' do
    link = Link.new(url: params[:url], title: params[:title])
    params[:tag].split(' ').each do |name|
      tag = Tag.create(name: name.downcase)
      link.tags << tag
    end
    link.save
    redirect '/links'
  end

  get '/tags/:name' do
    tag = Tag.first(name: params[:name].downcase)
    @links = tag ? tag.links : []
    erb :index
  end

  get '/users/new' do
    @user = User.new
    erb :'users/new'
  end

  post '/users' do
    @user = User.create(email: params[:email],
                        password: params[:password],
                        password_confirmation: params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      redirect to('/')
    elsif @user.email == ""
      flash.now[:email_error] = 'Please provide a valid email'
      erb :'users/new'
    else
      flash.now[:password_error] = 'Password and confirmation password do not match'
      erb :'users/new'
    end
  end

  helpers do
    def current_user
      current_user ||= User.get(session[:user_id])
    end
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end

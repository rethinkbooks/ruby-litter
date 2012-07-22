TWITTER_KEY = 'SqvkQ9ZhhZ4x9ZEK2MomA'
TWITTER_SECRET = 'Yn0kSzzRSv1RLBCTaIsBVNvEirdsAn1xOGrKvwoRzc'

use Rack::Session::File::YAML, :storage => './tmp'
use Rack::Flash
use OmniAuth::Builder do
  provider :twitter, TWITTER_KEY, TWITTER_SECRET
end

Twitter.configure do |config|
  config.consumer_key = TWITTER_KEY
  config.consumer_secret = TWITTER_SECRET
end

set :haml, :format => :html5, :layout => :default_layout

helpers do
  def protect!
    unless authd?
      redirect to('/sign_in')
    end
  end

  def authd?
    session.has_key? :auth
  end

  def client
    creds = session[:auth][:credentials]
    Twitter::Client.new(
      :oauth_token => creds[:token],
      :oauth_token_secret => creds[:secret]
    )
  end
end

get '/' do
  redirect to('/dashboard') if authd?
  haml :index
end

get '/sign_in' do
  haml :sign_in
end

get '/sign_out' do
  session.delete :auth
  redirect to('/')
end

get '/auth/twitter/callback' do
  auth = request.env['omniauth.auth']
  session[:auth] = auth
  redirect to('/dashboard')
end

get '/dashboard' do
  protect!
  tweets = client.home_timeline
  haml :dashboard, :locals => {
    :tweets => tweets
  }
end

post '/tweets/create' do
  protect!
  tweet = params[:tweet] || {}
  text = (tweet[:text] || '').strip
  unless text.empty?
    client.update text
    flash[:notice] = 'Your tweet has been posted.'
  end
  redirect to('/dashboard')
end

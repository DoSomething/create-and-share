CreateAndShare::Application.routes.draw do
  root to: 'campaigns#index'
  resources :campaigns, except: [:index, :show]
  get '/campaigns', to: redirect('/')

  # Sessions business
  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:create]
  match 'login',  to: 'sessions#new',     as: :login
  match 'logout', to: 'sessions#destroy', as: :logout
  match 'sessions', to: redirect('/login')
  get 'auth/:provider/callback', to: 'sessions#fboauth'
  get 'auth/failure', to: redirect('/'), notice: 'Login failed! Try again?'

  scope ':campaign_path', constraints: lambda { |params| Campaign.where(:path => params[:campaign_path]).count > 0 } do
    root to: 'posts#index'
    match 'auth-bar', to: 'sessions#get_auth_bar'
    match 'is-admin', to: 'sessions#is_admin'

    resources :posts do
      member do
        post 'flag'
        post 'thumbs'
        post 'share'
      end

      collection do
        get 'stats_email'
        post 'autoimg'
        get 'school_lookup'
        get 'uid_lookup'
        post 'scroll'
        post 'get_counts'
      end
    end

    # Login / out
    match 'login',  to: 'sessions#new',     as: :login
    get 'logout', to: 'sessions#destroy', as: :logout

    # Static pages
    get 'faq',          to: 'static_pages#faq', as: :faq
    get 'gallery',      to: 'static_pages#gallery', as: :gallery
    get 'start',        to: 'static_pages#start', as: :start

    get 'page/:page', to: 'posts#page', constraints: { page: /[0-9]+/ }, as: :page

    # User pages
    get 'submit/guide', to: 'users#intent', as: :intent
    get 'participation', to: 'users#participation', as: :participation

    get 'submit', to: 'posts#new', as: :submit
    get ':id/edit', to: 'posts#edit', as: :edit

    # General paths
    get 'featured', to: 'posts#extras', run: 'featured', as: :featured
    get 'mine',     to: 'posts#extras', run: 'mine', as: :mine

    # Filters
    get 'show/:filter', to: 'posts#filter', constraints: { filter: /[A-Za-z0-9\-\_]+/ }, as: :filter
    get 'show/:filter/page/:page', to: 'posts#page', constraints: { filter: /[A-Za-z0-9\-\_]+/ }, as: :filter_page

    # Individual posts
    get ':id',     to: 'posts#show', constraints: { id: /\d+/ }, as: :show_post
    get ':vanity', to: 'posts#vanity', constraints: { vanity: /\w+/ }, as: :vanity_post
  
    # Popups
    get 'popups/:popup', to: 'campaigns#popups'
  end
end

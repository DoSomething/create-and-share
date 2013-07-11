CreateAndShare::Application.routes.draw do
  root to: 'campaigns#index'
  resources :campaigns

  # DASHBOARD
  match '/dashboard', to: 'dashboard#index'

  # Sessions business
  resources :sessions, :only => [:new, :create, :destroy]
  resources :users, :only => [:create]
  match '/login',  to: 'sessions#new',     :as => :login
  match '/logout', to: 'sessions#destroy', :as => :logout
  match 'sessions' => redirect('/login')
  get 'auth/:provider/callback' => 'sessions#fboauth'
  get 'auth/failure' => redirect('/'), :notice => 'Login failed! Try again?'

  scope ':campaign_path', constraints: lambda{|params| Campaign.where(:path => params[:campaign_path]).count > 0 } do
    root to: 'posts#index'

    resources :posts do
      member do
        post 'flag', constraints: lambda { is_admin? }
      end

      collection do
        post 'autoimg'
      end
    end

    resources :shares, :only => [:create]

    # Static pages
    get 'faq', to: 'static_pages#faq', as: :faq
    get 'gallery', to: 'static_pages#gallery', as: :gallery
    get 'start', to: 'static_pages#start', as: :start
    get 'submit/guide', to: 'users#intent', as: :intent

    get 'submit', to: 'posts#new', as: :real_submit_path

    # General paths
    get 'featured', to: 'posts#filter', run: 'featured'
    get 'adopted', to: 'posts#filter', run: 'adopted'

    # Filters
    get 'show/:filter', to: 'posts#show_filter', constraints: { filter: /[A-Za-z0-9\-\_]+/ }

    get 'mine', to: 'posts#mine', as: 'mypics'
    get ':id', to: 'posts#show', constraints: { id: /\d+/ }, as: :show_post
    get ':vanity', to: 'posts#vanity', constraints: { vanity: /\w+/ }, as: :vanity_post
  end
end

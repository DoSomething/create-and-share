CreateAndShare::Application.routes.draw do
  root :to => 'campaigns#index'
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

  scope ':campaign', constraints: lambda{|params| Campaign.where(:path => params[:campaign]).count > 0 } do
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
    get 'show/:filter', to: 'posts#show_filter', constraints: { filter: /[a-z]+/ }
    get ':atype', to: 'posts#filter', constraints: { atype: /(cat|dog|other)s?/ }, run: 'animal'
    get ':state', to: 'posts#filter', constraints: { state: /[A-Z]{2}/ }, run: 'state'
    get ':atype-:state', to: 'posts#filter', constraints: { atype: /(cat|dog|other)s?/, state: /[A-Z]{2}/ }, run: 'both'

    get 'mine' => 'posts#filter', :run => 'my', :as => :mypics
    get ':id', to: 'posts#show', constraints: { id: /\d+/ }, as: :show_post
    get ':vanity', to: 'posts#vanity', constraints: { vanity: /\w+/ }, as: :vanity_post
  end
end

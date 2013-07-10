CreateAndShare::Application.routes.draw do
  root :to => 'posts#index'

  # DASHBOARD
  match '/dashboard', to: 'dashboard#index'

  # Gate
  resources :sessions, :only => [:new, :create, :destroy]
  match '/login',  to: 'sessions#new',     :as => :login
  match '/logout', to: 'sessions#destroy', :as => :logout

  # Static
  get '/start',   to: 'static_pages#start',   :as => :start
  get '/gallery', to: 'static_pages#gallery', :as => :gallery
  get '/faq',     to: 'static_pages#faq',     :as => :faq

  resources :posts
  resources :users, :only => [:create]
  resources :shares, :only => [:create]

  match 'submit' => 'posts#new', :as => :real_submit_path
  match 'mypets' => 'posts#filter', :run => 'my', :as => :mypics
  match ':id' => 'posts#show', :constraints => { :id => /\d+/ }, :as => :show_post
  match ':atype' => 'posts#filter', :constraints => { :atype => /(cat|dog|other)s?/ }, :run => 'animal'
  match ':state' => 'posts#filter', :constraints => { :state => /[A-Z]{2}/ }, :run => 'state'
  match ':atype-:state' => 'posts#filter', :constraints => { :atype => /(cat|dog|other)s?/, :state => /[A-Z]{2}/ }, :run => 'both'
  match 'featured' => 'posts#filter', :run => 'featured'
  match 'adopted' => 'posts#filter', :run => 'adopted'
  match 'fix' => 'posts#fix'
  match 'autoimg' => 'posts#autoimg'
  match 'alterimg/:id' => 'posts#alterimg', :as => :alter_image
  match 'flag/:id' => 'posts#flag', :as => :flag
  get 'submit/guide' => 'users#intent', :as => :intent
  match 'sessions' => redirect('/login')
  match ':vanity' => 'posts#vanity', :constraints => { :vanity => /[A-Za-z]+/ }

  # FACEBOOK AUTH
  match 'auth/:provider/callback' => 'sessions#fboauth'
  match 'auth/failure' => redirect('/'), :notice => 'Login failed! Try again?'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

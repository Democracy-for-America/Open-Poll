Rails.application.routes.draw do

  get 'admin' => 'admin/static_pages#index'

  namespace :admin do
    resources :polls do
      get :results
      get :raw_results
      resources :candidates
    end
    resources :domains
  end

  # Use the root of the site search for a poll based on sub-domain
  ['', ':poll/'].each do |slug|
    get "#{ slug }" => 'votes#new'
    post "#{ slug }" => 'votes#create'
    get "#{ slug }v/:vote_hash" => 'votes#show'
    get "#{ slug }s" => 'votes#new'
    post "#{ slug }s" => 'votes#create'
    get "#{ slug }s/:vote_hash" => 'votes#new'
    post "#{ slug }s/:vote_hash" => 'votes#create'
    get "#{ slug }vote/:candidate_slug" => 'votes#new'
    post "#{ slug }vote/:candidate_slug" => 'votes#create'
    get "#{ slug }candidate/:candidate_id" => 'candidates#show'
    get "#{ slug }results" => 'results#show'
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
   root 'main_pages#index', as: 'root'
  resources :management
  #
  resources :main_pages
  resources :sources do
    resources :articles
  end
  delete 'delete_all_articles', to: 'articles#delete_all', as: 'delete_all_articles'
  get 'parse', to: 'main_pages#parse', as: 'parse'
  get 'reset', to: 'main_pages#reset', as: 'reset'
end

Rails.application.routes.draw do
  root 'characters#index'
  resources :characters, except: :show
  get 'groups', to: 'groups#show'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

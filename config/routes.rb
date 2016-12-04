# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :projects do
  resources :spent_times do
    collection do
      put "approve_multiple"
      get "approve"
      get "reject"
    end
  end
end

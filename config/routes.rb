Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
    get '/repositories/:owner/:repository/commit/:commit_sha', to: 'commits#show'
end

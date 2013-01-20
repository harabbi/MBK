MergeSite::Application.routes.draw do
  match "/search/download" => "application#download", :via => :post, :as => :download
  match "/search/" => "application#search", :via => [ :post, :get ]
  match "/" => "application#upload", :via => :put, :as => :upload
  match "/" => "application#destroy", :via => :delete, :as => :delete
  root :to => 'application#home', :via => [ :get, :post ]
end

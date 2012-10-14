MergeSite::Application.routes.draw do
  match "/search/download" => "application#download", :via => :post, :as => :download
  match "/search/" => "application#search", :via => [ :post, :get ]
  match "/" => "application#upload", :via => :post, :as => :upload
  root :to => 'application#home', :via => :get
end

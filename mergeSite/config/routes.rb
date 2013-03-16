MergeSite::Application.routes.draw do
  match "/search/download" => "application#download", :via => :get, :as => :download
  match "/search/" => "application#search", :via => [ :post, :get ]
  match "/image/:productcode" => "application#change_image", :via => [ :post, :get ], :as => :image
  match "/reindex/:productcode" => "application#reindex_magento", :via => :get , :as => :reindex
  match "/" => "application#upload", :via => :put, :as => :upload
  match "/" => "application#destroy", :via => :delete, :as => :delete
  root :to => 'application#home', :via => [ :get, :post ]
end

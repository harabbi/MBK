MergeSite::Application.routes.draw do
  match "/search/download" => "application#download", :via => :get, :as => :download
  match "/search/" => "application#search", :via => [ :post, :get ]
  match "/image/:productcode" => "application#change_image", :via => [ :post, :get ], :as => :image
  match "/change_preview" => "application#change_preview", :via => :post, :as => :preview
  match "/reindex" => "application#reindex_magento", :via => :get , :as => :reindex
  match "/" => "application#upload", :via => :put, :as => :upload
  match "/" => "application#destroy", :via => :delete, :as => :delete
  root :to => 'application#home', :via => [ :get, :post ]
  scope 'admin' do
    match "/" => 'admin#home', :via => [ :get, :post ], :as => :admin
    match "/admin/run_script/:id" => 'admin#run_script', :as => :script
  end
end

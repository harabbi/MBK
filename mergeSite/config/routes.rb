MergeSite::Application.routes.draw do
  match "/search/download" => "application#download"
  match "/search/" => "application#search"
  root :to => 'application#home'
end

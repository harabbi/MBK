MergeSite::Application.routes.draw do
  match ':page', :to => 'application#home'
  root :to => 'application#home'
end

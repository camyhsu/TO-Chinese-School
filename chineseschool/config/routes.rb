Chineseschool::Application.routes.draw do

  #resources :products
  #get "say/hello"
  #get "say/goodbye"

  #match 'signin/' => 'signin#index'
  #match 'signin/:action'

  namespace :accounting do
    get 'instructors/discount' => 'instructors#discount'
    get 'manual_transactions' => 'manual_transactions#index'
    get 'manual_transactions/show' => 'manual_transactions#show'
    get 'registration_report/registration_payments_by_date' => 'registration_report#registration_payments_by_date'
  end

  namespace :instruction do
    get 'active_school_classes' => 'active_school_classes#index'
  end

  namespace :librarian do
    get 'library_books' => 'library_books#index'
    match 'library_books/new' => 'library_books#new'
    get 'library_books/read_only_view' => 'library_books#read_only_view'
  end

  namespace :registration do
    get 'active_school_classes/grade_class_student_count' => 'active_school_classes#grade_class_student_count'
    get 'active_school_classes/elective_class_student_count' => 'active_school_classes#elective_class_student_count'
    match 'families/new' => 'families#new'
    get 'people/show' => 'people#show'
    get 'report/registration_integrity' => 'report#registration_integrity'
  end

  namespace :student do
    get 'transaction_history' => 'transaction_history#index'
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root to: 'home#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id))(.:format)'
end

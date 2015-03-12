Chineseschool::Application.routes.draw do

  #resources :products
  #get "say/hello"
  #get "say/goodbye"

  #match 'signin/' => 'signin#index'
  #match 'signin/:action'
  match 'signin/register_with_invitation' => 'signin#register_with_invitation'

  namespace :accounting do
    get 'in_person_registration_payments' => 'in_person_registration_payments#index'
    get 'instructors/discount' => 'instructors#discount'
    get 'manual_transactions' => 'manual_transactions#index'
    match 'manual_transactions/new' => 'manual_transactions#new'
    get 'manual_transactions/show' => 'manual_transactions#show'
    get 'registration_report/registration_payments_by_date' => 'registration_report#registration_payments_by_date'
  end

  namespace :activity do
    get 'forms/elective_class_information' => 'forms#elective_class_information'
    get 'forms/fire_drill_form' => 'forms#fire_drill_form'
    get 'forms/grade_class_information' => 'forms#grade_class_information'
    get 'forms/students_by_class' => 'forms#students_by_class'

    get 'track_events' => 'track_events#index'
    get 'track_events/sign_up_index' => 'track_events#sign_up_index'
    get 'track_events/sign_up' => 'track_events#sign_up'
    get 'track_events/assign_student_team_index' => 'track_events#assign_student_team_index'
    get 'track_events/assign_parent_team_index' => 'track_events#assign_parent_team_index'

    post 'track_events/create_team' => 'track_events#create_team'
    post 'track_events/select_team' => 'track_events#select_team'
    get 'track_events/delete_team' => 'track_events#delete_team'

    post 'track_events/change_filler_team' => 'track_events#change_filler_team'
    post 'track_events/create_filler_signup' => 'track_events#create_filler_signup'
    get 'track_events/delete_filler_signup' => 'track_events#delete_filler_signup'

    get 'track_events/calculate_lane_assignments' => 'track_events#calculate_lane_assignments'
    get 'track_events/lane_assignment_index' => 'track_events#lane_assignment_index'
    get 'track_events/tocs_lane_assignment_form' => 'track_events#tocs_lane_assignment_form'
    get 'track_events/tocs_track_event_data' => 'track_events#tocs_track_event_data'

    post 'track_events/select_program' => 'track_events#select_program'
    post 'track_events/select_relay_group' => 'track_events#select_relay_group'
    post 'track_events/select_parent' => 'track_events#select_parent'
    post 'track_events/select_parent_relay_group' => 'track_events#select_parent_relay_group'
  end

  namespace :admin do
    get 'grades' => 'grades#index'

    get 'rights' => 'rights#index'

    get 'roles' => 'roles#index'
    get 'roles/show' => 'roles#show'
    post 'roles/add_user' => 'roles#add_user'
    post 'roles/remove_user' => 'roles#remove_user'

    get 'school_classes' => 'school_classes#index'
    match 'school_classes/new' => 'school_classes#new'
    match 'school_classes/edit' => 'school_classes#edit'
    post 'school_classes/toggle_active' => 'school_classes#toggle_active'
    get 'school_years' => 'school_years#index'
    get 'school_years/show' => 'school_years#show'
    match 'school_years/new' => 'school_years#new'
    match 'school_years/edit' => 'school_years#edit'
    match 'school_years/edit_book_charge' => 'school_years#edit_book_charge'

    match 'user_registration/invite' => 'user_registration#invite'
  end

  namespace :communication do
    get 'forms/picture_taking_form' => 'forms#picture_taking_form'
    get 'forms/student_list_for_yearbook' => 'forms#student_list_for_yearbook'
  end

  namespace :instruction do
    get 'active_school_classes' => 'active_school_classes#index'
  end

  namespace :librarian do
    get 'library_books' => 'library_books#index'
    match 'library_books/new' => 'library_books#new'
    get 'library_books/read_only_view' => 'library_books#read_only_view'

    get 'search_students/index' => 'search_students#index'
    match 'search_students/search_result' => 'search_students#search_result'
  end

  namespace :registration do
    get 'active_school_classes' => 'active_school_classes#index'
    get 'active_school_classes/grade_class_student_count' => 'active_school_classes#grade_class_student_count'
    get 'active_school_classes/elective_class_student_count' => 'active_school_classes#elective_class_student_count'
    match 'families/new' => 'families#new'
    post 'instructor_assignments/destroy' => 'instructor_assignments#destroy'
    post 'instructor_assignments/select_school_class' => 'instructor_assignments#select_school_class'
    post 'instructor_assignments/select_start_date' => 'instructor_assignments#select_start_date'
    post 'instructor_assignments/select_end_date' => 'instructor_assignments#select_end_date'
    post 'instructor_assignments/select_role' => 'instructor_assignments#select_role'
    post 'people/select_grade' => 'people#select_grade'
    post 'people/select_school_class' => 'people#select_school_class'
    post 'people/select_elective_class' => 'people#select_elective_class'
    get 'people' => 'people#index'
    get 'people/show' => 'people#show'

    get 'report/registration_integrity' => 'report#registration_integrity'

    get 'student_class_assignments/list_active_students_by_name' => 'student_class_assignments#list_active_students_by_name'
    get 'student_class_assignments/random_assign_grade_class' => 'student_class_assignments#random_assign_grade_class'
    get 'student_class_assignments/student_list_by_class' => 'student_class_assignments#student_list_by_class'
  end

  namespace :student do
    get 'transaction_history' => 'transaction_history#index'
  end

  get 'signout' => 'signout#index'

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

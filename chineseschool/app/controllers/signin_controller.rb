class SigninController < ApplicationController

  skip_before_filter :check_authentication, :check_authorization
  
  def index
    if request.post?
      user_found = User.authenticate(params[:username], params[:password])
      if user_found
        session[:user_id] = user_found.id
        original_uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(original_uri || {:controller => 'home', :action => 'index'})
      else
        flash.now[:notice] = 'Invalid username / password combination'
      end
    end
  end

  def register
    if request.post?
      if params[:password] != params[:password_confirmation]
        flash.now[:notice] = 'Password does not match confirmation re-typed' and return
      end
      people_found = Person.find_people_on_record(params[:english_first_name].strip, params[:english_last_name].strip,
                                                  params[:email].strip, params[:phone_number])
      if people_found.size == 1
        person_found = people_found.first
        if existing_user = User.find_by_person_id(person_found.id)
          flash.now[:notice] = "This person already have an account with username #{existing_user.username}" and return
        end

        # 
        # This is a temporary guard to allow only Wanlin and Linda to register accounts
        #
        puts "Person found with id => #{person_found.id}"
        if person_found.id != 938 and person_found.id != 477
          flash.now[:notice] = 'System temporarily closed to public - please register account later' and return
        end
        
        @user = User.new(:username => params[:username], :person => person_found)
        @user.password = params[:password]

        #
        # Again temporary - give the user created the role of Registration Officer
        #
        @user.roles << Role.find_by_name('Registration Officer')

        if @user.save
          flash[:notice] = 'Account successfully registered'
          redirect_to :action => 'index'
        end
      else
        flash.now[:notice] = 'Unable to match identity with existing records - please try again or contact Chinese School'
      end
    end
  end

  def register_with_invitation
    timed_token = TimedToken.find_by_token params[:id]
    redirect_to :action => 'invalid_token' and return if timed_token.nil?
    
    if request.post?
    else

    end
  end
end

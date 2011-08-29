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
        flash.now[:notice] = "Invalid username / password combination - For technical support, please email #{Contacts::WEB_SITE_SUPPORT}"
      end
    end
  end

  def forgot_password
    if request.post?
      user_found = User.find_by_username params[:username]
      flash.now[:notice] = 'Username does not exist' and return unless user_found
      email_destination = user_found.person.personal_email_address
      flash.now[:notice] = 'Unable to find email address for the user' and return unless email_destination
      email = SigninMailer.create_forgot_password user_found.person, email_destination
      SigninMailer.deliver email
      flash[:notice] = 'Password Reset Request sent to email address on record'
      redirect_to :action => 'index'
    end
  end
  
  def forgot_username
    if request.post?
      @matched_users = []
      return if params[:email].blank?
      addresses_found = Address.find_all_by_email params[:email]
      return if addresses_found.empty?
      addresses_found.each do |address|
        if address.person
          collect_user_from address.person
        elsif address.family
          family = address.family
          collect_user_from family.parent_one unless family.parent_one.nil?
          collect_user_from family.parent_two unless family.parent_two.nil?
        end
      end
      @matched_users.uniq!
    end
  end

  def reset_password
    timed_token = TimedToken.find_by_token params[:id]
    redirect_to :action => 'invalid_token' and return if timed_token.nil? or timed_token.expired?
    
    @user = timed_token.person.user
    redirect_to :action => 'invalid_token' and return if @user.nil?

    if request.post?
      if params[:password] != params[:password_confirmation]
        flash.now[:notice] = 'Password does not match confirmation re-typed' and return
      end
      unless timed_token.person.phone_number_correct? params[:phone_number]
        flash.now[:notice] = 'Unable to match phone number with existing records - please try again' and return
      end
      @user.password = params[:password]
      if @user.save
        flash[:notice] = 'Password successfully updated'
        redirect_to :action => 'index'
      end
    end
  end

  def register
    if request.post?
      @address = Address.new params[:address]
      @parent_one = Person.new params[:parent_one]
      @user = User.new(:username => params[:user][:username], :person => @parent_one)
      @user.password = params[:password]
      @user.roles << Role.find_by_name(Role::ROLE_NAME_STUDENT_PARENT)

      if params[:password] != params[:password_confirmation]
        flash.now[:password_not_match] = 'Password does not match confirmation re-typed' and return
      end
      valid_address = @address.valid?
      valid_parent_one = @parent_one.valid?
      valid_user = @user.valid?
      return unless valid_address and valid_parent_one and valid_user
      
      new_family = Family.new
      new_family.address = @address
      new_family.parent_one = @parent_one
      Family.transaction do
        new_family.save!
        @user.save!
      end

      flash[:notice] = 'Account successfully created'
      redirect_to :action => 'index'
    else
      @address = Address.new
      @parent_one = Person.new
      @user = User.new
    end
  end

  def register_with_invitation
    timed_token = TimedToken.find_by_token params[:id]
    redirect_to :action => 'invalid_token' and return if timed_token.nil? or timed_token.expired?
    person = timed_token.person
    unless person.user.nil?
      flash.now[:notice] = "This person already have an account with username #{person.user.username}" and return
    end
    
    if request.post?
      if params[:password] != params[:password_confirmation]
        flash.now[:notice] = 'Password does not match confirmation re-typed' and return
      end
      unless person.phone_number_correct? params[:phone_number]
        flash.now[:notice] = 'Unable to match phone number with existing records - please try again' and return
      end

      @user = User.new(:username => params[:username], :person => person)
      @user.password = params[:password]
      @user.roles << Role.find_by_name(Role::ROLE_NAME_STUDENT_PARENT)
      @user.adjust_instructor_roles
      
      if @user.save
        flash[:notice] = 'Account successfully created'
        redirect_to :action => 'index'
      end
    end
  end

  def ping
    render :text => "Pong - #{Time.now}"
  end
  
  
  private
  
  def collect_user_from(person)
    @matched_users << person.user unless person.user.nil?
  end
end

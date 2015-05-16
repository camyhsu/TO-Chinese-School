class SigninController < ApplicationController

  skip_before_filter :check_authentication, :check_authorization
  
  def index
    if request.post?
      user_found = User.authenticate(params[:username], params[:password])
      if user_found
        session[:user_id] = user_found.id
        original_uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(original_uri || {controller: 'home', action: 'index'})
      else
        flash.now[:notice] = "Invalid username / password combination - For technical support, please email #{Contacts::WEB_SITE_SUPPORT}"
      end
    end
  end

  def forgot_password
    if request.post? || request.put?
      user_found = User.find_by_username params[:username]
      unless user_found
        flash.now[:notice] = 'Username does not exist'
        return
      end
      email_destination = user_found.person.personal_email_address
      unless email_destination
        flash.now[:notice] = 'Unable to find email address for the user'
        return
      end
      SigninMailer.forgot_password(user_found.person, email_destination).deliver
      flash[:notice] = 'Password Reset Request sent to email address on record'
      redirect_to action: 'index'
    end
  end
  
  def forgot_username
    @matched_users = []
    if request.post?
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
    else
      @initial_form_load = true
    end
  end

  def reset_password
    timed_token = TimedToken.find_by_token params[:id]
    if timed_token.nil? || timed_token.expired?
      redirect_to action: 'invalid_password_token'
      return
    end
    
    @user = timed_token.person.user
    if @user.nil?
      redirect_to action: 'invalid_password_token'
      return
    end

    if request.post?
      if params[:password] != params[:password_confirmation]
        flash.now[:notice] = 'Password does not match confirmation re-typed'
        return
      end
      unless timed_token.person.phone_number_correct? params[:phone_number]
        flash.now[:notice] = 'Unable to match phone number with existing records - please try again'
        return
      end
      @user.password = params[:password]
      if @user.save
        flash[:notice] = 'Password successfully updated'
        redirect_to action: 'index'
      end
    end
  end

  def register
    if request.post? || request.put?
      @address = Address.new params[:address]
      if @address.email_already_exists?
        redirect_to action: :email_already_exists, email: @address.email
        return
      end
      @parent_one = Person.new params[:parent_one]
      @user = User.new
      @user.username = params[:user][:username]
      @user.person = @parent_one
      @user.password = params[:password]
      @user.roles << Role.find_by_name(Role::ROLE_NAME_STUDENT_PARENT)

      if params[:password] != params[:password_confirmation]
        flash.now[:password_not_match] = 'Password does not match confirmation re-typed'
        return
      end
      valid_address = @address.valid?
      valid_parent_one = @parent_one.valid?
      valid_user = @user.valid?
      return unless valid_address && valid_parent_one && valid_user

      new_family = Family.new
      new_family.address = @address
      new_family.parent_one = @parent_one
      Family.transaction do
        new_family.save!
        @user.save!
      end

      flash[:notice] = 'Account successfully created'
      redirect_to action: :index
    else
      @address = Address.new
      @parent_one = Person.new
      @user = User.new
    end
  end

  def email_already_exists
    @existing_email = params[:email]
    addresses = Address.find_all_by_email(@existing_email)
    people = addresses.collect { |address| address.person }.uniq.compact
    @matched_users = []
    if people.empty?
      addresses.each do |address|
        family = address.family
        collect_user_with_matching_email family.parent_one unless family.parent_one.nil?
        collect_user_with_matching_email family.parent_two unless family.parent_two.nil?
      end
    else
      @matched_users = people.collect { |person| person.user }
    end
    @matched_users.uniq!
    @matched_users.compact!
  end

  def register_with_invitation
    @token_entered = params[:id]
    timed_token = TimedToken.find_by_token @token_entered
    redirect_to action: 'invalid_invitation_token' and return if timed_token.nil? or timed_token.expired?
    person = timed_token.person
    unless person.user.nil?
       flash.now[:notice] = "This person already have an account with username #{person.user.username}" and return
    end

    if request.post? || request.put?
       if params[:password] != params[:password_confirmation]
         flash.now[:notice] = 'Password does not match confirmation re-typed' and return
       end
       unless person.phone_number_correct? params[:phone_number]
         flash.now[:notice] = 'Unable to match phone number with existing records - please try again' and return
       end

       @user = User.new
       @user.username = params[:username]
       @user.person = person
       @user.password = params[:password]
       @user.roles << Role.find_by_name(Role::ROLE_NAME_STUDENT_PARENT)
       @user.adjust_instructor_roles

       if @user.save
         flash[:notice] = 'Account successfully created'
         redirect_to action: 'index'
       end
    end
  end

  def ping
    render text: "Pong - #{Time.now}"
  end
  
  
  private
  
  def collect_user_from(person)
    @matched_users << person.user unless person.user.nil?
  end

  def collect_user_with_matching_email(person)
    if person.personal_email_address == @existing_email
      @matched_users << person.user unless person.user.nil?
    end
  end
end

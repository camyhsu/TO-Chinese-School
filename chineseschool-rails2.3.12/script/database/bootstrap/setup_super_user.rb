class SetupSuperUser
  def self.setup

    su_person = Person.create(:id => 1, :english_last_name => 'User', :english_first_name => 'Super',
      :chinese_name => '', :gender => 'M', :birth_year => 1963, :birth_month => 7)

    su = User.create(:id => 1, :username => 'su', :password => 'change_me', 
      :person => su_person)

    super_user_role = Role.create(:id => 1, :name => 'Super User')
    su.roles << super_user_role

    su.save!
  end
end

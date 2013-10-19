# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_chineseschool_session',
  :secret      => '593cb58abe112cbb66424f77a6f5518baebfd26727485e6e1fe470c2818c3640d55df3f988c0434ca00868542549b208f58223619d9f62a8c86dc10bec845f67',
  :path => '/chineseschool'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

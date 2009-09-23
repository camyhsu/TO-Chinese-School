# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_chineseschool_session',
  :secret      => 'bb49dd1bdc68146235d3016493efb05895b56eccdd943ecfc450e2b62651f367c3c8f9103f50857c1679860d43be054150c71e84cdc8438ce21e5144ed907f4c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

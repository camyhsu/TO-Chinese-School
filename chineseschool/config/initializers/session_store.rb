# Be sure to restart your server when you modify this file.

Chineseschool::Application.config.session_store :cookie_store,
                                                key: '_chineseschool_session',
                                                secure: Rails.env.production?,
                                                httponly: true,
                                                expire_after: 60.minutes

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Chineseschool::Application.config.session_store :active_record_store

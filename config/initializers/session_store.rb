# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_djconseil_session',
  :secret      => '7a97e6f502ec5b1a0427e41881bafa1ceb50233903b52749ca2acc0a11eb0ba4c51018ec16c976e0999125666a966a2eef1b965d0a4e5a6997d9141481cd1195'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

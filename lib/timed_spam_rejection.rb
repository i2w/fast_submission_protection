require 'active_support'

require 'timed_spam_rejection/version'
require 'timed_spam_rejection/timer'
require 'timed_spam_rejection/action_controller'

ActiveSupport.on_load(:action_controller) do
  include TimedSpamRejection::ActionController
  I18n.load_path << File.expand_path('../timed_spam_rejection/locales/en.yml', __FILE__)
end
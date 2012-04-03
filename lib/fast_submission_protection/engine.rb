module FastSubmissionProtection
  class Engine < Rails::Engine
  end
end

ActiveSupport.on_load(:action_controller) do
  include FastSubmissionProtection::Controller
end
# FastSubmissionProtection

[![Build Status](https://secure.travis-ci.org/i2w/fast_submission_protection.png?branch=master)](http://travis-ci.org/i2w/fast_submission_protection)

ActionController engine that facilitates rejecting spam based on how long the form submission took.

This was developed by [Ian White](http://github.com/ianwhite) and [Nicholas Rutherford](http://github.com/nruth) while working at [Distinctive Doors](http://distinctivedoors.co.uk) who have kindly agreed to release this under the MIT-LICENSE.

## Installation

In your Gemfile:

    gem 'fast_submission_protection'

## Example Usage

Specify `protect_from_fast_submission` to protect a create action from being submitted in less than 5 seconds.  The default protection is
to render a HTTP 420 page (see Rescue below).

    class FeedbackController < ApplicationController
      protect_from_fast_submission 
    end

You can change the delay, start and finish actions, and the rescue behaviour

    class CommentsController < ApplicationController
      protect_from_fast_submission :delay => 10, :start => [:edit, :update], :finish => [:update], :rescue => false
      
      rescue_from FastSubmissionProtection::SubmissionTooFastError,
        :with => lambda {|c| c.redirect_to :edit, :alert => 'Don't comment in anger!' }
    end
    
See `FastSubmissionProtection::Controller#protect_from_fast_submission` for more details.

## Filters

You can start and finish the timed submission in different controllers, just set up the filters manually:

    class WelcomeController < ApplicationController
      before_filter FastSubmissionProtection::StartFilter.new('abused_form'), :only => :feedback_form
    end
    
    class FeedbackController < ApplicationController
      before_filter FastSubmissionProtection::FinishFilter.new('abused_form'), :only => :feedback
    end
    
## Instance methods

Or, for the most fine-grained control, you can start and finish at any point

    # within a controller instance
    self.submission_timer('abused_form').start
    
    # some point later, where controller is any controller instance
    # will raise FastSubmissionProtection::SubmissionTooFastError if the above call was < 20 seconds ago
    controller.submission_timer('abused_form', 20).finish
    
    
## Configuration

By default `fast_submission_protection` is off in `test` mode.  You can configure it in environment files as follows:
  
    config.action_controller.allow_fast_submission_protection = false
    
You can also configure it on a per controller basis:

    class MyController < ApplicationController
      self.allow_fast_submission_protection = true
    end

## Rescue

if you include FastSubmissionProtection::Rescue, the error is rescued with an error page with HTTP status 420 (enhance your calm).
This is included by default when you specify `protect_from_fast_submission`.

The default error page resides in 'views/fast_submission_protection/error'.  Simply add this page to your views directory to use a custom page.

Another option is to do something like put a message in the flash, and re-render the new page.  Simply rescue_from FastSubmissionProtection::SubmissionTooFastError.

## Development

Grab the project, use the last known good set of deps, and run the specs:

    git clone http://github.com/i2w/fast_submission_protection
    cd fast_submission_protection
    cp Gemfile.lock.development Gemfile.lock
    bundle
    rake

## License

This project uses the MIT-LICENSE.
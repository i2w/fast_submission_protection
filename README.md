# FastSubmissionProtection

*This is experimental and the API is currently subject to sudden and massive change!*

[![Build Status](https://secure.travis-ci.org/i2w/fast_submission_protection.png?branch=master)](http://travis-ci.org/i2w/timed_spam_rejection)

ActionController plugin that facilitates rejecting spam based on how long the form submission took.

This plugin was developed by [Ian White](http://github.com/ianwhite) and [Nicholas Rutherford](http://github.com/nruth) while working at [Distinctive Doors](http://distinctivedoors.co.uk) who have kindly agreed to release this under the MIT-LICENSE.

## Installation

In your Gemfile:

    gem 'fast_submission_protection'

## Example Usage

    class FeedbackController < ApplicationController
      protect_from_fast_submission # default delay is 5 seconds, protects create from fast submission
    end

    class CommentsController < ApplicationController
      # protects a Comment#update from happening too quickly, and rescues with custom behaviour
      protect_from_fast_submission :delay => 10, :start => [:edit, :update], :finish => [:update], :rescue => false
      
      rescue_from FastSubmissionProtection::SubmissionTooFastError, :with => lambda {|c| c.redirect_to :edit, :alert => 'Don't comment in anger!' }
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

You can start and finish at any point within a controller

    start_timed_submission 'abused_form'
    finish_timed_submission 'abused_form', 20 # raises FastSubmissionProtection::SubmissionTooFastError if the above line was < 20 seconds ago
    
Other methods, like reset timer, and clear timer are available on the timer object

    submission_timer('abused_form') # => a FastSubmissionProtection::SubmissionTimer

## Rescue

if you include FastSubmissionProtection::Rescue, the error is rescued with an error page with HTTP status 420 (enhance your calm).
This is included by default when you specify `protect_from_fast_submission`.

The default error page resides in 'views/fast_submission_protection/error'.  Simply add this page to your views directory to use a custom page.

Another option is to do something like put a message in the flash, and re-render the new page.  Simply rescue_from FastSubmissionProtection::SubmissionTimer.

## Development

Grab the project, use the last known good set of deps, and run the specs:

    git clone http://github.com/i2w/fast_submission_protection
    cd fast_submission_protection
    cp Gemfile.lock.development Gemfile.lock
    bundle
    rake

## License

This project uses the MIT-LICENSE.
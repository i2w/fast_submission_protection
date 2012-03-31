# TimedSpamRejection

ActionController plugin that facilitates rejecting spam based on how long the form submission took.

This plugin was developed by [Ian White](http://github.com/ianwhite) and [Nicholas Rutherford](http://github.com/nruth) while working at [Distinctive Doors](http://distinctivedoors.co.uk) who have kindly agreed to release this under the MIT-LICENSE.

## Installation

In your Gemfile:

    gem 'timed_spam_rejection'

## Example Usage

    class FeedbackController < ApplicationController
      reject_fast_submission # default delay is 5 seconds
    end

    class CommentsController < ApplicationController
      reject_fast_submission :delay => 10.seconds, :message => 'Whoah cowboy!'
    end

If a the time taken between the `new` and `create` action is less than than the delay, an alert
is added to the flash, and the `new` action is re-rendered.

## Development

Grab the project, use the last known good set of deps, and run the specs:

    git clone http://github.com/i2w/timed_spam_rejection
    cd timed_spam_rejection
    cp Gemfile.lock.development Gemfile.lock
    bundle
    rake

## License

This project uses the MIT-LICENSE.
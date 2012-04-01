# TimedSpamRejection

[![Build Status](https://secure.travis-ci.org/i2w/timed_spam_rejection.png?branch=master)](http://travis-ci.org/i2w/timed_spam_rejection)

ActionController plugin that facilitates rejecting spam based on how long the form submission took.

This plugin was developed by [Ian White](http://github.com/ianwhite) and [Nicholas Rutherford](http://github.com/nruth) while working at [Distinctive Doors](http://distinctivedoors.co.uk) who have kindly agreed to release this under the MIT-LICENSE.

## Installation

In your Gemfile:

    gem 'timed_spam_rejection'

## Example Usage

    class FeedbackController < ApplicationController
      reject_fast_create # default delay is 5 seconds
    end

    class CommentsController < ApplicationController
      reject_fast_create :delay => 10.seconds, :message => 'Whoah cowboy!'
    end

If the time taken between the `new` and `create` action is less than than the delay, `reject_fast_create`
is called on the controller, with an error message.

The default implementation of `reject_fast_create` does the following:

    flash.now.alert = error_message
    new
    render :new unless performed?
    
Which will render the new form again, with a flash alert.  Depending on what your `new` action looks like, the
form submission params may not be rendered.  You are encouraged to provide your own implementation.

The `reject_fast_create` method must be public (so the Rejector can call it), and it is in the
hidden_actions list by default.

## i18n

The default error message is looked up using the key `timed_spam_rejection.error`

## Development

Grab the project, use the last known good set of deps, and run the specs:

    git clone http://github.com/i2w/timed_spam_rejection
    cd timed_spam_rejection
    cp Gemfile.lock.development Gemfile.lock
    bundle
    rake

## License

This project uses the MIT-LICENSE.
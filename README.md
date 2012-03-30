# TimedSpamRejection

Rails plugin that facilitates rejecting spam based on how long the form submission took.

This plugin was developed by [Ian White](http://github.com/ianwhite) and [Nicholas Rutherford](http://github.com/nruth) while working at [Distinctive Doors](http://distinctivedoors.co.uk) who have kindly agreed to release under the MIT-LICENSE.

## Example

    class FeedbackController < ApplicationController
      reject_fast_submission # default delay is 5 seconds
    end

    class CommentsController < ApplicationController
      reject_fast_submission :delay => 10.seconds, :message => 'Whoah cowboy!'
    end

If a the time taken between the `new` and `create` action is less than than the delay, an error notice
is added to the flash, and the `new` action is re-rendered.

## License

This project uses the MIT-LICENSE.
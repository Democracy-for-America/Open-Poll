OpenPoll by Democracy for America
========
Make electoral polling exciting.

We built OpenPoll to find out who DFA members supported as the [2016 Democratic Presidential Nominee](http://poll.democracyforamerica.com/results/).

OpenPoll works by allowing voters to select their top three candidates for an upcoming election.

OpenPoll provides a responsive drag and drop interface, built with [hammer.js](http://hammerjs.github.io/). A non-visual interface is provided for users accessing the app with screen readers, or those otherwise experiencing difficulty with the visual interface.

Visitors may explore results via a run-off style interface, to find out what an electoral race would look like with various sets of candidates. When a visitor loads a poll's results page, results are first calculated based on voters' first choices. From there, visitors may remove candidates from the running, causing votes to go follow-up candidates.

OpenPoll was created with Rails 4.2.

Requirements
--------
* MySQL
* Amazon Web Services S3
* MemCached

Instructions
========

Creating a poll
--------
To view a list of existing polls or create a new poll, visit /admin/polls/.

To create a new poll, simply fill in the form fields and save the poll. You may choose to make the results viewable immediately, or you may choose to hide the results until a later date. At any time, you may close or re-open voting.

Adding candidates
--------
After creating a poll, it's time to add candidates. Candidate images should be 200 by 200 pixel squares. You may control which candidates show up on the ballot and in the results via the "show on ballot" and "show in results" settings. This allows you to include write-in candidates in a poll's results, at your discretion.

Thank-you email
--------
"Thanks for voting" emails are sent to voters via sendgrid. (Edit the ActionMailer configuration in config/environments/production.rb to use a different email service.)

You may edit a poll's thank-you email via the poll editor. The following tags are available to insert dynamic content:
```
{{ first_name }}    - A voter's first name
{{ share_url }}     - A URL voters may share with their friends, to refer them to the poll
{{ twitter_url }}   - A Twitter share link for the poll
{{ facebook_url }}  - A Facebook share link for the poll
{{ change_url }}    - A URL voters may use to change their vote
{{ top_candidate }} - A voter's top pick
{{ rank }}          - The current rank of a voter's top pick (1st, 2nd, 3rd, etc.)
```

Custom domains
--------
Polls may be given custom domains, so that the may act as a domain's root URL. To add a custom domain, visit /admin/domains/. Select a poll, and enter the desired domain (e.g. "2016.example.com"). Once you've configured your DNS records, visitors will be able to vote and view results without a URL slug specifying the poll ("2016.example.com," "2016.example.com/results").

ActionKit syncing
--------
ActionKit users may immediately sync results to their ActionKit instance via DFA's [ak_syncable](https://github.com/Democracy-for-America/ak_syncable/) gem.

To enable, simply set the following environment variables:
* ACTIONKIT_PATH
* ACTIONKIT_USERNAME
* ACTIONKIT_PASSWORD

(Refer to [application.yml.example](https://github.com/Democracy-for-America/Open-Poll/blob/master/config/application.yml.example) for examples)

Then, in the admin interface, set a poll's ActionKit page to the name of the ActionKit page you wish to sync results to.

License
--------
MIT

## Synopsis

Discovers the top 30 posts of any Tumblr blog, using the number of notes per post as a metric. Working example [here](https://polar-forest-5071.herokuapp.com/).

## How it works

This Ruby on Rails application sends requests to the [Tumblr API](https://www.tumblr.com/docs/en/api/v2) to receive a blog's posts. Blogs with thousands of posts can take a while to process because only 20 posts can be requested from the Tumblr API at a time. To address this issue, I use [Delayed::Job](https://github.com/collectiveidea/delayed_job) to create a background job, and [Progress Job](https://github.com/d4be4st/progress_job) to inform the user of the job's status. After the job is complete, the user is sent to a page containing the top 30 posts of the Tumblr blog requested. 

## TODO

* Creating the appropriate tests (RSpec?)
* Scheduling a daily job that clears blog entries from the database (Cron?)

## Motivation

A friend of mine wanted a tool to find the top posts of Tumblr blogs, and I wanted to learn more Ruby on Rails, so I decided to create this application.

## References
* [Tumblr Ruby Gem](https://github.com/tumblr/tumblr_client)
* [Delayed::Job](https://github.com/collectiveidea/delayed_job)
* [Progress Job](https://github.com/d4be4st/progress_job)
* [ActiveAttr](https://github.com/cgriego/active_attr)
* [Bootstrap Sass](https://github.com/twbs/bootstrap-sass)

## License

This project is licensed under the terms of the MIT license.
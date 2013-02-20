# Redmine-Deployment

The project is a sample for using [roundsman](https://github.com/iain/roundsman): Roundsman is a clever little tool that combines capistrano&chef to give you a push-button-solution
to provision an empty machine with a customized software-stack __and__ configure you rails(or whatever)-application for deployment.

The example here uses this approach to deploy and configure a machine to run [redmine](http://www.redmine.org), the open-source projectmanagement-software.

It contains examples to configure either an amazon-machine (see [config/deploy/amazon.rb](https://github.com/mugwump/redmine-deploy/blob/master/config/deploy/amazon.rb),
or a local [vagrant](http://www.vagrantup.com)-machine.

You can read more about this approach in the blog-article on [Deploying Redmine](http://www.vierundsechzig.de/blog/?p=708).

## Acknowledgements
This came out of a project that we ran in the Summer of 2012 for [Alere](http://www.alere.com) in collaboration with [Method Park](http://methodpark.de): Many thanks for their input and for agreeing to make this work public.


## Note
The project currently uses [a patched version](https://github.com/mugwump/roundsman) of roundsman, as I ran into some dependency-issues with the chef-version that roundsman is using.

## Contributing
Found an issue? Have a great idea? Want to help? Great! Create an [issue](https://github.com/mugwump/redmine-deploy/issues) for it, [ask](http://github.com/inbox/new/mugwump), or even better; fork the project and fix the problem yourself. Pull requests are always welcome. :)
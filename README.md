# Shiplight

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shiplight'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shiplight

## Usage

Connect the [blink(1)](https://blink1.thingm.com/) USB notification light to your computer.

### Configure CodeShip credentials

Shiplight uses the [Codeship API 2.0](https://apidocs.codeship.com/v2/introduction)
to monitor projects and it uses Basic Auth to authenticate the user.
Shiplight looks for the Basic Auth credentials in a local file named
`credentials` in a folder named `.shiplight` in your home directory.
The files look like this:

```
[default]
username=<codeship-username>
password=<codeship-password>
```

### Monitor all projects

To monitor all projects associated with your credentials, run Shiplight with no arguments:

    $ shiplight

### Monitor specific project(s)

Use the `--repo` (`-r`) command line switch to monitor builds for a specific project:

    $ shiplight -r <repo-name>

Where *\<repo-name\>* is the full or partial name of the Github repository to monitor.

### Monitor commits by a specific user

Use the `--user` (`-u`) command line switch to monitor builds triggered by a specific user:

    $ shiplight -u <user-name>

Where *\<user-name\>* is a full or partial Github user name.

### Monitor commits by a specific project and user

Combine the `-r` and `-u` switches to monitor builds for a specific project and user:

    $ shiplight -u <user-name> -r <repo-name>

### Getting Help

Use `--help` (`-h`) for a complete list of command line options.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dextersealy/shiplight.

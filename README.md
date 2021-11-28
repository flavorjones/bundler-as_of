# Bundler::AsOf

Bundler::AsOf allows you to `bundle install` dependencies as of a certain date. This is intended for use with old projects that have not been well-maintained and that won't bundle today (but were able to be bundled on some date in the past).


## Inspiration

Inspiration for this came from @Schwad and his [portal_gun](https://github.com/Schwad/portal_gun) project. Also a bunch of old mdpress presentations that I have sitting around in Dropbox.


## Usage

First, install this gem as a bundler plugin. I haven't packaged a gem yet, so the best thing to do right now is bundle from git:

``` sh
bundle plugin install --git=https://github.com/flavorjones/bundler-as_of --branch=main bundler-as_of
```

(Note that bundler plugins are project-specific and are installed into the `.bundler` subdirectory.)

Second, pick a date and run `bundle install`:

``` ruby
BUNDLE_AS_OF=2013-11-11 bundle install
```

You should see something like this as the output:

``` text
$ BUNDLE_AS_OF=2013-09-22 bi
NOTE: bundler-as_of: bundling dependencies as of 2013-09-22 ...
NOTE: bundler-as_of: resolving xml-focus [">= 0"] to 0.0.1 released on 2013-08-07
NOTE: bundler-as_of: resolving rake [">= 0"] to 10.1.0 released on 2013-06-20
NOTE: bundler-as_of: resolving rspec [">= 0"] to 2.14.1 released on 2013-07-11
NOTE: bundler-as_of: resolving nokogiri [">= 0"] to 1.6.0 released on 2013-06-10
NOTE: bundler-as_of: resolving rspec-core ["~> 2.14.0"] to 2.14.5 released on 2013-08-14
NOTE: bundler-as_of: resolving rspec-expectations ["~> 2.14.0"] to 2.14.2 released on 2013-08-15
NOTE: bundler-as_of: resolving rspec-mocks ["~> 2.14.0"] to 2.14.3 released on 2013-08-09
NOTE: bundler-as_of: resolving mini_portile ["~> 0.5.0"] to 0.5.1 released on 2013-07-07
NOTE: bundler-as_of: resolving diff-lcs ["< 2.0", ">= 1.1.3"] to 1.2.4 released on 2013-04-21
Fetching gem metadata from https://rubygems.org/.......
Resolving dependencies...
Using rake 10.1.0
Using bundler 2.2.30
Using diff-lcs 1.2.4
Using mini_portile 0.5.1
Using rspec-mocks 2.14.3
Using rspec-core 2.14.5
Using rspec-expectations 2.14.2
Using nokogiri 1.6.0
Using rspec 2.14.1
Using xml-focus 0.0.1
Bundle complete! 9 Gemfile dependencies, 10 gems now installed.
Use `bundle info [gemname]` to see where a bundled gem is installed.

```

## Tips

Once you find the date that works, you may want to use something like [`direnv`](https://direnv.net/) to automatically load that environment variable when you `cd` into the project directory.


## This Gem Won't Help You With ...

### ... finding and using the right Ruby version

`bundler-as_of` only resolves gem dependencies as of the given date. You can look up [Ruby version release dates](https://www.ruby-lang.org/en/downloads/releases/) and use the [Ruby dockerhub OCI images](https://hub.docker.com/_/ruby) for the particular version you want to use.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/flavorjones/bundler-as_of. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/flavorjones/bundler-as_of/blob/main/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


## Code of Conduct

Everyone interacting in the Bundler::AsOf project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/flavorjones/bundler-as_of/blob/main/CODE_OF_CONDUCT.md).

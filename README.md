# Metadata Checker

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'metadata-checker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install metadata-checker

## Usage

To generate a package that will distribute changes to the
metadata-checker gem to hub:

* run https://build.ida.digital.cabinet-office.gov.uk/job/package-sensu-client-gems to generate a new package
* run https://build.ida.digital.cabinet-office.gov.uk/job/third-party-yaml-release to distribute the new package
* update the version of sensu-client-gems in ida-webops/tools/aptly/packages.yaml

## Contributing

1. Fork it ( https://github.com/[my-github-username]/metadata-ocsp-checker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

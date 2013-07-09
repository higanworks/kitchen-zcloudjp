# Kitchen::Zcloudjp A Test Kitchen Driver for ZcloudJP (Based on the joyent SmartDataCenter)

A Test Kitchen Driver for Z Cloud(JP).

Current_Status => 'developing'

This driver uses the [giraffi/zcloudjp](https://github.com/giraffi/zcloudjp) gem to provision and destroy SmartMachines.

This driver was made by reference to the [opscode/kitchen-ec2](https://github.com/opscode/kitchen-ec2/).


## Requirements

There are no external system requirements for this driver. However you will need access to an [Z Cloud(JP)](http://z-cloud.jp/) account.

## Installation

Add this line to your application's Gemfile:

    gem 'kitchen-zcloudjp'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kitchen-zcloudjp

## Configuration

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## <a name="authors"></a> Authors

Created and maintained by [Yukihiko Sawanobori][author] (<sawanoboriyu@higanworks.com>)

## <a name="license"></a> License

Apache 2.0 (see [LICENSE][license])


[author]:           https://github.com/sawanoboly
[license]:          https://github.com/higanworks/kitchen-zcloudjp/blob/master/LICENSE

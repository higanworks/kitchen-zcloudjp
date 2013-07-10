# Kitchen::Zcloudjp A Test Kitchen Driver for Z Cloud(joyent)

[![Gem Version](https://badge.fury.io/rb/kitchen-zcloudjp.png)](http://badge.fury.io/rb/kitchen-zcloudjp)

A Test Kitchen Driver for [Z Cloud(JP)](http://z-cloud.jp/).

Current_Status => 'developing'

This driver uses the [giraffi/zcloudjp](https://github.com/giraffi/zcloudjp) gem to provision and destroy SmartMachines.


## Requirements

There are no external system requirements for this driver. However you will need access to a [Z Cloud(JP)](http://z-cloud.jp/) account and api-key.

## Installation

Add this line to your application's Gemfile:

    gem 'kitchen-zcloudjp'

And then execute:

    $ bundle
    
Or install it yourself as:

    $ gem install kitchen-zcloudjp

## Configuration


### api_key

**Required** The Z Cloud(joyent) apikey to use.

You can see an account section at Z Cloud controle panel.

### dataset

The Z Cloud(joyent) dataset image to use.

The default is SmartOS base64 image `sdc:sdc:base64:13.1.0`.


### package

The Z Cloud(joyent) smartmachine size to use.

The default is `Small_1GB`.

### require_chef_omnibus

For `VirtualMachine` only option. Install chef from omnibus installer on boot.

The default is `nil`.

### Other Options

This driver based on `Kitchen::Driver::SSHBase`. You can set ssh configurations and more.


### `.kitchen.yml` Example

Cookbook test on smartos and ubuntu.

```
---                                                                                                                                                            
driver_plugin: zcloudjp
driver_config:
  api_key: ZCLOUD_API_KEY

platforms:
- name: smartos-base64
- name: ubuntu12
  driver_config:
    require_chef_omnibus: true
    dataset: sdc:jpc:ubuntu-12.04:2.4.1

suites:
- name: default
  run_list: ['recipe[dustbox::default]']
  attributes: {}
```



## Product List (2013-07-09)


```
name                   os            dataset                     package   
MySQL Small 1          SmartOS       sdc:sdc:mysql:1.4.1         Small_1GB 
MySQL Medium 2         SmartOS       sdc:sdc:mysql:1.4.1         Medium_2GB
MySQL Medium 4         SmartOS       sdc:sdc:mysql:1.4.1         Medium_4GB
MySQL Large 1          SmartOS       sdc:sdc:mysql:1.4.1         Large_8GB 
Fedora Small 1         Fedora 14     sdc:sdc:fedora-14:1.0.1     Small_1GB 
Fedora Medium 2        Fedora 14     sdc:sdc:fedora-14:1.0.1     Medium_2GB
Fedora Medium 4        Fedora 14     sdc:sdc:fedora-14:1.0.1     Medium_4GB
Fedora Large 8         Fedora 14     sdc:sdc:fedora-14:1.0.1     Large_8GB 
CentOS Small 1         CentOS 5.7    sdc:jpc:centos-5.7:1.3.0    Small_1GB 
CentOS Medium 2        CentOS 5.7    sdc:jpc:centos-5.7:1.3.0    Medium_2GB
CentOS Medium 4        CentOS 5.7    sdc:jpc:centos-5.7:1.3.0    Medium_4GB
CentOS Large 8         CentOS 5.7    sdc:jpc:centos-5.7:1.3.0    Large_8GB 
Ubuntu Small 1         Ubuntu 10.04  sdc:sdc:ubuntu10.04:0.1.0   Small_1GB 
Ubuntu Medium 2        Ubuntu 10.04  sdc:sdc:ubuntu10.04:0.1.0   Medium_2GB
Ubuntu Medium 4        Ubuntu 10.04  sdc:sdc:ubuntu10.04:0.1.0   Medium_4GB
Ubuntu Large 8         Ubuntu 10.04  sdc:sdc:ubuntu10.04:0.1.0   Large_8GB 
SmartOS Plus Small 1   SmartOS       sdc:sdc:standard:1.0.7      Small_1GB 
SmartOS Plus Medium 2  SmartOS       sdc:sdc:standard:1.0.7      Medium_2GB
SmartOS Plus Medium 4  SmartOS       sdc:sdc:standard:1.0.7      Medium_4GB
SmartOS Plus Large 8   SmartOS       sdc:sdc:standard:1.0.7      Large_8GB 
Hadoop Small 1         SmartOS       sdc:sdc:hadoop:1.0.0        Small_1GB 
Hadoop Medium 2        SmartOS       sdc:sdc:hadoop:1.0.0        Medium_2GB
Hadoop Medium 4        SmartOS       sdc:sdc:hadoop:1.0.0        Medium_4GB
Hadoop Large 8         SmartOS       sdc:sdc:hadoop:1.0.0        Large_8GB 
Chef Server Small 1    SmartOS       sdc:sdc:chefserver:1.0.0    Small_1GB 
Chef Server Medium 2   SmartOS       sdc:sdc:chefserver:1.0.0    Medium_2GB
Chef Server Medium 4   SmartOS       sdc:sdc:chefserver:1.0.0    Medium_4GB
Chef Server Large 8    SmartOS       sdc:sdc:chefserver:1.0.0    Large_8GB 
Ubuntu Small 1         Ubuntu 12.04  sdc:jpc:ubuntu-12.04:2.4.1  Small_1GB 
Ubuntu Medium 2        Ubuntu 12.04  sdc:jpc:ubuntu-12.04:2.4.1  Medium_2GB
Ubuntu Medium 4        Ubuntu 12.04  sdc:jpc:ubuntu-12.04:2.4.1  Medium_4GB
Ubuntu Medium 8        Ubuntu 12.04  sdc:jpc:ubuntu-12.04:2.4.1  Large_8GB 
Debian Small 1         Debian 6.0.7  sdc:sdc:debian-6.0.7:2.4.1  Small_1GB 
Debian Medium 2        Debian 6.0.7  sdc:sdc:debian-6.0.7:2.4.1  Medium_2GB
Debian Medium 4        Debian 6.0.7  sdc:sdc:debian-6.0.7:2.4.1  Medium_4GB
Debian Large 8         Debian 6.0.7  sdc:sdc:debian-6.0.7:2.4.1  Large_8GB 
SmartOS Small 1        SmartOS       sdc:sdc:base64:13.1.0       Small_1GB 
SmartOS Medium 2       SmartOS       sdc:sdc:base64:13.1.0       Medium_2GB
SmartOS Medium 4       SmartOS       sdc:sdc:base64:13.1.0       Medium_4GB
SmartOS Large 8        SmartOS       sdc:sdc:base64:13.1.0       Large_8GB 
MongoDB Small 1        SmartOS       sdc:sdc:mongodb:1.4.5       Small_1GB 
MongoDB Medium 2       SmartOS       sdc:sdc:mongodb:1.4.5       Medium_2GB
MongoDB Medium 4       SmartOS       sdc:sdc:mongodb:1.4.5       Medium_4GB
MongoDB Large 8        SmartOS       sdc:sdc:mongodb:1.4.5       Large_8GB 
Node.js Small 1        SmartOS       sdc:sdc:nodejs:13.1.0       Small_1GB 
Node.js Medium 2       SmartOS       sdc:sdc:nodejs:13.1.0       Medium_2GB
Node.js Medium 4       SmartOS       sdc:sdc:nodejs:13.1.0       Medium_4GB
Node.js Large 8        SmartOS       sdc:sdc:nodejs:13.1.0       Large_8GB 
Percona Small 1        SmartOS       sdc:sdc:percona:13.1.0      Small_1GB 
Percona Medium 2       SmartOS       sdc:sdc:percona:13.1.0      Medium_2GB
Percona Medium 4       SmartOS       sdc:sdc:percona:13.1.0      Medium_4GB
Percona Large 8        SmartOS       sdc:sdc:percona:13.1.0      Large_8GB 
Riak Small 1           SmartOS       sdc:sdc:riak:13.1.0         Small_1GB 
Riak Medium 2          SmartOS       sdc:sdc:riak:13.1.0         Medium_2GB
Riak Medium 4          SmartOS       sdc:sdc:riak:13.1.0         Medium_4GB
Riak Large 1           SmartOS       sdc:sdc:riak:13.1.0         Large_8GB 
CentOS Small 1         CentOS 6.4    sdc:sdc:centos-6:2.4.1      Small_1GB 
CentOS Medium 2        CentOS 6.4    sdc:sdc:centos-6:2.4.1      Medium_2GB
CentOS Medium 4        CentOS 6.4    sdc:sdc:centos-6:2.4.1      Medium_4GB
CentOS Large 8         CentOS 6.4    sdc:sdc:centos-6:2.4.1      Large_8GB 
```

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

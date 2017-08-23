[![Build Status](https://travis-ci.org/kigster/register.svg?branch=master)](https://travis-ci.org/kigster/register)
[![Code Climate](https://codeclimate.com/github/kigster/register/badges/gpa.svg)](https://codeclimate.com/github/kigster/register)
[![Test Coverage](https://codeclimate.com/github/kigster/register/badges/coverage.svg)](https://codeclimate.com/github/kigster/register/coverage)
[![Issue Count](https://codeclimate.com/github/kigster/register/badges/issue_count.svg)](https://codeclimate.com/github/kigster/register)


# *Register* —  A Module Method Factory Pattern

**Register** is a tiny library that can be included in a module that is to become a Façade to several application globals via auto-generated module-level methods.

A good example is a register of several connections to either *Redis* or *MemCached*, for example you might have a short-term memcached connection with a short default expiration TTL, and a longer-living one that requires sweeping to clean. You could use `Register` to wrap access to these singletons in `MyModule.cache_type` accessors.

## Usage

### Creating a Register

To create a register module, just include `Register` in any ruby module: 

```ruby
require 'register'

module Cache
  include Register
end
```

### Storing Items in the Register

To add items to the register, call the `<<` method, passing an array of identifiers, followed by the actual item to store. In other words, the last items of the argument array is the actual item stored against each of the identifiers passed before it.

```ruby

# Our "item" will be a simple cache store with a name:
CacheStore = Struct.new(:name)

# Register items associated with any one of the identifiers
Cache.register :planetary, :cosmic, CacheStore.new(:saturn)

# You can use << syntax which is an alias to #register, but 
# then use << to append the actual item
Cache.<< %i[primary main rails deploy] << CacheStore.new(:primary)

Cache.<< %i[durable secondary] << CacheStore.new(:secondary)
```

### Looking up (Fetching) Items from the Register

There are two ways to fetch the previously-stored item:

  1. Using the `#for(:name)` method
  2. Using the auto-generated module-level accessor
  
In the first example, we would call `Cache.for(:planetary)` to fetch the cache store, while in the second case we would call `Cache.planetary` method, which provides additional guarantees: if the method is not there, something is definitely wrong.  

```ruby
Cache.planetary.name should eq(:saturn)
Cache.primary === Cache.main === Cache.rails === Cache.deploy
Cache.durable.name = 'DURABLE'
Cache.secondary.name # => 'DURABLE'
```

Here is a more complete RSPec example:

```ruby
require 'rspec'
require 'rspec/its'
RSpec.describe Cache do
  subject(:cache) { Cache }
  its(:planetary) { should eq CachStore.new(:saturn) }    
  its(:deploy) { should eq CachStore.new(:primary) }    
  its(:durable) { should eq CachStore.new(:secondary) }
  it 'should also respond to #for' do
    expect(cache.for(:secondary)).to eq(CacheStore(:secondary))      
  end
end
```
    
## Installation

    gem install register 

## Note on Patches and Pull Requests
 
 * Fork the project.
 * Make your feature addition or bug fix.
 * Add tests for it. This is important so I don't break it in a future version unintentionally.
 * Commit, do not mess with rakefile, version, or history. If you want to have your own version, that is fine but bump  version in a commit by itself I can ignore when I pull.
 * Send a pull request. Bonus points for topic branches.

## Copyright

Copyright &copy; 2017 Konstantin Gredeskoul. See LICENSE for details.

## Contributors

 * [Konstantin Gredeskoul](https://github.com/kigster)
 
 


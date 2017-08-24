[![Build Status](https://travis-ci.org/kigster/register.svg?branch=master)](https://travis-ci.org/kigster/register)
[![Code Climate](https://codeclimate.com/github/kigster/register/badges/gpa.svg)](https://codeclimate.com/github/kigster/register)
[![Test Coverage](https://codeclimate.com/github/kigster/register/badges/coverage.svg)](https://codeclimate.com/github/kigster/register/coverage)
[![Issue Count](https://codeclimate.com/github/kigster/register/badges/issue_count.svg)](https://codeclimate.com/github/kigster/register)


# *Register* —  A Module Method Factory Pattern

**Register** is a tiny library that can be included in a module that is to become a Façade to several application globals via auto-generated module-level methods.

A good example is a register of several connections to either *Redis* or *MemCached*, for example you might have a short-term memcached connection with a short default expiration TTL, and a longer-living one that requires sweeping to clean. You could use `Register` to wrap access to these singletons in `MyModule.cache_type` accessors.

## Usage

You need to create a module for each individual "store" — behind the scenes `Register` uses ruby `Hash`, but protects any write access to it using a local mutex to ensure thread-safety.

### Creating a Register

To create a register module, just include `Register` in any of your custom ruby modules: 

```ruby
require 'register'

module Cache
  include Register
end
```

### Adding Items to the Register

To add items to the register, call the `#register` method on the module (or it's alias `.<<`, passing an array of identifiers first, followed by the actual item to store. 

In other words, the very last item of the argument array is the actual item stored against each of the keys passed in an array before it.

The `#register` method returns the item successfully stored, or raises one of several exceptions.

```ruby

# Our "item" will be a simple cache store with a name:
CacheStore = Struct.new(:name)

# Register items associated with any one of the identifiers
Cache.register :planetary, 
               :cosmic, 
               CacheStore.new(:saturn)
#=> #<struct CacheStore name=:saturn>

# Use the block syntax to define the value:
Cache.register(*%i[primary main rails deploy]) do
  CacheStore.new(:primary)
end
#=> #<struct CacheStore name=:primary>

# Use the << method alias instead (just ensure the proper 
# grouping of the arguments)
Cache << %i[number].push(Math::PI)
#=> 3.141592653589793

# Using double << with () 
Cache << (%i[durable secondary] << CacheStore.new(:secondary))
#=> #<struct CacheStore name=:secondary>
```

#### Exceptions while Adding Items

 * `AlreadyRegisteredError` is thrown when the key is already in the store, and the option `:ignore_if_exists` is not passed to the `register()` method;

 * `ReservedIdentifierError` is thrown upon an attempt to register a keyword that is reserved (i.e. clashes with one of the methods on the blank `Module`).


### Fetching an Item from the Register

There are two ways to fetch the previously-stored item:

  1. Using the `#for(:name)` method

  2. Using the auto-generated module-level accessor
  
In the first example, we would call `Cache.for(:planetary)` to fetch the cache store, while in the second case we would call `Cache.planetary` method, which provides additional guarantees: if the method is not there, something is definitely wrong.  

```ruby
Cache.cosmic
# => #<struct CacheStore name=:saturn>
Cache.planetary.name 
# => :saturn
Cache.primary == Cache.main == Cache.rails == Cache.deploy
# => true
Cache.durable.name = 'DURABLE'
# => 'DURABLE'
Cache.secondary.name 
# => 'DURABLE'
```

#### Exceptions while Fetching Items

 * `NoSuchIdentifierError` is thrown upon lookup with method `#for` when no requested key was found in the store;

## Contributing
 
 * Fork the project.
 * Make your feature addition or bug fix.
 * Add specs for it, as without tests the PR will be rejected.
 * Do not change the version.
 * Send a pull request, with a well worded description.


There are some additional methods that will help you debug should things go weird:

### Additional Methods: `#keys` and `#values`

These two methods proxy into the underlying `Hash`. The `#values` method returns the uniq'd array of the values.

```ruby
# ap Cache.keys
[
    [0] :planetary,
    [1] :cosmic,
    [2] :primary,
    [3] :main,
    [4] :rails,
    [5] :deploy,
    [6] :durable,
    [7] :secondary,
    [8] :number
]
# ap Cache.store.values.uniq
[
    [0] #<Struct:CacheStore:0x7facd107c800
        name = :saturn
    >,
    [1] #<Struct:CacheStore:0x7facd2836c98
        name = :primary
    >,
    [2] #<Struct:CacheStore:0x7facd281fa98
        name = :secondary
    >,
    [3] 3.141592653589793
]
```

### Internal Storage

This gem uses a plain ruby `Hash` to store the values, but protects write access with a `Mutex`. 

While it is not advisable to manipulate the underlying storage, you can access it via `Cache.send(:store)`, i.e:

```ruby
Cache.send(:store).class
# => Hash
```

## Installation

    gem install register 
    
Or if you are using Bundler, add the following to your `Gemfile`:

    gem 'register'        

## Copyright

Copyright &copy; 2017 Konstantin Gredeskoul. See [LICENSE](LICENSE.txt) for details.

## Contributors

 * [Konstantin Gredeskoul](https://github.com/kigster)
 * You?
 
 


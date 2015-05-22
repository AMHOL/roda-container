# roda-container <a href="https://gitter.im/AMHOL/roda-container" target="_blank">![Join the chat at https://gitter.im/AMHOL/roda-container](https://badges.gitter.im/Join%20Chat.svg)</a>

A plugin for Roda which turns your application into a (IoC) container

## Installation

```ruby
gem 'roda-container', '0.0.4'
```

## Usage

```ruby
class MyApplication < Roda
  plugin :container
end

class UserRepository
  def self.first
    { name: 'Jack' }
  end
end

MyApplication.register(:user_repository, UserRepository)
MyApplication.resolve(:user_repository).first
  # => {:name=>"Jack"}

class PersonRepository
  def first
    { name: 'Gill' }
  end
end

MyApplication.register(:person_repository, -> { PersonRepository.new })
MyApplication.resolve(:person_repository).first
  # => {:name=>"Gill"}
```

If you want to register a proc, or anything that responds to call, without calling when resolving it, you can pass the `call: false` option:

```ruby
class MyApplication < Roda
  plugin :container
end

MyApplication.route do |r|
  # Roda responds to the instance method #call, with the call: false
  # option, calling MyApplication.instance.resolve(:app) will not attempt to call
  # it, without the option, the application would error
  register(:app, self, call: false) # Roda#register, regiser with the request container
end
```

## Thread safety

Please note the use of and `MyApplication.instance.resolve` above, without the call to `Roda.instance` the item will not be present in the container, as it was registered with the request container (using Roda#register), without this, there is high possiblilty of a thread safety issue when registering anything at runtime. For example:

```ruby
class MyApplication < Roda
  plugin :container
end

MyApplication.route do |r|
  # DO NOT DO THIS, SEE ABOVE ^^^
  MyApplication.register(:app, self, call: false) # Roda.register, register with the global container

  r.on 'users' do
    # ...
    r.get :id do |user_id|
      MyApplication.resolve(:app)
    end

    r.post do
      sleep(5)
      MyApplication.resolve(:app)
    end
  end
end
```

Immagine a user hitting `POST /users`, then another user hitting `GET /users/{id}` in quick succession; the first user registers their instance of app with the global container, then hits the 5 second sleep, then the second user comes along, registers their instance of app with the global container, the request executes and they go on their merry way.

A few seconds later the 5 second sleep is complete, and the first user resolves `:app` from the global container, only to find the application instance that was registered by the user hitting `GET /users/{id}`, they have just spent 5 minutes meticulously filling out your webform to create their user account, only for their payload to be lost in a race condition, needless to say - you don't want this to happen.

This is preventable by registering anything specific to a request with the request container, this is done using the `Roda#register` method, i.e.

```ruby
MyApplication.route do |r|
  register(:app, self, call: false) # Roda#register, regiser with the request container
end
``

## Contributing

1. Fork it ( https://github.com/AMHOL/roda-container )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

[MIT](LICENSE.txt)

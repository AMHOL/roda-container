# roda-container

A plugin for Roda which turns your application into a (IoC) container

## Installation

```ruby
gem 'roda-container', '0.0.2'
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
  # option, calling MyApplication.resolve(:app) will not attempt to call
  # it, without the option, the application would error
  MyApplication.register(:app, self, call: false)
```

## Contributing

1. Fork it ( https://github.com/AMHOL/roda-container )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

[MIT](LICENSE.txt)

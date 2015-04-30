# roda-container

[![Join the chat at https://gitter.im/AMHOL/roda-container](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/AMHOL/roda-container?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A plugin for Roda which turns your application into a (IoC) container

## Installation

```ruby
gem 'roda-container', '0.0.1'
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

## Contributing

1. Fork it ( https://github.com/AMHOL/roda-container )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

[MIT](LICENSE.txt)

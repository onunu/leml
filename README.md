# Leml(Leaf Enrypted YAML)
Leml encrypt your secrets only leaf.  
You and member can see only keys without decrypt.  
It depend on rails.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'leml'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install leml
```

## Usage
```bash
$ gem install leml

# Initialize your secrets
$ rake leml:init
Complete!
create  config/leml.key
create  config/leml.yml

Caution Don't forget add key file in gitignore

# Edit your secrets
# It use environmental variable `EDITOR`, please set your editor.
$ EDITOR=vim rake leml:edit
## edit your secrets
OK, your secrets is encrypted.

# You can also see secrets
$ rake leml:show
---
development:
  author: onunu
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

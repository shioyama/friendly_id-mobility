# FriendlyId Mobility

[Mobility](https://github.com/shioyama/mobility) support for
[FriendlyId](https://github.com/norman/friendly_id).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'friendly_id-mobility'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install friendly_id-mobility

## Translating Slugs using Mobility

To translate slugs using Mobility, simply translate the attribute you want to
use to generate slugs and also translate the slug attribute itself, and then
call `friendly_id` with `use: :mobility`:

```ruby
class Post < ActiveRecord::Base
  include Mobility
  translates :title, :slug

  extend FriendlyId
  friendly_id :title, use: :mobility
end
```

You can now save `title` in any locale and FriendlyId will generate a
slug, stored by Mobility in the current locale:

```ruby
post = Post.create(title: "My Foo Title")
post.title
#=> "My Foo Title"
post.slug
#=> "my-foo-title"
Mobility.locale = :fr
post.title = "Mon titre foo"
post.save
post.slug
#=> "mon-titre-foo"
Mobility.locale = :en
post.slug
#=> "my-foo-title"
```

Finders work too:

```ruby
Mobility.locale = :en
Post.friendly.find("my-foo-title")
#=> #<Post id: 1 ...>
Mobility.locale = :fr
Post.friendly.find("mon-titre-foo")
#=> #<Post id: 1 ...>
```

## Development

(TODO)

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/shioyama/friendly_id-mobility. This project is intended to
be a safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of
conduct.


## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

FriendlyId Mobility
===================

[![Gem Version](https://badge.fury.io/rb/friendly_id-mobility.svg)][gem]
[![Build Status](https://travis-ci.org/shioyama/friendly_id-mobility.svg?branch=master)][travis]

[Mobility](https://github.com/shioyama/mobility) support for
[FriendlyId](https://github.com/norman/friendly_id).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'friendly_id-mobility'
```

And then execute:

```
bundle
```

Or install it yourself as:

```
gem install friendly_id-mobility
```

Run the Mobility generator and migrate:

```
rails generate mobility:install
rake db:migrate
```

Run the FriendlyId generator, without the migration to generate the slugs
table:

```
rails generate friendly_id --skip-migration
```

You're ready to go!

## Usage

There are two ways to translate FriendlyId slugs with Mobility: with an
untranslated base column (like the SimpleI18n module included with FriendlyId),
and with a translated base column.

### Translating Slug

If you only want to translate the slug, include `Mobility` and translate the
slug with whichever backend you want (here we're assuming the default KeyValue
backend). Here, `name` is untranslated (so there is a column on the `posts`
table named `name`):

```ruby
class Journalist < ActiveRecord::Base
  include Mobility
  translates :slug

  extend FriendlyId
  friendly_id :title, use: :mobility
end
```

You can now save `name` and generate a slug, and update the slug in any locale
using `set_friendly_id`

```ruby
journalist = Journalist.create(name: "John Smith")
journalist.slug
#=> "john-smith"
journalist.set_friendly_id("Juan Fulano", :es)
journalist.save!
I18n.with_locale(:es) { journalist.friendly_id }
#=> "juan-fulano"
```

So the slug is translated, but the base attribute (`name`) is not.

### Translating Slug and Base Attribute

You can also translate both slug and base attribute:

```ruby
class Article < ActiveRecord::Base
  include Mobility
  translates :slug, :title, dirty: true

  extend FriendlyId
  friendly_id :title, use: :mobility
end
```

In this case, `title` is translated, and its value in the current locale will
be used to generate the slug in this locale:

```ruby
article = Article.create(title: "My Foo Title")
article.title
#=> "My Foo Title"
article.slug
#=> "my-foo-title"
Mobility.locale = :fr
article.title = "Mon titre foo"
article.save
article.slug
#=> "mon-titre-foo"
Mobility.locale = :en
article.slug
#=> "my-foo-title"
```

Setting `dirty: true` on the translated base attribute is recommended in order
to ensure that changes in any locale trigger updates to the slug in that
locale.

### Friendly Finders with Translated Attributes

The Mobility `i18n` scope is mixed into the `friendly` scope for models which
`use: mobility`, so you can find translated slugs just like you would an
untranslated one:

```ruby
Mobility.locale = :en
Article.friendly.find("my-foo-title")
#=> #<Article id: 1 ...>
Mobility.locale = :fr
Article.friendly.find("mon-titre-foo")
#=> #<Article id: 1 ...>
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/shioyama/friendly_id-mobility. This project is intended to
be a safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of
conduct.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

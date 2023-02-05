FriendlyId Mobility
===================

[![Gem Version](https://badge.fury.io/rb/friendly_id-mobility.svg)][gem]
[![Build Status](https://github.com/shioyama/friendly_id-mobility/workflows/CI/badge.svg)][actions]
[![Code Climate](https://api.codeclimate.com/v1/badges/1dad5895b69b4ae5bd38/maintainability.svg)][codeclimate]

[gem]: https://rubygems.org/gems/friendly_id-mobility
[actions]: https://github.com/shioyama/friendly_id-mobility/actions
[codeclimate]: https://codeclimate.com/github/shioyama/friendly_id-mobility

[Mobility](https://github.com/shioyama/mobility) support for
[FriendlyId](https://github.com/norman/friendly_id).

Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'friendly_id-mobility', '~> 1.0.4'
```

And then execute:

```
bundle
```

Then run the Mobility generator:

```
rails generate mobility:install
```

This will generate an initializer for Mobility. To ensure that FriendlyId sees
changes correctly on attributes, enable (uncomment) the `dirty` plugin line in
your Mobility configuration:

```ruby
Mobility.configure do
  plugins do
    # ...
    dirty
    # ...
  end
end
```

Next, run the FriendlyId generator:

```
rails generate friendly_id
```

And migrate to generate Mobility and FriendlyId tables:

```
rake db:migrate
```

You're ready to go!

Usage
-----

There are two ways to translate FriendlyId slugs with Mobility: with an
untranslated base column (like the SimpleI18n module included with FriendlyId),
and with a translated base column.

### Translating Slug

If you only want to translate the slug, include `Mobility` and translate the
slug with whichever backend you want (here we're assuming the default KeyValue
backend). Here, `name` is untranslated (so there is a column on the
`journalists` table named `name`):

```ruby
class Journalist < ActiveRecord::Base
  extend Mobility
  translates :slug

  extend FriendlyId
  friendly_id :name, use: :mobility
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
  extend Mobility
  translates :slug, :title

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

### Friendly Finders with Translated Attributes

The Mobility `i18n` scope is mixed into the `friendly` scope for models which
`use: :mobility`, so you can find translated slugs just like you would an
untranslated one:

```ruby
Mobility.locale = :en
Article.friendly.find("my-foo-title")
#=> #<Article id: 1 ...>
Mobility.locale = :fr
Article.friendly.find("mon-titre-foo")
#=> #<Article id: 1 ...>
```

Note that this gem is not compatible with the `finders` add-on; using both
together will lead to unexpected results. To use these finder methods, you will
have to remove `finders` and explicitly call `friendly.find`, as above.

### Slug History

To use the FriendlyId history module, use `use: [:history, :mobility]` when
calling `friendly_id` from your model:

```ruby
class Article < ActiveRecord::Base
  extend Mobility
  translates :slug, :title

  extend FriendlyId
  friendly_id :title, use: [:history, :mobility]
end
```

It is important to have `:history` *before* `:mobility` here, since the
Mobility module looks for the presence of the history module and only adds
necessary overrides if history has been enabled (so the reverse order will not
work).

To use the history feature, you must add a `locale` column to your
`friendly_id_slugs` table, which you can do with the `friendly_id_mobility` generator:

```
rails generate friendly_id_mobility
```

Then run the generated migration with `rake db:migrate`.

License
-------

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

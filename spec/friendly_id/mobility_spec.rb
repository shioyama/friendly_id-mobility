require 'spec_helper'

describe FriendlyId::Mobility do
  it 'has a version number' do
    expect(FriendlyId::Mobility::VERSION).not_to be nil
  end

  context "base column is untranslated" do
    describe "#friendly_id" do
      it "returns the current locale's slug" do
        journalist = Journalist.new(:name => "John Doe")
        journalist.slug_es = "juan-fulano"
        journalist.valid?
        I18n.with_locale(I18n.default_locale) do
          expect(journalist.friendly_id).to eq("john-doe")
        end
        I18n.with_locale(:es) do
          expect(journalist.friendly_id).to eq("juan-fulano")
        end
      end
    end

    describe "generating slugs in different locales" do
      it "creates record with slug for the current locale" do
        I18n.with_locale(I18n.default_locale) do
          journalist = Journalist.new(name: "John Doe")
          journalist.valid?
          expect(journalist.slug_en).to eq("john-doe")
          expect(journalist.slug_es).to be_nil
        end

        I18n.with_locale(:es) do
          journalist = Journalist.new(name: "John Doe")
          journalist.valid?
          expect(journalist.slug_es).to eq("john-doe")
          expect(journalist.slug_en).to be_nil
        end
      end
    end

    describe "#to_param" do
      it "returns numeric id when there is no slug for the current locale" do
        journalist = Journalist.new(name: "Juan Fulano")
        I18n.with_locale(:es) do
          journalist.save!
          journalist.to_param
          expect(journalist.to_param).to eq("juan-fulano")
        end
        expect(journalist.to_param).to eq(journalist.id.to_s)
      end
    end

    describe "#set_friendly_id" do
      it "sets friendly id for locale" do
        journalist = Journalist.create!(name: "John Smith")
        journalist.set_friendly_id("Juan Fulano", :es)
        journalist.save!
        expect(journalist.slug_es).to eq("juan-fulano")
        I18n.with_locale(:es) do
          expect(journalist.to_param).to eq("juan-fulano")
        end
      end

      it "should fall back to default locale when none is given" do
        journalist = I18n.with_locale(:es) do
          Journalist.create!(name: "Juan Fulano")
        end
        journalist.set_friendly_id("John Doe")
        journalist.save!
        expect(journalist.slug_en).to eq("john-doe")
      end

      it "sequences localized slugs" do
        journalist = Journalist.create!(name: "John Smith")
        I18n.with_locale(:es) do
          Journalist.create!(name: "Juan Fulano")
        end
        journalist.set_friendly_id("Juan Fulano", :es)
        journalist.save!

        aggregate_failures do
          expect(journalist.to_param).to eq("john-smith")
          I18n.with_locale(:es) do
            expect(journalist.to_param).to match(/juan-fulano-.+/)
          end
        end
      end
    end

    describe ".friendly" do
      it "finds record by slug in current locale" do
        john = Journalist.create!(name: "John Smith")
        juan = I18n.with_locale(:es) { Journalist.create!(name: "Juan Fulano") }

        aggregate_failures do 
          expect(Journalist.friendly.find("john-smith")).to eq(john)
          expect {
            Journalist.friendly.find("juan-fulano")
          }.to raise_error(ActiveRecord::RecordNotFound)

          I18n.with_locale(:es) do
            expect(Journalist.friendly.find("juan-fulano")).to eq(juan)
            expect { Journalist.friendly.find("john-smith") }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      it "works with normal finds" do
        john = Journalist.create!(name: "John Smith")

        expect(Journalist.friendly.find(john.id)).to eq(john)
      end
    end
  end

  context "base column is translated" do
    before do
      klass = Class.new(ActiveRecord::Base)

      # Add dirty plugin for this class, needed for these tests
      translations_class = Class.new(Mobility.translations_class)
      translations_class.plugins do
        dirty
      end

      klass.class_eval do
        self.table_name = :articles
        include translations_class.new(:slug, :title, type: :string, fallbacks: { en: [:es] })

        extend FriendlyId
        friendly_id :title, use: :mobility
      end
      stub_const('Article', klass)
    end

    describe "#friendly_id" do
      it "sets friendly_id from base column in each locale" do
        article = Article.create!(:title => "War and Peace")
        I18n.with_locale(:'es-MX') { article.title = "Guerra y paz" }
        article.save!
        article = Article.first

        aggregate_failures do
          I18n.with_locale(:'es-MX') { expect(article.friendly_id).to eq("guerra-y-paz") }
          I18n.with_locale(:en) { expect(article.friendly_id).to eq("war-and-peace") }
        end
      end
    end

    describe "#set_friendly_id" do
      # Ref: https://github.com/shioyama/friendly_id-mobility/issues/10
      it "generates slug records for all locales with present values" do
        article = Article.new(title_en: "English title", title_es: "Título español")
        article.save

        expect(article.slug_en).to eq("english-title")
        expect(article.slug_es).to eq("titulo-espanol")
      end

      it "regenerates slug records for all locales with present values when reset" do
        article = Article.new(title_en: "English title", title_es: "Título español")
        article.save

        article.slug_en = nil
        article.slug_es = nil
        article.save

        expect(article.slug_en).to eq("english-title")
        expect(article.slug_es).to eq("titulo-espanol")
      end

      # Regression: https://github.com/shioyama/friendly_id-mobility/pull/26
      it "ignores changes to other columns" do
        I18n.enforce_available_locales = true
        application = double(:application)
        allow(application).to receive_message_chain(:config, :i18n, :available_locales).and_return([:en, :ja])
        expect(Rails).to receive(:application).at_least(1).time.and_return(application)
        article = Article.new(title_en: "English title", title_translations: "foo")
        expect { article.save }.not_to raise_error
      ensure
        I18n.enforce_available_locales = false
      end
    end
  end

  describe "history" do
    # Check that normal history functions are working, both with and without locale
    # column on the slugs table.
    describe "base features" do
      it "inserts record in slugs table on create" do
        post = Post.create!(title: "foo title", content: "once upon a time...")
        expect(post.slugs.any?).to eq(true)
      end

      it "does not create new slug record if friendly_id is not changed" do
        post = Post.create(published: true)
        post.published = false
        post.save!
        expect(FriendlyId::Slug.count).to eq(1)
      end

      it "creates new slug record when friendly_id changes" do
        post = Post.create(title: "foo title")
        post.title = post.title + " 2"
        post.slug = nil
        post.save!
        expect(FriendlyId::Slug.count).to eq(2)
      end

      it "is findable by old slugs" do
        post = Post.create(title: "foo title")
        old_friendly_id = post.friendly_id
        post.title = post.title + " 2"
        post.slug = nil
        post.save!
        expect(Post.friendly.find(old_friendly_id)).to eq(post)
        expect(Post.friendly.exists?(old_friendly_id))
      end

      it "creates slug records on each change" do
        post = Post.create! title: "hello"
        expect(FriendlyId::Slug.count).to eq(1)
        post = Post.friendly.find("hello")
        post.title = "hello again"
        post.slug = nil
        post.save!
        expect(FriendlyId::Slug.count).to eq(2)
      end
    end

    describe "translations", :locale_slugs do
      it "stores locale on slugs" do
        expect {
          Post.create(title: "Foo Title")
        }.to change(FriendlyId::Slug, :count).by(1)
        post = Post.first
        slug = post.slugs.first

        aggregate_failures do
          expect(slug.slug).to eq("foo-title")
          expect(slug.locale).to eq("en")
        end

        expect {
          Mobility.with_locale(:fr) do
            post.title = "Foo Titre"
            post.save!
          end
        }.to change(FriendlyId::Slug.unscoped, :count).by(1)

        slug = post.slugs.find { |slug| slug.locale == "fr" }
        expect(slug.slug).to eq("foo-titre")
      end

      it "finds slug in current locale" do
        Mobility.with_locale(:'pt-BR') do
          post = Post.create!(title: "Foo Title")
          post.title = "New Title"
          post.slug = nil
          post.save!
        end

        Mobility.with_locale(:de) do
          post = Post.create!(title: "Foo Title")
          post.title = "New Title"
          post.slug = nil
          post.save!
        end

        expect { Post.friendly.find("new-title") }.to raise_error(ActiveRecord::RecordNotFound)
        expect { Post.friendly.find("foo-title") }.to raise_error(ActiveRecord::RecordNotFound)

        Mobility.with_locale(:'pt-BR') do
          expect(Post.friendly.find("foo-title")).to eq(Post.first)
          expect(Post.friendly.find("new-title")).to eq(Post.first)
        end

        Mobility.with_locale(:de) do
          expect(Post.friendly.find("foo-title")).to eq(Post.last)
          expect(Post.friendly.find("new-title")).to eq(Post.last)
        end
      end
    end

    describe "non-translated", :locale_slugs do
      it "stores no locale on slugs" do
        expect {
          Product.create(name: "Foo Title")
        }.to change(FriendlyId::Slug, :count).by(1)
        product = Product.first
        slug = product.slugs.first

        aggregate_failures do
          expect(slug.slug).to eq("foo-title")
          expect(slug.locale).to eq(nil)
        end

        expect {
          Mobility.with_locale(:fr) do
            product.name = "Foo Titre"
            product.save!
          end
        }.not_to change(FriendlyId::Slug.unscoped, :count)
      end

      it "finds slug ignoring current locale" do
        Mobility.with_locale(:'pt-BR') do
          product = Product.create!(name: "Foo Title")
          product.name = "New Title"
          product.slug = nil
          product.save!
        end

        second_product_slugs = nil

        Mobility.with_locale(:de) do
          product = Product.create!(name: "Foo Title")
          product.name = "New Title"
          product.slug = nil
          product.save!
          second_product_slugs = product.slugs.pluck(:slug)
        end

        expect { Product.friendly.find("new-title") }.not_to raise_error
        expect { Product.friendly.find("foo-title") }.not_to raise_error

        Mobility.with_locale(:'pt-BR') do
          expect(Product.friendly.find("foo-title")).to eq(Product.first)
          expect(Product.friendly.find("new-title")).to eq(Product.first)

          expect(Product.friendly.find(second_product_slugs.first)).to eq(Product.second)
          expect(Product.friendly.find(second_product_slugs.second)).to eq(Product.second)
        end

        Mobility.with_locale(:de) do
          expect(Product.friendly.find("foo-title")).to eq(Product.first)
          expect(Product.friendly.find("new-title")).to eq(Product.first)

          expect(Product.friendly.find(second_product_slugs.first)).to eq(Product.second)
          expect(Product.friendly.find(second_product_slugs.second)).to eq(Product.second)
        end
      end
    end
  end

  describe "scoped" do
    # Check that normal scoped functions are working, both with and without locale
    # column on the slugs table.
    describe "base features" do
      it "detects scope column from belongs_to relation" do
        expect(Novel.friendly_id_config.scope_columns).to eq(["publisher_id", "novelist_id"])
      end

      it "detects scope column from explicit column name" do
        model_class = Class.new(ActiveRecord::Base) do
          extend Mobility
          translates :slug, :empty, type: :string

          self.abstract_class = true
          extend FriendlyId
          friendly_id :empty, use: [:scoped, :mobility], scope: :dummy
        end

        expect(model_class.friendly_id_config.scope_columns).to eq(["dummy"])
      end

      it "allows duplicate slugs outside scope" do
        novel1 = Novel.create! name: "a", novelist: Novelist.create!(name: "a")
        novel2 = Novel.create! name: "a", novelist: Novelist.create!(name: "b")
        expect(novel1.friendly_id).to eq(novel2.friendly_id)
      end

      it "does not allow duplicate slugs inside scope" do
        novelist = Novelist.create!(name: "a")
        novel1 = Novel.create! name: "a", novelist: novelist
        novel2 = Novel.create! name: "a", novelist: novelist
        expect(novel1.friendly_id).not_to eq(novel2.friendly_id)
      end

      it "applies scope with multiple columns" do
        novelist = Novelist.create! name: "a"
        publisher = Publisher.create! name: "b"
        novel1 = Novel.create! name: "c", novelist: novelist, publisher: publisher
        novel2 = Novel.create! name: "c", novelist: novelist, publisher: Publisher.create(name: "d")
        novel3 = Novel.create! name: "c", novelist: Novelist.create(name: "e"), publisher: publisher
        novel4 = Novel.create! name: "c", novelist: novelist, publisher: publisher
        expect(novel1.friendly_id).to eq(novel2.friendly_id)
        expect(novel2.friendly_id).to eq(novel3.friendly_id)
        expect(novel3.friendly_id).not_to eq(novel4.friendly_id)
      end

      it "allows a record to reuse its own slug" do
        record = Novel.create!(name: "a")
        old_id = record.friendly_id
        record.slug = nil
        record.save!

        expect(record.friendly_id).to eq(old_id)
      end
    end
  end
end

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
    end
  end

  context "base column is translated" do
    describe "#friendly_id" do
      it "sets friendly_id from base column in each locale" do
        article = Article.create!(:title => "War and Peace")
        I18n.with_locale(:es) { article.title = "Guerra y paz" }
        article.save!
        article = Article.first

        aggregate_failures do
          I18n.with_locale(:es) { expect(article.friendly_id).to eq("guerra-y-paz") }
          I18n.with_locale(:en) { expect(article.friendly_id).to eq("war-and-peace") }
        end
      end
    end
  end
end

# FriendlyId Mobility Changelog

## 1.0

### 1.0.4
* Convert field from symbol to string value when comparing with
  `mobility_attributes`
  ([#29](https://github.com/shioyama/friendly_id-mobility/pull/29)) thanks
  [mrbrdo](https://github.com/mrbrdo)

### 1.0.3
* Ensure regex does not trigger on changes unrelated to translated attributes
  ([#26](https://github.com/shioyama/friendly_id-mobility/pull/26)) thanks
  [kevynlebouille](https://github.com/kevynlebouille)!

### 1.0.2

* Depend on Mobility 1.0.1 to avoid need for `const_get`
  ([#25](https://github.com/shioyama/friendly_id-mobility/pull/25/files))

### 1.0.1

* Update friendly_id dependency ([#21](https://github.com/shioyama/friendly_id-mobility/pull/21))

### 1.0.0

* Release 1.0.0, compatible with Mobility 1.0
  ([#23](https://github.com/shioyama/friendly_id-mobility/pull/23))

## 0.5

### 0.5.5
* Bump friendly_id dependency version to 5.4.0
  ([#19](https://github.com/shioyama/friendly_id-mobility/pull/19/files))

### 0.5.4
* Generate all translated slugs when model is saved
  ([#12](https://github.com/shioyama/friendly_id-mobility/pull/12))

### 0.5.3
* Update gemspec to allow all Mobility versions < 1.0

### 0.5.2
* Emit warning when mobility is enabled with finders add-on

### 0.5.1
* Update Mobility dependency to >= 0.3, < 0.4

## 0.4

### 0.4.0
* Update Mobility dependency to 0.2.x

## 0.3

### 0.3.1
* Use `Mobility.query_method` instead of hard-coding `i18n` scope.

### 0.3.0
* Add support for history module ([#2](https://github.com/shioyama/friendly_id-mobility/pull/2))

## 0.2.0
* Add support for translated slugs and translated base attributes

## 0.1.0
* Mixin Mobility scope into FriendlyId scope





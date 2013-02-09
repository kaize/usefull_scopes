# UsefullScopes
[![Build Status](https://travis-ci.org/zzet/usefull_scopes.png?branch=testing)](https://travis-ci.org/zzet/usefull_scopes)
[![Coverage status](https://coveralls.io/repos/zzet/usefull_scopes/badge.png?branch=testing)](https://coveralls.io/repos/zzet/usefull_scopes)

This gem provides additional scopes for your ActiveRecord models.

## Installation

Add this line to your application's Gemfile:

    gem 'usefull_scopes'

Or install it yourself as:

    $ gem install usefull_scopes

## Usage

In order to use these scopes, we need to include `UsefullScopes` module in our model.

    class User < ActiveRecord::Base
      include UsefullScopes
    end

### Global scopes

<table>
  <tr>
    <th>Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>random</td>
    <td>Fetches a random record</td>
  </tr>
  <tr>
    <td>exclude</td>
    <td>Selects only those records who are not in a given array (you could also provide a single object as an argument)</td>
  </tr>
  <tr>
    <td>with</td>
    <td>Returns records, where attributes' values are corresponding to a given hash.</td>
  </tr>
  <tr>
    <td>without</td>
    <td>Returns records, where attributes' values are `NULL` or aren't equal to values from a given hash.</td>
  </tr>
</table>

### Scopes per attribute

These are the scopes created for each model's attribute.

<table>
  <tr>
    <th>Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>by_attribute</td>
    <td>Returns records ordered by `attribute` in descending order</td>
  </tr>
  <tr>
    <td>asc_by_attribute</td>
    <td>Returns records ordered by `attribute` in ascending order</td>
  </tr>
  <tr>
    <td>like_by_attribute</td>
    <td>Returns records, where attribute's value like a given term </td>
  </tr>
  <tr>
    <td>ilike_by_attribute</td>
    <td>Сase insensitive implementation of `like_by_attribute`</td>
  </tr>
</table>

### Example

Now, it is time to play with our model!

    User.create([{name: 'Mike'}, {name: 'Paul'}])

    user = User.random
    user.name
      => 'Mike'

    User.asc_by_name.map(&:name)
      => ['Mike', 'Paul']

    User.by_name.map(&:name)
      => ['Paul', 'Mike']

    users = User.with_name('Mike')
    users.map(&:name)
      => ['Mike']

    users = User.with(name: 'Mike')
      => SELECT "users".* FROM "users" WHERE ("users"."name" = 'Mike')
    users.map(&:name)
      => ['Mike']

    users = User.without(name: ['Mike', 'Paul'])
      => SELECT "users".* FROM "users" WHERE ("users"."name" NOT IN ('Mike','Paul'))
    users
      => []

    users = User.without(:name, :id)
      => SELECT "users".* FROM "users" WHERE ("users"."name" IS NULL AND "users"."id" IS NULL)
    users.count
      => 2

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

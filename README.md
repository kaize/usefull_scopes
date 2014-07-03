# UsefullScopes
[![Build Status](https://travis-ci.org/kaize/usefull_scopes.png?branch=master)](https://travis-ci.org/kaize/usefull_scopes)
[![Coverage
status](https://coveralls.io/repos/kaize/usefull_scopes/badge.png?branch=master)](https://coveralls.io/r/kaize/usefull_scopes)

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

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Credits

Maintained by kaize.

Thank you to all our amazing [contributors](http://github.com/kaize/usefull_scopes/contributors)!

## License

usefull_scopes is Copyright © 2012-2014 kaize. It is free
software, and may be redistributed under the terms specified in the LICENSE
file.

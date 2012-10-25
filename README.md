# UsefullScopes

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
    <td>Returns records, where attribute value like a given term </td>
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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
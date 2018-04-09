# Description
This module is to be used for anonymous checking user attributes in the MCommunity service provide at the University of Michigan

## Try it out
To try the module out you may clone the repo and run the ldaptest.rb script
```ruby
ruby .\ldaptest.rb
```
Requirements:
* Ruby at least 2.0.0
* Gem 'net-ldap' ~> '0.16.1'
> Install by running the following command at your command prompt_for_action
```bash
gem install net-ldap
```

* Time to try it out


## For use in a Rails project:
Install the gem net-ldap by adding the follwing line to your GEMFILE

> *The Net::LDAP (aka net-ldap) gem before 0.16.0 for Ruby has Missing SSL Certificate Validation.*

```
gem 'net-ldap', '~> 0.16.1'
```
Include the module in your class
```
include Ldap_Record
```

## Methods available
get_simple_name: returns the Display Name
```
Ldap_Record.get_simple_name(uniqname = nil)
```
get_dept: returns the users Department_name
```
Ldap_Record.get_dept(uniqname = nil)
```
get_email: returns the users email address
```
Ldap_Record.get_email(uniqname = nil)
```
is_member_of_group?: returns true/false if uniqname is a member of the specified group
```
Ldap_Record.is_member_of_group?(uid = nil, group_name = nil)
```
get_email_distribution_list: Returns the list of emails that are associated to a group.
```
Ldap_Record.get_email_distribution_list(group_name = nil)
```

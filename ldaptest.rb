#!/usr/bin/env ruby

require_relative 'ldapable'
class Ldaptest

  include Ldapable

  def initialize(name=nil)
    @uid = name
    @group_uid = nil
  end

  def reset_uid
    puts "Enter a valid UID"
    @uid = gets.chomp.to_s
    return "UID is now set to #{@uid}"
  end

  def reset_group_uid
    puts "Enter a valid group_name"
    @group_uid = gets.chomp.to_s
    return "group_name is now set to #{@group_uid}"
  end

  def result_box(answer)
    print "\e[2J\e[f"
    2.times { puts " " }
    puts "Your Results"
    puts "------------------------------------------------------"
    puts " " 
    puts "#{answer}"
    puts " "
    puts "------------------------------------------------------"
    2.times { puts " " }
  end

  def timestamp
    Time.now.asctime
  end

  def prompt_for_action
    puts "Hello, what would you like to do?"
    puts "================================="
    puts "0: set new uid" 
    puts "1: set new group_uid" 
    puts "2: check current UID and group_uid"
    puts "3: what time is it?"
    puts "4: ldap lookup"
    puts "5: ldap group-name lookup"
    puts "6: check if uid is member of a group"
    puts "9: exit"

    case gets.chomp.to_i
    when 0 then result_box(reset_uid)
    when 1 then result_box(reset_group_uid)
    when 2 then result_box("current values:\n UID set to #{@uid}\n group_uid set to #{@group_uid}")
    when 3 then result_box(timestamp)
    when 4 then result_box(Ldapable.get_simple_name(@uid))
    when 5 then result_box(Ldapable.get_email_distribution_list(@group_uid))
    when 6 then result_box(Ldapable.is_member_of_group(@uid,@group_uid))
    when 9 then puts "you chose exit!"
      throw(:done)
    else
      puts "====> Please type 0,1,2,3,4,5,6 or 9 only"
    end
  end

  def run
    catch(:done) do
      loop do
        prompt_for_action
      end
    end
  end
end
print "\e[2J\e[f"
print "Enter a valid UID=> "
name = gets.chomp.to_s
program1 = Ldaptest.new(name).run

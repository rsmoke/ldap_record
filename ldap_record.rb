module Ldap_Record
  # this was developed using guidence from this gist:
  # https://gist.githubusercontent.com/jeffjohnson9046/7012167/raw/86587b9637ddc2ece7a42df774980fa9c0aac9b3/ruby-ldap-sample.rb

  require 'rubygems'
  require 'net/ldap'

  #######################################################################################################################
  ## HELPER/UTILITY METHOD
  ##   This method interprets the response/return code from an LDAP bind operation (bind, search, add, modify, rename,
  ##   delete).  This method isn't necessarily complete, but it's a good starting point for handling the response codes
  ##   from an LDAP bind operation.
  ##
  ##   Additional details for the get_operation_result method can be found here:
  ##   http://net-ldap.rubyforge.org/Net/LDAP.html#method-i-get_operation_result
  ########################################################################################################################
  def self.get_ldap_response(ldap)
    msg = "Response Code: #{ ldap.get_operation_result.code }, Message: #{ ldap.get_operation_result.message }"
    raise msg unless ldap.get_operation_result.code == 0
  end

  #######################################################################################################################
  # SET UP LDAP CONNECTION
  # Setting up a connection to the LDAP server using .new() does not actually send any network traffic to the LDAP
  # server.  When you call an operation on ldap (e.g. add or search), .bind is called implicitly.  *That's* when the
  # connection is made to the LDAP server.  This means that each operation called on the ldap object will create its own
  # network connection to the LDAP server.
  #######################################################################################################################
  def self.ldap_connection
    ldap = Net::LDAP.new  host: "ldap.umich.edu", # your LDAP host name or IP goes here,
      port:"389", # your LDAP host port goes here,
      base: "dc=umich,dc=edu", # the base of your AD tree goes here,
      auth: {
        :method => :anonymous
      }
  end

  # GET THE DISPLAY NAME FOR A SINGLE USER
  def Ldap_Record.get_simple_name(uniqname = nil)
    ldap = ldap_connection
    search_param = uniqname # the AD account goes here
    result_attrs = ["displayName"] # Whatever you want to bring back in your result set goes here
    # Build filter
    search_filter = Net::LDAP::Filter.eq("uid", search_param)
    # Execute search
    ldap.search(filter: search_filter, attributes: result_attrs) { |item|
      return item.displayName.first
    }
    get_ldap_response(ldap)
  end

  # GET THE PRIMARY DEPARTMENT FOR A SINGLE USER
  def Ldap_Record.get_dept(uniqname = nil)
    ldap = ldap_connection
    search_param = uniqname # the AD account goes here
    result_attrs = ["umichPostalAddressData"] # Whatever you want to bring back in your result set goes here
    # Build filter
    search_filter = Net::LDAP::Filter.eq("uid", search_param)
    # Execute search
    ldap.search(filter: search_filter, attributes: result_attrs) { |item|
      return dept_name = item.umichpostaladdressdata.first.split("}:{").first.split("=")[1] unless item.umichpostaladdressdata.first.nil?
    }
    get_ldap_response(ldap)
  end

  # GET THE E-MAIL ADDRESS FOR A SINGLE USER
  def Ldap_Record.get_email(uniqname = nil)
    ldap = ldap_connection
    search_param = uniqname # the AD account goes here
    result_attrs = ["mail"] # Whatever you want to bring back in your result set goes here
    # Build filter
    search_filter = Net::LDAP::Filter.eq("uid", search_param)
    # Execute search
    ldap.search(filter: search_filter, attributes: result_attrs) { |item|
      return item.mail.first
    }
    get_ldap_response(ldap)
  end

  # ---------------------------------------------------------------------------------------------------------------------
  # Check if the UID is a member of an LDAP group. This function returns TRUE
  # if uid passed in is a member of group_name passed in. Otherwise it will
  # return false.
  def Ldap_Record.is_member_of_group?(uid = nil, group_name = nil)
    ldap = ldap_connection
    # GET THE MEMBERS OF AN E-MAIL DISTRIBUTION LIST
    search_param = group_name # the name of the distribution list you're looking for goes here
    result_attrs = ["member"]
    # Build filter
    search_filter = Net::LDAP::Filter.eq("cn", search_param)
    group_filter = Net::LDAP::Filter.eq("objectClass", "group")
    composite_filter = Net::LDAP::Filter.join(search_filter, group_filter)
    # Execute search, extracting the AD account name from each member of the distribution list
    ldap.search(filter: composite_filter, attributes: result_attrs) do |item|
      item.member.each do |entry|
        if entry.split(",").first.split("=")[1] == uid
          return true
        end
      end
    end
    return FALSE
    get_ldap_response(ldap)
  end

  # ---------------------------------------------------------------------------------------------------------------------
  # Get the Name email and members of an LDAP group as a hash
  def Ldap_Record.get_email_distribution_list(group_name = nil)
    ldap = ldap_connection
    result_hash = {}
    member_hash = {}
    # GET THE MEMBERS OF AN E-MAIL DISTRIBUTION LIST
    search_param = group_name # the name of the distribution list you're looking for goes here
    result_attrs = ["cn", "umichGroupEmail", "member"]
    # Build filter
    search_filter = Net::LDAP::Filter.eq("cn", search_param)
    group_filter = Net::LDAP::Filter.eq("objectClass", "group")
    composite_filter = Net::LDAP::Filter.join(search_filter, group_filter)
    # Execute search, extracting the AD account name from each member of the distribution list
    ldap.search(filter: composite_filter, attributes: result_attrs) do |item|
      result_hash["group_name"] = item.cn.first
      result_hash["group_email"] = item.umichGroupEmail.first
      result_hash["members"] = item.member
    end
    return result_hash
    get_ldap_response(ldap)
  end
end

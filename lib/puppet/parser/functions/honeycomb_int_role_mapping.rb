module Puppet::Parser::Functions
  newfunction(:honeycomb_int_role_mapping, :type => :rvalue, :doc => "Convert Honeycomb role mapping from kernel nic name (eth1) to VPP name (GigabitEthernet0/7/0).") do |arg|
    mapping_list = arg[0]
    mapping_list.map! do |item|
      mapping = item.split(':')
      unless mapping.length == 2
        raise Puppet::ParseError, "Invalid physnet mapping format: #{item}. Expecting 'interface_name:role_name'"
      end
      if defined? call_function
        vpp_int = call_function('hiera', [mapping[0]])
      else
        vpp_int = function_hiera([mapping[0]])
      end
      if vpp_int.to_s.strip.empty?
        raise Puppet::ParseError, "VPP interface mapped to #{mapping[0]} is not found."
      end
      vpp_int+':'+mapping[1]
    end
    return mapping_list
  end
end

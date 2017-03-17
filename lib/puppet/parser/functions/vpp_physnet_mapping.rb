module Puppet::Parser::Functions
  newfunction(:vpp_physnet_mapping, :type => :rvalue, :doc => "Convert VPP ML2 physnet mapping from kernel nic name (eth1) to VPP name (GigabitEthernet0/7/0).") do |arg|
    mapping_list = arg[0]
    mapping_list.map! do |item|
      mapping = item.split(':')
      unless mapping.length == 2
        raise Puppet::ParseError, "Invalid physnet mapping format: #{item}. Expecting 'physnet:interface_name'"
      end
      if defined? call_function
        vpp_int = call_function('hiera', [mapping[1]])
      else
        vpp_int = function_hiera([mapping[1]])
      end
      if vpp_int.to_s.strip.empty?
        raise Puppet::ParseError, "VPP interface mapped to #{mapping[1]} is not found."
      end
      mapping[0]+':'+vpp_int
    end
    return mapping_list.join(',')
  end
end

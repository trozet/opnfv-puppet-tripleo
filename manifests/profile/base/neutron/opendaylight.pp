# Copyright 2016 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: tripleo::profile::base::neutron::opendaylight
#
# OpenDaylight Neutron profile for TripleO
#
# === Parameters
#
# [*step*]
#   (Optional) The current step of the deployment
#   Defaults to hiera('step')
#
# [*odl_api_ips*]
#   (Optional) List of OpenStack Controller IPs for ODL API
#   Defaults to hiera('opendaylight_api_node_ips')
#
# [*node_name*]
#   (Optional) The short hostname of node
#   Defaults to hiera('bootstack_nodeid')
#
# [*vpp_routing*]
#   (Optional) Whether to configure vpp routing node
#   Defaults to false
#
class tripleo::profile::base::neutron::opendaylight (
  $step         = hiera('step'),
  $odl_api_ips  = hiera('opendaylight_api_node_ips'),
  $node_name    = hiera('bootstack_nodeid'),
  $vpp_routing  = false
) {

  if $step >= 1 {
    if $vpp_routing {
      $compute_nodes = hiera("nova_compute_short_node_names", [])
      if empty($compute_nodes) {
        fail('No compute nodes found')
      }
      $vpp_routing_node = "${compute_nodes[0]}.$::domain"
    } else {
      $vpp_routing_node = undef
    }

    if empty($odl_api_ips) {
      fail('No IPs assigned to OpenDaylight Api Service')
    } elsif size($odl_api_ips) == 2 {
      fail('2 node OpenDaylight deployments are unsupported.  Use 1 or greater than 2')
    } elsif size($odl_api_ips) > 2 {
      $node_string = split($node_name, '-')
      $ha_node_index = $node_string[-1] + 1
      class { '::opendaylight':
        enable_ha     => true,
        ha_node_ips   => $odl_api_ips,
        ha_node_index => $ha_node_index,
        vpp_routing_node => $vpp_routing_node,
      }
    } else {
      class { '::opendaylight':
        vpp_routing_node => $vpp_routing_node,
      }
    }
  }
}

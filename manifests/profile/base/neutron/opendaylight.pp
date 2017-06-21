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
class tripleo::profile::base::neutron::opendaylight (
  $step         = hiera('step'),
  $odl_api_ips  = hiera('opendaylight_api_node_ips'),
  $node_name    = hiera('bootstack_nodeid')
) {

  if $step == 1 {
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
      }
    } else {
      include ::opendaylight
      if $step == 2 {
        if hiera('opendaylight::extra_features') =~ /odl-ovsdb-sfc-rest/ {
          $opendaylight_controller_ip = $odl_api_ips[0]
          $opendaylight_port = hiera('opendaylight::odl_rest_port')
          $odl_username = hiera('opendaylight::username')
          $odl_password = hiera('opendaylight::password')
          $netvirt_coexist_url = "http://${opendaylight_controller_ip}:${opendaylight_port}/restconf/config/netvirt-providers-config:netvirt-providers-config"
          $sfc_post_body = "{ 'sfc-of-renderer-config' : { 'sfc-of-table-offset' : 150, 'sfc-of-app-egress-table-offset' : 11 }}"
          exec { 'Coexistence table offsets for netvirt':
            command   => "curl -o /dev/null --fail --silent -u ${odl_username}:${odl_password} ${netvirt_coexist_url} -i -H 'Content-Type: application/json' --data \'${netvirt_post_body}\' -X PUT",
            tries     => 5,
            try_sleep => 30,
            path      => '/usr/sbin:/usr/bin:/sbin:/bin',
          } ->
          # Coexist for SFC
          exec { 'Coexistence table offsets for sfc':
            command   => "curl -o /dev/null --fail --silent -u ${odl_username}:${odl_password} ${sfc_coexist_url} -i -H 'Content-Type: application/json' --data \'${sfc_post_body}\' -X PUT",
            tries     => 5,
            try_sleep => 30,
            path      => '/usr/sbin:/usr/bin:/sbin:/bin',
          }
        }
      }
    }
  }
}

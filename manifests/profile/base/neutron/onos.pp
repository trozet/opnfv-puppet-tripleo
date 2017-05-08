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
# == Class: tripleo::profile::base::neutron::onos
#
# ONOS Neutron profile for TripleO
#
# === Parameters
#
# [*step*]
#   (Optional) The current step of the deployment
#   Defaults to hiera('step')
#
# [*onos_api_ips*]
#   (Optional) List of OpenStack Controller IPs for ONOS API
#   Defaults to hiera('onos_api_node_ips')
#  $onos_api_ips  = hiera('aodh_api_node_ips'),
#
# [*node_name*]
#   (Optional) The short hostname of node
#   Defaults to hiera('bootstack_nodeid')
#
class tripleo::profile::base::neutron::onos (
  $step         = hiera('step'),
  $onos_api_ips  = hiera('onos_api_node_ips'),
  $node_name    = hiera('bootstack_nodeid')
) {

  if $step >= 1 {
    if empty($onos_api_ips) {
      fail('No IPs assigned to onos Api Service')
    } elsif size($onos_api_ips) == 2 {
      fail('2 node onos deployments are unsupported.  Use 1 or greater than 2')
    } elsif size($onos_api_ips) > 2 {
      $node_string = split($node_name, '-')
      $ha_node_index = $node_string[-1] + 1
      class { '::onos':
        controllers_ip   => $onos_api_ips,
      }
    } else {
      include ::onos
    }
  }
}

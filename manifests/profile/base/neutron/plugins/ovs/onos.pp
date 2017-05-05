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
# == Class: tripleo::profile::base::neutron::plugins::ovs::onos
#
# ONOS Neutron OVS profile for TripleO
#
# === Parameters
#
#
# [*onos_api_ips*]
#   (Optional) List of OpenStack Controller IPs for ONOS API
#   Defaults to hiera('onos_api_node_ips')
#
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to hiera('step')
#
class tripleo::profile::base::neutron::plugins::ovs::onos (
  $onos_api_ips   = hiera('onos_api_node_ips'),
  $step          = hiera('step'),
) {

  if $step >= 4 {
    if empty($onos_api_ips) { fail('No IPs assigned to ONOS Api Service') }


    # Build URL to check if onos is up before connecting OVS
    class { '::onos::ovs':
         manager_ip  => $onos_api_ips[0],
    }
  }
}

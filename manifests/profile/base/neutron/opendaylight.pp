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
  if hiera('vpp_enabled', False) and ('odl-router_v2' in hiera('neutron::service_plugins', [])) {
    file { 'org.opendaylight.groupbasedpolicy.renderer.vpp.startup.cfg':
      ensure => file,
      path   => '/opt/opendaylight/etc/org.opendaylight.groupbasedpolicy.renderer.vpp.startup.cfg',
      owner  => 'odl',
      group  => 'odl',
    }
    $odl_bind_ip = hiera('opendaylight::odl_bind_ip')
    file_line { 'odl-ip':
      path  => '/opt/opendaylight/etc/org.opendaylight.groupbasedpolicy.renderer.vpp.startup.cfg',
      line  => "odl.ip = ${odl_bind_ip}",
      match => '^odl.ip =.*$',
    }
    file_line { 'gbp.lisp.enabled':
      path  => '/opt/opendaylight/etc/org.opendaylight.groupbasedpolicy.renderer.vpp.startup.cfg',
      line  => "gbp.lisp.enabled = true",
    }
    file_line { 'vpp.lisp.mapregister.enabled':
      path  => '/opt/opendaylight/etc/org.opendaylight.groupbasedpolicy.renderer.vpp.startup.cfg',
      line  => "vpp.lisp.mapregister.enabled = true",
    }
    file_line { 'vpp.l3.flat.enabled':
      path  => '/opt/opendaylight/etc/org.opendaylight.groupbasedpolicy.renderer.vpp.startup.cfg',
      line  => "vpp.l3.flat.enabled = true",
    }
    file { '/opt/opendaylight/etc/custom.properties':
      ensure => file,
      path   => '/opt/opendaylight/etc/custom.properties',
      owner  => 'odl',
      group  => 'odl',
    }
    file_line { 'lisp.authEnabled':
      path  => '/opt/opendaylight/etc/custom.properties',
      line  => "lisp.authEnabled = false",
    }
  }
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
    }
  }
}

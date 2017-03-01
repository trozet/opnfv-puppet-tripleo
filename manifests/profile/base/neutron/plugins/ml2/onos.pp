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
# == Class: tripleo::profile::base::neutron::plugins::ml2::onos
#
# OpenDaylight ML2 Neutron profile for TripleO
#
# === Parameters
#
# [*odl_port*]
#   (Optional) Port to use for OpenDaylight
#   Defaults to hiera('onos::odl_rest_port')
#
# [*odl_username*]
#   (Optional) Username to configure for OpenDaylight
#   Defaults to 'admin'
#
# [*odl_password*]
#   (Optional) Password to configure for OpenDaylight
#   Defaults to 'admin'
#
# [*odl_url_ip*]
#   (Optional) Virtual IP address for ODL Api Service
#   Defaults to hiera('onos_api_vip')
#
# [*conn_proto*]
#   (Optional) Protocol to use to for ODL REST access
#   Defaults to hiera('onos::nb_connection_protocol')
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to hiera('step')
#
class tripleo::profile::base::neutron::plugins::ml2::onos (
  $onos_url_ip   = hiera('aodh_api_node_ips'),
  $step         = hiera('step'),
) {

  if $step >= 4 {

    class { '::onos::start':
         onos_ip => $onos_url_ip,
    }
  }
}

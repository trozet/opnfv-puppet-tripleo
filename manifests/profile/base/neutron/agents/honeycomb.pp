# Copyright 2017 Red Hat, Inc.
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
# == Class: tripleo::profile::base::neutron::agents::honeycomb
#
# Honeycomb Neutron agent profile
#
# Honeycomb is a java-based agent that runs on the same host as a VPP
# instance, and exposes yang models via netconf or restconf to allow
# remote management of that VPP instance.
#
# === Parameters
#
# [*step*]
#   (Optional) The current step of the deployment
#   Defaults to hiera('step')
#
# [*interface_role_mapping*]
#   (Optional) VPP interface role mapping, note that the interface name
#   specified here is a kernel interface name that is bound to VPP.
#   Defaults to []
#
class tripleo::profile::base::neutron::agents::honeycomb (
  $step = hiera('step'),
  $interface_role_mapping = [],
) {
  if $step >= 4 {
    class { '::fdio::honeycomb':
      interface_role_map => honeycomb_int_role_mapping($interface_role_mapping),
    }
  }
}

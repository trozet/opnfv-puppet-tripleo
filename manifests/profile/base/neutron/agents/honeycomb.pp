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
class tripleo::profile::base::neutron::agents::honeycomb (
  $step = hiera('step'),
) {
  if $step >= 4 {
    if $hostname =~ /.*controller.*/ {
      class { '::fdio::honeycomb':
        notify => Service['opendaylight']
      }
    } else {
      include ::fdio::honeycomb
    }
  }
}

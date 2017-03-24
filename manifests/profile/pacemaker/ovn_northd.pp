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
# == Class: tripleo::profile::pacemaker::neutron::plugins::ml2::ovn
#
# Neutron ML2 driver Pacemaker HA profile for tripleo
#
# === Parameters
#
# [*pacemaker_master*]
#   (Optional) The hostname of the pacemaker master
#   Defaults to hiera('ovn_dbs_short_bootstrap_node_name')
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to hiera('step')
#
# [*pcs_tries*]
#  (Optional) The number of times pcs commands should be retried.
#   Defaults to hiera('pcs_tries', 20)
#
# [*ovn_dbs_vip*]
#   (Optional) The OVN database virtual IP to be managed by the pacemaker.
#   Defaults to hiera('ovn_dbs_vip')
#
class tripleo::profile::pacemaker::ovn_northd (
  $pacemaker_master = hiera('bootstack_nodeid'),
  $step             = hiera('step'),
  $pcs_tries        = hiera('pcs_tries', 20),
  $ovn_dbs_vip      = hiera('ovn_dbs_vip'),
) {

  if $step >= 2 {
    pacemaker::property { 'ovn-northd-node-property':
      property => 'ovn-northd-role',
      value    => true,
      tries    => $pcs_tries,
      node     => $::hostname,
    }
  }

  # We want the config file to be created on all the cluster nodes,
  # so that when a slave becomes master, it can start ovn-northd.
  if $step == 4 and $::osfamily == 'RedHat' {
    augeas { 'sysconfig-ovn-northd':
      context =>  '/files/etc/sysconfig/ovn-northd',
      changes =>  "set OVN_NORTHD_OPTS '\"--db-nb-addr=${ovn_dbs_vip} --db-sb-addr=${ovn_dbs_vip} \
--db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes --ovn-manage-ovsdb=no\"'",
    }
  }

  if $step >= 5 and downcase($::hostname) == $pacemaker_master {
    $ovndb_servers_resource_name = 'ovndb_servers'
    $ovn_northd_resource_name    = 'ovn-northd'
    $ovndb_servers_ocf_name      = 'ovn:ovndb-servers'
    $ovndb_vip_resource_name     = "ip-${ovn_dbs_vip}"
    $northd_db_params_path = '/etc/sysconfig/ovn-northd'

    pacemaker::resource::ip { "${ovndb_vip_resource_name}":
      ip_address   => "${ovn_dbs_vip}",
      cidr_netmask => 24,
    }

    pacemaker::resource::ocf { "${ovndb_servers_resource_name}":
      ocf_agent_name  => "${ovndb_servers_ocf_name}",
      master_params   => '',
      resource_params => "master_ip=${ovn_dbs_vip}",
      meta_params     => 'notify=true'
    }

    pacemaker::resource::service { "$ovn_northd_resource_name":
      op_params     => 'start timeout=200s stop timeout=200s',
      tries         => $pcs_tries,
      location_rule => {
        resource_discovery => 'exclusive',
        score              => 0,
        expression         => ['ovn-northd-role eq true'],
      },
    }

    pacemaker::constraint::base { "${ovndb_vip_resource_name}-then-${ovndb_servers_resource_name}":
      constraint_type => 'order',
      first_resource  => "${ovndb_vip_resource_name}",
      second_resource => "${ovndb_servers_resource_name}-master",
      first_action    => 'start',
      second_action   => 'start',
      require         => [Pacemaker::Resource::Ip["${ovndb_vip_resource_name}"],
                          Pacemaker::Resource::Ocf["${ovndb_servers_resource_name}"]],
    }

    pacemaker::constraint::base { "${ovndb_servers_resource_name}-then-${ovn_northd_resource_name}":
      constraint_type => 'order',
      first_resource  => "${ovndb_servers_resource_name}-master",
      second_resource => "${ovn_northd_resource_name}",
      first_action    => 'start',
      second_action   => 'start',
      require         => [Pacemaker::Resource::Ocf["${ovndb_servers_resource_name}"],
                          Pacemaker::Resource::Service["${ovn_northd_resource_name}"]],
    }

    #pacemaker::constraint::colocation { "${ovndb_vip_resource_name}-with-${ovndb_servers_resource_name}-INFINITY":
    #  source       => "${ovndb_vip_resource_name}",
    #  target       => "${ovndb_servers_resource_name}-master",
    #  master_slave => true,
    #  score        => 'INFINITY',
    #  require      =>  [Pacemaker::Resource::Ocf["${ovndb_servers_resource_name}"],
    #                    Pacemaker::Resource::Ip["${ovndb_vip_resource_name}"]],
    #}

    #pacemaker::constraint::colocation { "${ovndb_vip_resource_name}-with-${ovn_northd_resource_name}-INFINITY":
    #  source  => "${ovndb_vip_resource_name}",
    #  target  => "${ovn_northd_resource_name}",
    #  score   => 'INFINITY',
    #  require => [Pacemaker::Resource::Service["${ovn_northd_resource_name}"],
    #              Pacemaker::Resource::Ip["${ovndb_vip_resource_name}"]],
    #}
  }
}

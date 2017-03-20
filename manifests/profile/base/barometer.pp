#
# == Class: tripeo::profile::base::barometer
#
# Barometer service profile for tripleo
# == Parameters
#
# [*step]
#    The current step of the deployment
#

class tripleo::profile::base::barometer (
  $step	= hiera('step'),
) {
  if $step >= 4 {
    include ::barometer::rdt
    include ::barometer::collectd
  }
}


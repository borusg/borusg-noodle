# Class: noodle
# ===========================
#
# Install Noodle and its dependencies
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'noodle':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Mark Plaksin <happy@mcplaksin.org>
#
# Copyright
# ---------
#
# Copyright 2017 Mark Plaksin, unless otherwise noted.
#
class noodle (
  $noodle_install_dir      = '/usr/local/noodle',
  $noodle_user             = 'noodle',
  $noodle_group            = 'noodle',
  $noodle_repo             = 'https://github.com/happymcplaksin/noodle.git',
  $noodle_revision         = 'master',
  $noodle_environment      = 'production',
  #
  $manage_es               = true,
  $es_hostname             = 'localhost',
  $es_port                 = 9200,
  $es_install_java         = true,
  $es_manage_repo          = true,
  $es_java_package         = undef,
  $es_repo_version         = '5.x',
  $es_instance_name        = 'noodle',
  $es_restart_on_change    = true,
  $es_java_xmx             = '-Xmx64m',
  $es_java_xms             = '-Xms32m',
  #
  # If manage_ruby is false, this module assumes you have done what's
  # required to make the ruby::bundle class work :)
  $manage_ruby             = true,
  $ruby_version            = undef,
  $rubygems_update         = false,
  $ruby_package            = undef,
  $rubygems_package        = undef,
  $rubydev_ensure          = 'installed',
  $rubydev_packages        = undef,
  $rubydev_rake_ensure     = 'installed',
  $rubydev_rake_package    = undef,
  $rubydev_bundler_ensure  = 'installed',
  $rubydev_bundler_package = undef,
  # Want Kibana with that?
  $manage_kibana           = true,
  $kibana_manage_repo      = true,
  $kibana_version          = 'latest',
  $kibana_host             = $::fqdn,
  $kibana_port             = '5601',
  # Want Grafana with that?
  $manage_grafana          = true,
  $grafana_manage_repo     = true,
  $grafana_version         = '4.2.0',
) {
  # Make group and user
  group{$noodle_group:
    ensure => 'present',
    system => true,
  } ->
  user{$noodle_user:
    ensure => 'present',
    home   => $noodle_install_dir,
    system => true,
  } ->
  file{ $noodle_install_dir:
    ensure => 'directory',
    owner  => $noodle_user,
    group  => $noodle_group,
  } ->
  # Fetch the code
  vcsrepo {$noodle_install_dir:
    ensure   => 'present',
    provider => 'git',
    source   => $noodle_repo,
    user     => $noodle_user,
    group    => $noodle_group,
    revision => $noodle_revision,
  } ->
  # Install dependencies
  ruby::bundle{'noodle':
    command   => 'install',
    option    => '--path=vendor/bundle',
    cwd       => $noodle_install_dir,
    rails_env => $noodle_environment,
    user      => $noodle_user,
    group     => $noodle_group,
    creates   => "${noodle_dir}/.bundle/config",
  }

  file{"${noodle_install_dir}/noodle.systemd":
    content => template('noodle/systemd.erb')
  } ->
  ::systemd::unit_file { 'noodle.service':
    source => "${noodle_install_dir}/noodle.systemd",
  } ->
  service{ 'noodle':
    ensure => 'running',
    enable => true,
  }

  if ($manage_kibana == true) {
    class { 'kibana':
      ensure          => $kibana_version,
      manage_repo     => $kibana_manage_repo,
      config          => {
        'server.host' => $kibana_host,
        'server.port' => $kibana_port,
      }
    }
  }

  if ($manage_grafana == true) {
    class { 'grafana':
      manage_package_repo => $grafana_manage_repo,
      version             => $grafana_version,
    }
  }

  if ($manage_es == true) {
    class { 'elasticsearch':
      java_install      => $es_install_java,
      java_package      => $es_java_package,
      manage_repo       => $es_manage_repo,
      repo_version      => $es_repo_version,
      restart_on_change => $es_restart_on_change,
      jvm_options       => [$es_java_xmx,$es_java_xms],
    }
    elasticsearch::instance { $es_instance_name: }
  }

  if ($manage_ruby == true) {
    class { 'ruby':
      version          => $ruby_version,
      ruby_package     => $ruby_package,
      rubygems_package => $rubygems_package,
      rubygems_update  => $rubygems_update,

    }
    class { 'ruby::dev':
      ensure            => $rubydev_ensure,
      ruby_dev_packages => $rubydev_packages,
      rake_ensure       => $rubydev_rake_ensure,
      rake_package      => $rubydev_rake_package,
      bundler_ensure    => $rubydev_bundler_ensure,
      bundler_package   => $rubydev_bundler_package,
    }
  }
}

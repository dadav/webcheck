# Wait for internet and then install vim

wait_for_connection { 'google.de:80':
  timeout     => 3600,
  retry_sleep => 10,
}
~> package { 'vim':
  ensure => installed,
}

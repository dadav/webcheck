# Wait for an application to be available, then start a service
wait_for_response { 'https://myapp.example/version':
  expected_status_codes => [200],
  expected_json         => {
    'status' => 'running',
  },
  timeout               => 3600,
  retry_sleep           => 10,
}
->service { 'foobar':
  ensure => running,
}

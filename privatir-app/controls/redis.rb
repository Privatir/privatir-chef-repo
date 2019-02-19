# Redis configuration

control 'redis-1.0' do # A unique ID for this control
  impact 0.7 # The criticality, if this control fails.
  title 'Verify Redis configuration.'
  describe(group('redis')) do
    it { should exist }
  end
  describe(user('redis')) do
    it { should exist }
  end
  describe(port(6379)) do
    it { should be_listening }
    its('processes') { should include 'redis-server' }
  end
end

# Hostname configuration
control 'hostname-1.0' do # A unique ID for this control
  impact 0.7 # The criticality, if this control fails.
  title 'Verify hostname.'
  describe etc_hosts do
    its('primary_name') { should include 'privatir-api-ubuntu-1604' }
  end
end

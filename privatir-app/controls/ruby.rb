# Ruby configuration
control 'ruby-1.0' do # A unique ID for this control
  impact 0.7 # The criticality, if this control fails.
  title 'Verify ruby configuration.'
  describe command('su - deployer -c "ruby -v"') do
    its('stdout') { should match 'ruby 2.6.1' }
  end
end

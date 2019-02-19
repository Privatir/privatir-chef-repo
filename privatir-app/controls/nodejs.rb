# Nodejs configuration

control 'nodejs-1.0' do # A unique ID for this control
  impact 0.7 # The criticality, if this control fails.
  title 'Verify Nodejs configuration.'

  describe command('node -v') do
    its('stdout') { should match 'v10.15.1' }
  end

  describe command('npm version') do
    its('stdout') { should match(/^(.*?)+ npm: (.*?)+/) }
  end
end

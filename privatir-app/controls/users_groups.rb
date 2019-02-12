# User and Group permissions & configuration
control 'users-1.0' do # A unique ID for this control
  impact 0.7 # The criticality, if this control fails.
  title 'Verify the creation of users, groups, file permissions and ownership.'

  describe(groups.where { name == 'www-data' }) do
    it { should exist }
  end

  describe(user('privatir')) do
    it { should exist }
    its('group') { should eq 'www-data' }
  end

  describe(user('nginx')) do
    it { should exist }
    its('group') { should eq 'www-data' }
  end

  describe(user('deployer')) do
    it { should exist }
    its('group') { should eq 'deployer' }
    its('groups') { should include 'deployer' }
    its('groups') { should include 'sudo' }
    its('groups') { should include 'sysadmin' }
    its('groups') { should include 'www-data' }
  end
end

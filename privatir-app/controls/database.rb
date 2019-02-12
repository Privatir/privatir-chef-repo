# Postgres configuration
control 'postgres-1.0' do # A unique ID for this control
  impact 0.7 # The criticality, if this control fails.
  title 'Verify Postgresql configuration.'
  describe(postgres_conf) do
    its('max_connections') { should cmp '300' }
  end
  describe(postgres_hba_conf.where { database == 'privatir' }) do
    its('user') { should cmp 'privatir' }
  end
  describe(postgres_hba_conf.where { database == 'privatir_dev' }) do
    its('user') { should cmp 'privatir' }
  end
end

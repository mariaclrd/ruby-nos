require_relative '../../environment'

Sequel.migration do
  change do
    create_table :agents do
      String     :agent_uuid,       :primary_key=>true
    end
  end
end
Sequel.migration do

  up do
    rename_column(:settings, :key, :name, :unique => true)
    rename_column(:settings, :group_key, :group)

    drop_column(:settings, :language_key)
    drop_column(:settings, :language_group_key)

    # Ensure the identifiers are unique
    #add_index(:settings, :key, :unique => true)

    # Update the settings
    Zen::Database.handle[:settings].all.each do |row|
      name  = row[:name].split('.').last
      group = row[:group].split('.').last

      Zen::Database.handle[:settings].filter(:id => row[:id])
        .update(:name => name, :group => group)
    end
  end
  
  down do
    rename_column(:settings, :identifier      , :key)
    rename_column(:settings, :group_identifier, :group_key)

    add_column(:settings, :language_key      , String)
    add_column(:settings, :language_group_key, String)
  end

end

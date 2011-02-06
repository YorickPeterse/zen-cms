Sequel.migration do

  up do
    create_table :custom_field_groups do
      primary_key :id
      
      String :name,         :null => false
      String :description,  :text => true
    end
    
    create_table :custom_fields do
      primary_key :id

      String    :name,                :null => false
      String    :slug,                :null => false, :unique => true
      String    :description,         :text => true
      Integer   :sort_order,          :null => false, :default  => 0
      Enum      :type,                :null => false, :elements => ['textbox', 'textarea', 'radio', 'checkbox', 'date', 'select', 'select_multiple'], :default => 'textbox'
      Enum      :format,              :null => false, :elements => ['plain', 'html', 'textile', 'markdown'], :default => 'plain'
      String    :possible_values,     :text => true
      
      # Custom field settings
      TrueClass :required,            :null => false, :default => false
      TrueClass :visual_editor,       :null => false, :default => true
      Integer   :textarea_rows,       :null => false, :default => 6
      Integer   :text_limit,          :null => false, :default => 255
      
      foreign_key :custom_field_group_id, :custom_field_groups, :on_delete => :cascade, :on_update => :cascade, :key => :id
    end
    
    create_table :custom_field_groups_sections do
      foreign_key :custom_field_group_id, :custom_field_groups, :on_delete => :cascade, :on_update => :cascade, :key => :id
      foreign_key :section_id,            :sections,            :on_delete => :cascade, :on_update => :cascade, :key => :id
    end
    
    create_table :custom_field_values do
      primary_key :id
    
      String  :value, :text  => true
      
      foreign_key :custom_field_id,  :custom_fields,   :on_delete => :cascade, :on_update => :cascade, :key => :id
      foreign_key :section_entry_id, :section_entries, :on_delete => :cascade, :on_update => :cascade, :key => :id
    end
  end
  
  down do
    drop_table :custom_field_values
    drop_table :custom_field_groups_sections
    drop_table :custom_fields
    drop_table :custom_field_groups
  end

end
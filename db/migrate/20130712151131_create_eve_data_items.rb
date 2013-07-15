class CreateEveDataItems < ActiveRecord::Migration
  def change
    create_table :eve_data_items do |t|

      t.timestamps
    end
  end
end

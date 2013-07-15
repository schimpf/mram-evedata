class CreateEveDataInvTypes < ActiveRecord::Migration
  def change
    create_table :eve_data_inv_types do |t|

      t.timestamps
    end
  end
end

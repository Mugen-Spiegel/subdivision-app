class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :block
      t.string :lot
      t.string :street
      t.belongs_to :subdivision
      t.timestamps
    end
  end
end

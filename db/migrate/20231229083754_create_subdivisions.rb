class CreateSubdivisions < ActiveRecord::Migration[7.1]
  def change
    create_table :subdivisions do |t|
      t.string :name
      t.string :barangay
      t.string :city
      t.string :postal_code

      t.timestamps
    end
  end
end

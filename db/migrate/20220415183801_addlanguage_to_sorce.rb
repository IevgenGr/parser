class AddlanguageToSorce < ActiveRecord::Migration[7.0]
  def change
    add_column :sources, :language, :string
  end
end

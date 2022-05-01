class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :link
      t.text :headline
      t.text :snippet
      t.references :source, null: false, foreign_key: true

      t.timestamps
    end
  end
end

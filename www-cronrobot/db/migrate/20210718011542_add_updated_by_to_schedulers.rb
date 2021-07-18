class AddUpdatedByToSchedulers < ActiveRecord::Migration[7.0]
  def change
    add_reference :schedulers, :updated_by_user, foreign_key: { to_table: :users }
  end
end

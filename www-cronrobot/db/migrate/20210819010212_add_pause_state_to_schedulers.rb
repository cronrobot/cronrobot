class AddPauseStateToSchedulers < ActiveRecord::Migration[7.0]
  def change
    add_column :schedulers, :pause_state, :string
  end
end

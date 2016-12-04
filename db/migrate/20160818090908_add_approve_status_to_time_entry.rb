class AddApproveStatusToTimeEntry < ActiveRecord::Migration
  def change
    add_column :time_entries, :review, :integer
    add_column :time_entries, :reason, :string
  end
end

class RenameAdmittancesToAdmissions < ActiveRecord::Migration
  def change
    rename_table :admittances, :admissions
  end
end

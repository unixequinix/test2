class ChangeNullInCustomers < ActiveRecord::Migration[5.1]
  def change
    change_column_null :customers, :email, true
    change_column_null :customers, :first_name, true
    change_column_null :customers, :last_name, true
    change_column_null :customers, :encrypted_password, true


    change_column_default :customers, :email, nil
    change_column_default :customers, :first_name, nil
    change_column_default :customers, :last_name, nil
    change_column_default :customers, :encrypted_password, nil
  end
end

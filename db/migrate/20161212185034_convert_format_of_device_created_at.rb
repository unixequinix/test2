class ConvertFormatOfDeviceCreatedAt < ActiveRecord::Migration
  def change
    puts "updating the format of device_created_at"

    sql = "update transactions 
          set device_created_at = concat(left(device_created_at, 10),'T',substr(device_created_at,12,12),'+0100')
          where device_created_at LIKE '____-__-__ __:__:__.___'"
    ActiveRecord::Base.connection.execute(sql)

    sql = "update transactions
          set device_created_at = concat(left(device_created_at, 10),'T',substr(device_created_at,12,8),'.000+0100')
          where device_created_at LIKE '____-__-__ __:__:__'"
    ActiveRecord::Base.connection.execute(sql)

    sql = "update transactions
          set device_created_at = concat(left(device_created_at, 19),'.000',substr(device_created_at,20,3),substr(device_created_at,24,2))
          where device_created_at LIKE '____-__-__T__:__:__+__:__'"
    ActiveRecord::Base.connection.execute(sql)

    sql = "update transactions
           set device_created_at = concat(left(device_created_at, 10),'T',substr(device_created_at,12,8),'.000',substr(device_created_at,21,5))
           where device_created_at LIKE '____-__-__ __:__:__ +____'"
    ActiveRecord::Base.connection.execute(sql)
  end
end

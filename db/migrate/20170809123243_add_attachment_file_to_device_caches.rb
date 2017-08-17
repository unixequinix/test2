class AddAttachmentFileToDeviceCaches < ActiveRecord::Migration[5.1]
  def self.up
    change_table :device_caches do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :device_caches, :file
  end
end

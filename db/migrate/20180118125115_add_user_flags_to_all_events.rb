class AddUserFlagsToAllEvents < ActiveRecord::Migration[5.1]
  def change
    Event.all.each {|event| Event::USER_FLAGS.each { |flag| event.user_flags.find_or_create_by!(name: flag) } }
  end
end

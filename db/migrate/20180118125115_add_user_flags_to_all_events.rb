class AddUserFlagsToAllEvents < ActiveRecord::Migration[5.1]
  def change
    Event.all.each do |event|
      Event::USER_FLAGS.each do |flag|
        flag = event.user_flags.find_or_initialize_by(name: flag)
        flag.update!(symbol: "C")
      end
    end
  end
end

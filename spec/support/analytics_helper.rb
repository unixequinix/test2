module AnalyticsHelper
  def test_group_by_day(items, method_name, group_field)
    [items].flatten.compact.last.update!("#{group_field.to_s}": Date.yesterday)
    [items].flatten.compact.first.update!("#{group_field.to_s}": Date.tomorrow)

    expect(subject.send(method_name, :day).keys).to include(Date.yesterday)
    expect(subject.send(method_name, :day).keys).to include(Time.zone.today)
    expect(subject.send(method_name, :day).keys).to include(Date.tomorrow)
  end

  def test_group_by_hour(items, method_name, group_field)
    [items].flatten.compact.last.update!("#{group_field.to_s}": 1.hour.ago)
    [items].flatten.compact.first.update!("#{group_field.to_s}": 2.hours.ago)

    expect(subject.send(method_name, :hour).keys).to include(1.hour.ago.beginning_of_hour)
    expect(subject.send(method_name, :hour).keys).to include(Date.now.beginning_of_hour)
    expect(subject.send(method_name, :hour).keys).to include(2.hours.ago.beginning_of_hour)
  end
end

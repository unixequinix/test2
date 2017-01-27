Capybara.add_selector :link_to do
  xpath { |href| XPath.descendant(:a)[XPath.attribute(:href).equals(href)] }
end

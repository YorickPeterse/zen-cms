require File.expand_path('../../../../../helper', __FILE__)

describe("Menus::Controller::MenuItems") do
  behaves_like :capybara

  menu          = Menus::Model::Menu.create(:name => 'Spec menu')
  index_url     = Menus::Controller::MenuItems.r(:index, menu.id).to_s
  edit_url      = Menus::Controller::MenuItems.r(:edit, menu.id).to_s
  new_button    = lang('menu_items.buttons.new')
  save_button   = lang('menu_items.buttons.save')
  delete_button = lang('menu_items.buttons.delete')

  should('find no existing menu items') do
    message = lang('menu_items.messages.no_items')

    visit(index_url)

    page.has_content?(message).should           == true
    page.has_selector?('table tbody tr').should == false
  end

  should('submit a form without a CSRF token') do
    response = page.driver.post(
      Menus::Controller::MenuItems.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should == true
    response.status.should                                         == 403
  end

  should("create a new menu item") do
    visit(index_url)
    click_link(new_button)

    within('#menu_item_form') do
      fill_in('name'     , :with => 'Spec menu item')
      fill_in('url'      , :with => '/spec')
      fill_in('html_class', :with => 'spec_class')
      click_on(save_button)
    end

    current_path.should =~ /#{edit_url}\/[0-9]+/
  end

  should('search for a menu item') do
    search_button = lang('zen_general.buttons.search')
    error         = lang('zen_general.errors.invalid_search')

    visit(index_url)

    within('#search_form') do
      fill_in('query', :with => 'Spec menu item')
      click_on(search_button)
    end

    page.has_content?(error).should            == false
    page.has_content?('Spec menu item').should == true

    within('#search_form') do
      fill_in('query', :with => 'does not exist')
      click_on(search_button)
    end

    page.has_content?(error).should            == false
    page.has_content?('Spec menu item').should == false
  end

  should("edit an existing menu item") do
    visit(index_url)
    click_link('Spec menu item')

    within('#menu_item_form') do
      fill_in('name', :with => 'Spec menu item modified')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should == 'Spec menu item modified'
  end

  should('edit an existing menu item with invalid data') do
    visit(index_url)
    click_link('Spec menu item')

    within('#menu_item_form') do
      fill_in('name', :with => 'xxx')
      fill_in('url' , :with => '')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should == 'xxx'
    page.has_selector?('span.error').should      == true
  end

  should('fail to delete a set of items without an ID') do
    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="menu_item_ids[]"]').should == true
  end

  should("delete an existing menu item") do
    message = lang('menu_items.messages.no_items')

    visit(index_url)
    check('menu_item_ids[]')
    click_on(delete_button)

    page.has_selector?('table tbody tr').should == false
    page.has_content?(message).should           == true
  end

  should('call the event new_menu_item (before and after)') do
    event_name = nil

    Zen::Event.listen(:before_new_menu_item) do |menu|
      menu.name += ' with event'
    end

    Zen::Event.listen(:after_new_menu_item) do |menu|
      event_name = menu.name
    end

    visit(index_url)
    click_on(new_button)

    within('#menu_item_form') do
      fill_in('name', :with => 'Menu item')
      fill_in('url' , :with => '/')
      click_on(save_button)
    end

    page.has_selector?('span.error').should      == false
    page.find('input[name="name"]').value.should == 'Menu item with event'

    Zen::Event.delete(:before_new_menu_item, :after_new_menu_item)
  end

  should('call the event edit_menu_item (before and after)') do
    event_name = nil

    Zen::Event.listen(:before_edit_menu_item) do |menu|
      menu.name = 'Menu item modified'
    end

    Zen::Event.listen(:after_edit_menu_item) do |menu|
      event_name = menu.name
    end

    visit(index_url)
    click_on('Menu item with event')

    within('#menu_item_form') do
      click_on(save_button)
    end

    page.has_selector?('span.error').should      == false
    page.find('input[name="name"]').value.should == 'Menu item modified'
    event_name.should                            == 'Menu item modified'

    Zen::Event.delete(:before_edit_menu_item, :after_edit_menu_item)
  end

  should('call the event delete_menu_item (before and after)') do
    event_name  = nil
    event_name2 = nil
    message     = lang('menu_items.messages.no_items')

    Zen::Event.listen(:before_delete_menu_item) do |menu|
      event_name = menu.name
    end

    Zen::Event.listen(:after_delete_menu_item) do |menu|
      event_name2 = menu.name
    end

    visit(index_url)
    check('menu_item_ids[]')
    click_on(delete_button)

    page.has_selector?('table tbody tr').should == false
    page.has_content?(message).should           == true
    event_name.should                           == 'Menu item modified'
    event_name2.should                          == event_name

    Zen::Event.delete(:before_delete_menu_item, :after_edit_menu_item)
  end

  menu.destroy
end

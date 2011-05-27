require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('categories')

describe(
  "Categories::Controller::Categories", :type => :acceptance, :auto_login => true
) do

  it("Create the test data") do
    Testdata[:group] = Categories::Model::CategoryGroup.new(:name => 'Spec group').save
  end

  it("No categories should exist") do
    index_url = Categories::Controller::Categories.r(:index, Testdata[:group].id).to_s
    message   = lang('categories.messages.no_categories')

    visit(index_url)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
    current_path.should                         === index_url
  end

  it("Create a new category") do
    index_url   = Categories::Controller::Categories.r(:index, Testdata[:group].id).to_s
    edit_url    = Categories::Controller::Categories.r(:edit , Testdata[:group].id).to_s
    new_button  = lang('categories.buttons.new')
    save_button = lang('categories.buttons.save')

    visit(index_url)
    click_link(new_button)

    within('#category_form') do
      fill_in('name', :with => 'Spec category')
      click_on(save_button)
    end

    current_path.should =~ /#{edit_url}\/[0-9]+/
  end

  it("Edit an existing category") do
    index_url   = Categories::Controller::Categories.r(:index, Testdata[:group].id).to_s
    edit_url    = Categories::Controller::Categories.r(:edit , Testdata[:group].id).to_s
    save_button = lang('categories.buttons.save')

    visit(index_url)
    click_link('Spec category')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#category_form') do
      fill_in('name', :with => 'Spec category modified')
      click_on(save_button)
    end    

    page.find('input[name="name"]').value.should === 'Spec category modified'
  end

  it("Delete an existing category") do
    index_url     = Categories::Controller::Categories.r(:index, Testdata[:group].id).to_s
    message       = lang('categories.messages.no_categories')
    delete_button = lang('categories.buttons.delete')

    visit(index_url)
    check('category_ids[]')
    click_on(delete_button)

    page.has_content?(message).should           === true
    page.has_selector?('table tbody tr').should === false
  end

  it("Delete the test data") do
    Testdata[:group].destroy
  end

end

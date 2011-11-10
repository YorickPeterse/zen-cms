require File.expand_path('../../../../../helper', __FILE__)

describe('Ramaze::Helper::Category') do
  behaves_like :capybara

  category_group = ::Categories::Model::CategoryGroup.create(
    :name => 'Spec group'
  )

  category = ::Categories::Model::Category.create(
    :name              => 'Spec category',
    :category_group_id => category_group.id
  )

  should('validate a valid category group') do
    url = ::Categories::Controller::Categories.r(
      :index, category_group.id
    ).to_s

    visit(url)

    current_path.should == "/admin/categories/index/#{category_group.id}"
  end

  should('validate an invalid category group') do
    url = ::Categories::Controller::Categories.r(
      :index, category_group.id + 1
    ).to_s

    visit(url)

    current_path.should == '/admin/category-groups/index'
  end

  should('validate a valid category') do
    group_id = category_group.id
    cat_id   = category.id

    url = ::Categories::Controller::Categories.r(
      :edit, group_id, cat_id
    ).to_s

    visit(url)

    current_path.should == "/admin/categories/edit/#{group_id}/#{cat_id}"
  end

  should('validate an invalid category') do
    group_id = category_group.id

    url = ::Categories::Controller::Categories.r(
      :edit, group_id, group_id + 1
    ).to_s

    visit(url)

    current_path.should == "/admin/categories/index/#{group_id}"
  end

  category.destroy
  category_group.destroy
end

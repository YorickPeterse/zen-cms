require File.expand_path('../../../../../helper', __FILE__)

describe('Comments::Controller::Comments') do
  behaves_like :capybara

  index_url   = Comments::Controller::Comments.r(:index).to_s
  edit_url    = Comments::Controller::Comments.r(:edit).to_s
  save_button = lang('comments.buttons.save')
  user_id     = Users::Model::User[:email => 'spec@domain.tld'].id
  section     = Sections::Model::Section.create(
    :name                    => 'Spec section',
    :comment_allow           => true,
    :comment_require_account => false,
    :comment_moderate        => false,
    :comment_format          => 'markdown'
  )

  entry = Sections::Model::SectionEntry.create(
    :title      => 'Spec entry',
    :user_id    => user_id,
    :section_id => section.id
  )

  after do
    Zen::Event.delete(
      :before_edit_comment,
      :after_edit_comment,
      :before_delete_comment,
      :after_delete_comment
    )
  end

  should('submit a form without a CSRF token') do
    response = page.driver.post(
      Comments::Controller::Comments.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should == true
    response.status.should                                         == 403
  end

  should('find no existing comments') do
    message = lang('comments.messages.no_comments')

    visit(index_url)

    page.has_content?(message).should           == true
    page.has_selector?('table tbody tr').should == false
  end

  should('create a new comment') do
    comment = Comments::Model::Comment.create(
      :user_id          => 1,
      :section_entry_id => entry.id,
      :email            => 'spec@domain.tld',
      :comment          => 'Spec comment'
    )

    message = lang('comments.messages.no_comments')

    visit(index_url)

    page.has_content?(message).should           == false
    page.has_selector?('table tbody tr').should == true
  end

  should('search for a comment') do
    visit(index_url)
    search_button = lang('zen_general.buttons.search')
    error         = lang('zen_general.errors.invalid_search')

    within('#search_form') do
      fill_in('query', :with => 'Spec comment')
      click_on(search_button)
    end

    page.has_content?(error).should          == false
    page.has_content?('Spec comment').should == true

    within('#search_form') do
      fill_in('query', :with => 'spec@domain.tld')
      click_on(search_button)
    end

    page.has_content?(error).should          == false
    page.has_content?('Spec comment').should == true

    within('#search_form') do
      fill_in('query', :with => 'does not exist')
      click_on(search_button)
    end

    page.has_content?(error).should          == false
    page.has_content?('Spec comment').should == false
  end

  should('edit an existing comment') do
    event_comment  = nil
    event_comment2 = nil
    comment        = 'Spec modified 123'

    Zen::Event.listen(:before_edit_comment) do |comment|
      event_comment = comment.comment
    end

    Zen::Event.listen(:after_edit_comment) do |comment|
      event_comment2 = comment.comment
    end

    visit(index_url)
    click_link('Spec comment')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#comment_form') do
      fill_in('comment', :with => comment)
      select(lang('comments.labels.open'), :from => 'comment_status_id')
      click_on(save_button)
    end

    page.find('textarea[name="comment"]').value.should == comment

    page.find('select[name="comment_status_id"] option[selected]').text \
      .should == lang('comments.labels.open')

    event_comment.should  == comment
    event_comment2.should == event_comment

    Zen::Event.delete(:before_edit_comment, :after_edit_comment)

    # Modify the comment using an event
    Zen::Event.listen(:before_edit_comment) do |comment|
      comment.comment = 'Spec comment modified'
    end

    within('#comment_form') do
      click_on(save_button)
    end

    page.find('textarea[name="comment"]') \
      .value.should == 'Spec comment modified'
  end

  should('edit an existing comment with invalid data') do
    visit(index_url)
    click_link('Spec comment')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#comment_form') do
      fill_in('comment', :with => '')
      click_on(save_button)
    end

    page.has_selector?('span.error').should == true
  end

  should('fail to delete a set of comments without IDs') do
    delete_button = lang('comments.buttons.delete')

    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="comment_ids[]"]').should == true
  end

  should('delete an existing comment') do
    delete_button  = lang('comments.buttons.delete')
    message        = lang('comments.messages.no_comments')
    event_comment  = nil
    event_comment2 = nil

    Zen::Event.listen(:before_delete_comment) do |comment|
      event_comment = comment.comment
    end

    Zen::Event.listen(:after_delete_comment) do |comment|
      event_comment2 = comment.comment
    end

    visit(index_url)
    check('comment_ids[]')
    click_on(delete_button)

    page.has_content?(message).should           == true
    page.has_selector?('table tbody tr').should == false

    event_comment.should  == 'Spec comment modified'
    event_comment2.should == event_comment
  end

  entry.destroy
  section.destroy
end

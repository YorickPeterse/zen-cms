require File.expand_path('../../../../../helper', __FILE__)

describe('Sections::Plugin::Sections') do
  @section_1 = Sections::Model::Section.create(
    :name                    => 'Spec',
    :comment_allow           => true,
    :comment_require_account => false,
    :comment_moderate        => false,
    :comment_format          => 'plain'
  )

  @section_2 = Sections::Model::Section.create(
    :name                    => 'Spec 1',
    :comment_allow           => true,
    :comment_require_account => false,
    :comment_moderate        => false,
    :comment_format          => 'plain'
  )

  it('Retrieve all sections') do
    sections = plugin(:sections)

    sections.count.should   === 2
    sections[0][:name].should === 'Spec'
    sections[1][:name].should === 'Spec 1'
  end

  it('Retrieve a single section') do
    section = plugin(:sections, :section => 'spec')

    section[:name].should           === 'Spec'
    section[:comment_allow].should  === true
    section[:comment_format].should === 'plain'
  end

  it('Retrieve a single section by it\'s ID') do
    section = plugin(
      :sections, :section => @section_1.id
    )

    section[:name].should           === 'Spec'
    section[:comment_allow].should  === true
    section[:comment_format].should === 'plain'
  end

  it('Limit the amount of sections') do
    sections = plugin(:sections, :limit => 1)

    sections.count.should     === 1
    sections[0][:name].should === 'Spec'
  end

  it('Limit the amount of sections and set an offset') do
    sections = plugin(:sections, :limit => 1, :offset => 1)

    sections.count.should     === 1
    sections[0][:name].should === 'Spec 1'
  end

  @section_1.destroy
  @section_2.destroy
end

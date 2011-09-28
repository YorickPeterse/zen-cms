require File.expand_path('../../helper', __FILE__)

describe('Zen::Event') do
  after do
    Zen::Event::Registered.delete(:test)
  end

  it('Register a event') do
    Zen::Event.add(:test) {}

    Zen::Event::Registered.key?(:test).should === true
  end

  it('Run a single event') do
    data = 0

    Zen::Event.add(:test) do |number|
      data = number
    end

    Zen::Event.call(:test, 10)
    data.should === 10

    Zen::Event.call(:test, 12)
    data.should === 12
  end

  it('Run multiple events') do
    data = 0

    Zen::Event.add(:test) do |number|
      data += number
    end

    Zen::Event.add(:test) do |number|
      data += (number * 2)
    end

    Zen::Event.call(:test, 10)
    Zen::Event.call(:test, 20)

    data.should === 90
  end
end

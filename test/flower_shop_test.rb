require 'minitest/autorun'
require 'minitest-spec-context'

test_dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift(test_dir) unless $LOAD_PATH.include?(test_dir)

bin_dir = File.expand_path(File.join(test_dir, '..', 'bin'))
$LOAD_PATH.unshift(bin_dir) unless $LOAD_PATH.include?(bin_dir)

load 'flower_shop'

describe '#bundler' do

  let(:bundle_definitions) do
    instance_eval(File.read(File.join('test', 'fixtures', 'bundle_definitions.rb')))
  end

  it "will find the most optimal bundling of a line item" do
    bundler(10, bundle_definitions['R12'], {}).must_equal({10 => 1})
  end

end

describe '#order_processor' do

  let(:order) do
    File.read(File.join('test', 'fixtures', 'order.txt')).split("\n")
  end

  let(:bundle_definitions) do
    instance_eval(File.read(File.join('test', 'fixtures', 'bundle_definitions.rb')))
  end

  it "find most optional bundles for an order" do
    expectation = [
      {quantity: '10', code: 'R12', bundles: {10 => 1}},
      {quantity: '15', code: 'L09', bundles: {9 => 1, 6 => 1}},
      {quantity: '13', code: 'T58', bundles: {5 => 2, 3 => 1}},
    ]
    order_processor(order, bundle_definitions).must_equal(expectation)
  end

end

require 'minitest/autorun'
require 'minitest-spec-context'

test_dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift(test_dir) unless $LOAD_PATH.include?(test_dir)

bin_dir = File.expand_path(File.join(test_dir, '..', 'bin'))
$LOAD_PATH.unshift(bin_dir) unless $LOAD_PATH.include?(bin_dir)

load 'flower_shop'

describe 'flower_shop' do
  describe 'bundler()' do
    let(:bundle_definitions) do
      instance_eval(File.read(File.join('test', 'fixtures', 'bundle_definitions.rb')))
    end

    it "will find the most optimal bundling of a line item" do
      bundler(10, bundle_definitions['R12'], {}).must_equal({10 => 1})
    end
  end

  describe 'order_processor()' do
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

  describe 'delivery_docket_bundle_heading()' do
    let(:order_line_item) do
      {quantity: '10', code: 'R12', bundles: {10 => 1}}
    end

    let(:bundle_definitions) do
      instance_eval(File.read(File.join('test', 'fixtures', 'bundle_definitions.rb')))
    end

    it "generates a delivery docket bundle heading" do
      expectation = '10 R12 $12.99'
      delivery_docket_bundle_heading(order_line_item, bundle_definitions).must_equal(expectation)
    end
  end

  describe 'delivery_docket_bundle_breakdown()' do
    let(:order_line_item) do
      {quantity: '15', code: 'L09', bundles: {9 => 1, 6 => 1}}
    end

    let(:bundle_definitions) do
      instance_eval(File.read(File.join('test', 'fixtures', 'bundle_definitions.rb')))
    end

    it "generates a delivery docket bundle heading" do
      expectation = "      1 x 9 $24.95\n      1 x 6 $16.95"
      delivery_docket_bundle_breakdown(order_line_item, bundle_definitions).must_equal(expectation)
    end
  end

  describe 'delivery_docket()' do
    let(:processed_order) do
      [
        {quantity: '10', code: 'R12', bundles: {10 => 1}},
        {quantity: '15', code: 'L09', bundles: {9 => 1, 6 => 1}},
        {quantity: '13', code: 'T58', bundles: {5 => 2, 3 => 1}},
      ]
    end

    let(:bundle_definitions) do
      instance_eval(File.read(File.join('test', 'fixtures', 'bundle_definitions.rb')))
    end

    it "generates a delivery docket bundle heading" do
      expectation = ["10 R12 $12.99", "      1 x 10 $12.99", "15 L09 $41.90", "      1 x 9 $24.95\n      1 x 6 $16.95", "13 T58 $25.85", "      2 x 5 $19.90\n      1 x 3 $5.95"]
      delivery_docket(processed_order, bundle_definitions).must_equal(expectation)
    end
  end
end

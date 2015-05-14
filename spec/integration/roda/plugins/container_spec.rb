require 'spec_helper'

RSpec.describe 'container plugin' do
  before do
    module Test
      class Application < Roda; end
    end
  end

  context 'registering a block' do
    context 'without options' do
      it 'registers and resolves an object' do
        Test::Application.register(:item) { 'item' }

        expect(Test::Application.resolve(:item)).to eq('item')
      end
    end

    context 'with option call: false' do
      it 'registers and resolves a proc' do
        Test::Application.register(:item, call: false) { 'item' }

        expect(Test::Application.resolve(:item).call).to eq('item')
      end
    end
  end

  context 'registering a proc' do
    context 'without options' do
      it 'registers and resolves an object' do
        Test::Application.register(:item, proc { 'item' })

        expect(Test::Application.resolve(:item)).to eq('item')
      end
    end

    context 'with option call: false' do
      it 'registers and resolves a proc' do
        Test::Application.register(:item, proc { 'item' }, call: false)

        expect(Test::Application.resolve(:item).call).to eq('item')
      end
    end
  end

  context 'registering an object' do
    context 'without options' do
      it 'registers and resolves the object' do
        item = 'item'
        Test::Application.register(:item, item)

        expect(Test::Application.resolve(:item)).to be(item)
      end
    end

    context 'with option call: false' do
      it 'registers and resolves an object' do
        module Test
          class Callable
            def call; end
          end
        end

        item = Test::Callable.new
        Test::Application.register(:item, item, call: false)

        expect(Test::Application.resolve(:item)).to eq(item)
      end
    end
  end
end

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

  context 'registering with "instance"' do
    it 'is threadsafe' do
      Test::Application.route do |r|
        register(:app, self, call: false)

        r.on 'concurrency' do
          r.on 'one' do
            sleep(0.1)
            r.get do
              Test::Application.instance.resolve(:app).request.params.to_s
            end
          end

          r.on 'two' do
            r.get do
              Test::Application.instance.resolve(:app).request.params.to_s
            end
          end
        end
      end

      threads = []
      queue = Queue.new
      threads << Thread.new { queue << get('/concurrency/one', one: true) }
      threads << Thread.new { queue << get('/concurrency/two', two: true) }
      threads.each(&:join)

      response_1 = queue.pop
      response_2 = queue.pop

      if response_1.body =~ /^Request 1\:/
        expect(response_1.body).to end_with("{\"one\"=>\"true\"}")
        expect(response_2.body).to end_with("{\"two\"=>\"true\"}")
      else
        expect(response_2.body).to end_with("{\"one\"=>\"true\"}")
        expect(response_1.body).to end_with("{\"two\"=>\"true\"}")
      end
    end
  end
end

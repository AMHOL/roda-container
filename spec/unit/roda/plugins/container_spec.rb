require 'spec_helper'

RSpec.describe Roda::RodaPlugins::Container do
  describe '.inherited' do
    let(:parent_key) { :parent_key }
    let(:parent_value) { 'parent containers string instance' }

    before do
      Roda.register(parent_key, parent_value)
      Test::RodaApplication = Class.new(Roda)
    end

    it 'inherits its parents continaer' do
      expect(Test::RodaApplication.resolve(parent_key)).to eq(parent_value)
    end
  end

  describe '.register' do
    context 'given a normal argument' do
      subject! { Roda.register(:key, value) }

      context 'when argument does not respond to call' do
        let(:value) { 'a string instance' }

        it 'registers an instance to be resolved' do
          expect(Roda.resolve(:key)).to be(value)
        end
      end

      context 'when argument responds to call' do
        let(:instance) { 'a string instance' }
        let(:value) do
          proc { instance }
        end

        it 'registers a proc to evaluate each time it is resolved' do
          expect(Roda.resolve(:key)).to eq(instance)
        end
      end
    end

    context 'given a block argument' do
      let(:value) { 'a string instance' }

      subject! do
        Roda.register(:key) { value }
      end

      it 'registers the block as a proc to evaluate each time it is resolved' do
        expect(Roda.resolve(:key)).to eq(value)
      end
    end
  end

  describe '.resolve' do
    context 'given a key that is registered' do
      before do
        Roda.register(:key, value)
      end

      subject { Roda.resolve(:key) }

      context 'when registered value is not a proc' do
        let(:value) { 'not a proc' }

        it { is_expected.to be(value) }
      end

      context 'when registered value is a proc' do
        let(:instance) { 'a string instance' }
        let(:value) do
          proc { instance }
        end

        it { is_expected.to be(instance) }
      end
    end

    context 'given a key that is not registered' do
      it do
        expect { Roda.resolve(:random_key) }.to raise_error(Roda::ContainerError)
      end
    end
  end

  describe '.detach_container' do
    before do
      Roda.register(parent_key, parent_value)
      Test::RodaApplication = Class.new(Roda)
      Test::RodaApplication.detach_container
      Test::RodaApplication.register(child_key, child_value)
    end

    context 'registering with the child container using a key that exists in the parent' do
      let(:parent_key) { :key }
      let(:parent_value) { 'parent containers string instance' }
      let(:child_key) { :key }
      let(:child_value) { 'child containers string instance' }

      it 'does not overwrite the parent container' do
        expect(Test::RodaApplication.resolve(parent_key)).not_to be(Roda.resolve(child_key))
      end
    end

    context 'registering with the child container using a key that does not exist in the parent' do
      let(:parent_key) { :parent_key }
      let(:parent_value) { 'parent containers string instance' }
      let(:child_key) { :child_key }
      let(:child_value) { 'child containers string instance' }

      it 'does not overwrite the parent container' do
        expect { Roda.resolve(child_key) }.to raise_error(Roda::ContainerError)
      end
    end
  end

  describe '.freeze' do
    before do
      Roda.freeze
    end

    it 'freezes the container and errors when you try to register' do
      expect { Roda.register(:key, 'value') }.to raise_error
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'
require_relative 'support/cache'

RSpec.describe Register do
  subject(:c) { Cache }

  before do
    Cache.send(:store).clear
    # Various ways of calling #register
    Cache.register :planetary, CacheStore.new(:saturn)
    Cache << %i[number].push(Math::PI)
    Cache.register(:primary, :main, :rails, :deploy) do
      CacheStore.new(:primary)
    end
    Cache << (%i[durable secondary] << CacheStore.new(:secondary))
  end

  let(:durable) { CacheStore.new(:secondary) }
  its(:store) { should be_kind_of(Hash) }
  its(:rails) { should eq CacheStore.new(:primary) }
  its(:number) { should eq Math::PI }

  it 'for' do
    expect(c.for(:durable)).to eq(durable)
    expect(c.for(:secondary)).to eq(durable)
  end

  it 'planetary' do
    expect(Cache.planetary.name).to eq(:saturn)
  end

  its(:keys) { should include(:planetary) }
  its(:values) { should include Cache.planetary }
  it 'should have values already uniq' do
    expect(Cache.values).to eq(Cache.values.uniq)
  end

  it 'should protect store as private' do
    expect { Cache.store }.to raise_error(NoMethodError)
  end

  context 'invalid usage' do
    it 'non-existing key ' do
      expect { Cache.for(:boohahah) }.to raise_error(Register::NoSuchIdentifierError)
    end

    it 'adding already existing key' do
      expect { Cache.register(:main, :boo) }.to raise_error(Register::AlreadyRegisteredError)
    end

    it 'adding already existing key with :ignore_if_exists' do
      expect(Cache.register(:main, :boo, ignore_if_exists: true)).to eq(Cache.main)
    end

    Register::RESERVED.each do |key|
      it "adding reserved keys #{key}" do
        expect { Cache.register(key, :boo) }.to raise_error(Register::ReservedIdentifierError)
      end
    end
  end
end

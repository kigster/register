require 'spec_helper'
require_relative 'support/cache'

RSpec.describe Register do

  subject(:c) { Cache }
  let(:durable) { CacheStore.new(:secondary) }
  its(:store) { should be_kind_of(Hash) }
  its(:rails) { should eq CacheStore.new(:primary) }

  it 'for' do
    expect(c.for(:durable)).to eq(durable)
    expect(c.for(:secondary)).to eq(durable)
  end

  it 'planetary' do
    expect(Cache.planetary.name).to eq(:saturn)
  end

  context 'invalid usage' do
    it 'non-existing key ' do
      expect { Cache.for(:boohahah) }.to raise_error(Register::NoSuchIdentifierError)
    end

    it 'adding already existing key' do
      expect { Cache.register(:main, :boo) }.to raise_error(Register::AlreadyRegisteredError)
    end

    Register::RESERVED.each do |key|
      it "adding already existing key #{key}" do
        expect { Cache.register(key, :boo) }.to raise_error(Register::ReservedIdentifierError)
      end
    end

  end
end



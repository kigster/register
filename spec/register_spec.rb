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


end

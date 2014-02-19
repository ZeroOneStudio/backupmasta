require 'spec_helper'

describe Storage do
  before(:each) do
    Fog.mock!
    @storage = Storage.connect
    @storage.name = 'test'
    @storage.create
  end

  after(:each) { Fog::Mock.reset }

  describe '::connect' do
    it 'should just work' do
      expect(@storage).to be_a(Storage)
    end
    
    it 'should set up directories' do
      expect(@storage.directories).not_to be_nil
    end
  end

  describe '#create' do
    it 'should create directory' do
      expect(@storage.directories.size).to eq(1)
    end

    it 'should create directory with correct name' do
      expect(@storage.directories.first.key).to eq('backupmasta_test_test')
    end
  end

  describe '#create' do
    it 'should create directory' do
      expect(@storage.directories.size).to eq(1)
    end

    it 'should create directory with correct name' do
      expect(@storage.directories.first.key).to eq('backupmasta_test_test')
    end
  end

  describe '#destroy' do
    it 'should destroy directory' do
      @storage.destroy
      expect(@storage.directories.size).to eq(0)
    end
  end

  describe '#files' do
    before(:each) { @storage.files.create({ body: 'kinda_body', key: 'kinda_key' }) }

    it 'should be not blank' do
      expect(@storage.files).not_to be_blank
    end

    it 'should fetch files' do
      expect(@storage.files.first.key).to eq('kinda_key')
    end    
  end  

  describe '#current_directory' do
    it 'should fetch current directory' do
      expect(@storage.directories.get('backupmasta_test_test')).not_to be_nil
    end
  end  
end
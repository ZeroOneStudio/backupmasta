require 'spec_helper'

describe "Backupmasta application" do
  it "GET '/' should be success" do
    get '/'
    expect(last_response).to be_ok
  end
end

require 'spec_helper'

describe "Backupmasta application" do
  it "GET '/' should be success" do
    get '/'
    last_response.should be_ok
  end
end
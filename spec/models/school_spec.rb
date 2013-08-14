require 'spec_helper'

describe School do
  it 'has a valid factory' do
    FactoryGirl.create(:school).should be_valid
  end

  describe 'the model' do
    subject { FactoryGirl.create(:school) }
    it { should respond_to(:gsid) }
    it { should respond_to(:title) }
    it { should respond_to(:city) }
    it { should respond_to(:state) }
    it { should respond_to(:zip) }
  end


  describe 'validations' do
    let(:school) { FactoryGirl.build(:school) }
    it 'is invalid without a Great Schools ID' do
      school.gsid = nil
      school.should_not be_valid
    end
    it 'is invalid without a title' do
      school.title = nil
      school.should_not be_valid
    end
    it 'is invalid without a city' do
      school.city = nil
      school.should_not be_valid
    end
    it 'is invalid without a state' do
      school.state = nil
      school.should_not be_valid
    end
    it 'is invalid without a zip' do
      school.zip = nil
      school.should_not be_valid
    end
  end

  it 'is associated with posts' do
    school = FactoryGirl.create(:school)
    post = FactoryGirl.create(:post, school_id: school.id)
    school.posts.should include(post)
  end
end

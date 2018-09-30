require 'spec_helper'
require 'memory_repository/models/user'

describe UsersController do
  before(:each) do
    @user = MemoryRepository::User.new({ :login => "test user", :email => "test_user@test.com"})
    controller.stub(:current_user).and_return(@user)
    controller.stub(:authenticate)
    controller.stub(:employee?)
    User.stub(:find).and_return(@user)
  end

  after :each do
    MemoryRepository.user.destroy_all
  end

  describe "show" do
    it "finds the user" do
      get :show, :id => @user.id
      assigns[:user].should == @user
    end
  end

  describe "edit" do
    it "finds the user" do
      get :edit, :id => @user.id
      assigns[:user].should == @user
    end
  end

  describe "update" do
    it "updates user with valid params" do
      post :update, {:id => @user.id, "user" => {:login => "test_user", :email => "changed_email@test.com"}}
      @user.email.should == "changed_email@test.com"
    end

    it "redirects to profile after updating" do
      post :update, {:id => @user.id, "user" => {:login => "test_user", :email => "changed_email@test.com"}}
      expect(response).to redirect_to(user_path(assigns(:user)))
    end

    it "only updates if successful save" do
      @user.saves = false
      post :update, {:id => @user.id, "user" => { :login => "test_user", :email => ""}}
      @user.email.should == "test_user@test.com"
    end

    it "renders edit template for unsuccessful save" do
      @user.saves = false
      post :update, {:id => @user.id, "user" => { :login => "test_user", :email => ""}}
      response.should render_template("edit")
    end

    it "doesn't update profile unless you're the current user" do
      request.env["HTTP_REFERER"] = "where_i_came_from"
      @new_user = MemoryRepository::User.new({ :login => "new user", :email => "new_user@test.com"})
      controller.stub(:current_user).and_return(@new_user)
      controller.stub(:authenticate)
      controller.stub(:employee?)
      User.stub(:find).and_return(@user)
      post :update, { :id => @user.id, "user" => { :login => "test_user", :email => "new_email@test.com" }}
      response.should redirect_to "where_i_came_from"
    end
  end
end

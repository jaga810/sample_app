require 'spec_helper'

describe "Authentification" do

  subject {page}

  describe "signin page" do
    before { visit signin_path }

    it{should have_content('Sign in')}
    it{should have_title('Sign in')}
  end

  describe "signin" do
    before { visit signin_path}

    describe "with invalid information" do
        before{click_button "Sign in"}

      it { should have_title('Sign in')}
      it {should have_selector('div.alert.alert-error', text:'Invalid')}

      describe "after visiting another page" do
        before{ click_link "Home"}
        it{should_not have_selector('div.aler.alert_error')}
      end
    end

    before{ click_button "Sign in"}

    it {should have_title('Sign in')}
    it{should have_selector('div.alert.alert-error',text:'Invalid')}

    describe "with valid information" do
      let(:user){ FactoryGirl.create(:user)}
    #  before do
   #     fill_in "Email", with: user.email.upcase
  #      fill_in "Password", with:user.password
 #       click_button "Sign in"
#      end
      before { sign_in user}

      it {should have_title(user.name)}
      it { should have_link('Users', href: users_path)}
      it { should have_link('Settings', href: edit_user_path(user))}
      it{should have_link('Profile', href: user_path(user))}
      it {should have_link('Sign out', href: signout_path)}
      it{ should_not have_link('Sign in', href: signin_path)}

      describe "followed by signout" do
        before { click_link "Sign out"}
        it{should have_link('Sign in')}
      end
    end
  end

    describe "authorization" do
      describe "for non-signed-in users" do
        let(:user){ FactoryGirl.create(:user)}

        describe " confirm profile and settings dont exist" do
          subject { page}
          before{visit root_path}
          it {should_not have_content("Profile")}
          it {should_not have_content("Settings")}
        end

         describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            expect(page).to have_title('Edit user')
          end
        end

        describe "int the Microposts controller" do

          describe "submitting to the create action" do
            before{ post microposts_path}
            specify{ expect(response).to redirect_to(signin_path)}
          end

          describe "submitting to the destroy action" do
            before { delete micropost_path(FactoryGirl.create(:micropost))}
            specify{expect(response).to redirect_to(signin_path)}
          end
        end
      end

        describe "in the Users controller" do

          describe "visitng the edit page" do
            before { visit edit_user_path(user)}
            it { should have_title('Sign in')}
          end

          describe "submitting to the update action" do
            before { patch user_path(user)}
            specify{ expect(response).to redirect_to(signin_path)}
          end

          describe"visiting the user index" do
            before { visit users_path}
            it{should have_title('Sign in')}
          end

       end
    end

      describe "as non-admin user" do
        let(:user){FactoryGirl.create(:user)}
        let(:non_admin){FactoryGirl.create(:user)}

        before{sign_in non_admin, no_capybara:true}

        describe "submitting a DELETE request to the Users#destory action" do
          before {delete user_path(user)}
          specify{expect(response).to redirect_to(root_path)}
        end
      end

      describe "as admin user" do
        let(:admin_user){FactoryGirl.create(:user)}

        before{ sign_in admin_user, no_capybara: true}

        describe "submitting a self-DELETE request to the Users#destory action" do
          before {delete user_path(:admin_user)}
          specify{expect(response).to redirect_to(root_path)}
        end
      end
  end
end

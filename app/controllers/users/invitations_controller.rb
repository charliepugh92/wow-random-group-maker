module Users
  class InvitationsController < Devise::InvitationsController
    # before_action :authenticate_user!, only: [:new, :create]    
  end
end

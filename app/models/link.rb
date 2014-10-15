class Link < ActiveRecord::Base
  belongs_to :user
  belongs_to :track
  belongs_to :role

  after_save :add_role_to_user

  private
    def add_role_to_user
      User.find(self.user_id).add_role(Role.find(self.role_id))
    end
end

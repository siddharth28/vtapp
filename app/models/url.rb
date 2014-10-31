class Url < ActiveRecord::Base
  belongs_to :usertask

  validates :name, uniqueness: { case_sensitive: false }, presence: true
end

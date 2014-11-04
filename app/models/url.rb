class Url < ActiveRecord::Base
  belongs_to :usertask

  validates :name, uniqueness: { scope: [:usertask_id], case_sensitive: false }, presence: true
end

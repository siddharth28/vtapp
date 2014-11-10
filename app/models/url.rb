class Url < ActiveRecord::Base
  belongs_to :usertask

  # FIXED
  # FIXME : Should also validate presence of usertask
  validates :usertask, presence: true
  validates :name, uniqueness: { scope: [:usertask_id], case_sensitive: false }, presence: true
end

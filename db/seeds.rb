# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
## FIXME_NISH Don't delete users, roles etc. Instead use Role.find_or_create_by(name: 'super_admin')
User.delete_all
Role.delete_all
Role.create!(name: 'super_admin')
Role.create!(name: 'account_owner')
Role.create!(name: 'account_admin')
Role.create!(name: 'track_owner')
Role.create!(name: 'task_reviewer')
Role.create!(name: 'track_runner')
User.new(name: 'tanmay', email: 'tanmay@vinsol.com', password: 'vinsol123').save(validate: false)
User.find_by(email: 'tanmay@vinsol.com').add_role 'super_admin'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.delete_all
Role.delete_all
Company.delete_all
Role.create!(name: 'super_admin')
Role.create!(name: 'account_owner')
Role.create!(name: 'account_admin')
Role.create!(name: 'track_owner')
Role.create!(name: 'task_reviewer')
Role.create!(name: 'track_runner')
User.create!(name: 'tanmay', email: 'tanmay@vinsol.com', password: 'vinsol123')
User.first.add_role 'super_admin'

## FIXED
## FIXME_NISH Don't delete users, roles etc. Instead use Role.find_or_create_by(name: 'super_admin')
Role.find_or_create_by!(name: 'super_admin')
Role.find_or_create_by!(name: 'account_owner')
Role.find_or_create_by!(name: 'account_admin')
Role.find_or_create_by!(name: 'track_owner')
Role.find_or_create_by!(name: 'task_reviewer')
Role.find_or_create_by!(name: 'track_runner')
User.new(name: 'tanmay', email: 'tanmay@vinsol.com', password: 'vinsol123').save!(validate: false)
User.find_by(email: 'tanmay@vinsol.com').add_role 'super_admin'

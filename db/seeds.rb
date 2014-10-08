## FIXED
## FIXME_NISH Don't delete users, roles etc. Instead use Role.find_or_create_by(name: 'super_admin')
roles = ['super_admin', 'account_owner', 'account_admin', 'track_owner', 'track_runner', 'task_reviewer']
roles.each do |role|
  Role.find_or_create_by!(name: role)
end
User.create!(name: 'tanmay', email: 'tanmay@vinsol.com', password: 'vinsol123').add_role 'super_admin'

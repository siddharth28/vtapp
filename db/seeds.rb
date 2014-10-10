## FIXED
## FIXME_NISH Don't delete users, roles etc. Instead use Role.find_or_create_by(name: 'super_admin')
#FIXME_AB: Don't commit and push unwanted files like tmp file and log files. 
roles = ['super_admin', 'account_owner', 'account_admin', 'track_owner', 'track_runner', 'task_reviewer']
#FIXME_AB: I don't think we need to create all these roles. Because only super_admin would be a global role. And to assign any role, it is not necessary that role should be present in model. Apart from super_admin all roles would be resource specific. Kindly checkout rollify gem's doc.
roles.each do |role|
  Role.find_or_create_by!(name: role)
end
super_admin = User.new(name: 'tanmay', email: 'tanmay@vinsol.com', password: 'vinsol123')
#FIXME_AB: why validate set to be false
super_admin.save(validate: false)
super_admin.add_role(:super_admin)

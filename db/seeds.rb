#FIXED
#FIXME_AB: Don't commit and push unwanted files like tmp file and log files.
# roles = ['super_admin', 'account_owner', 'account_admin', 'track_owner', 'track_runner', 'task_reviewer']
#FIXME_AB: I don't think we need to create all these roles. Because only super_admin would be a global role. And to assign any role, it is not necessary that role should be present in model. Apart from super_admin all roles would be resource specific. Kindly checkout rollify gem's doc.
# roles.each do |role|
  Role.find_or_create_by!(name: 'super_admin')
# end
#FIXED
#FIXME_AB: why validate set to be false
super_admin = User.new(name: 'Super Admin', email: 'mailvtapp@gmail.com', password: 'superadmin123')
super_admin.add_role(:super_admin)

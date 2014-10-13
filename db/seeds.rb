Role.find_or_create_by!(name: 'super_admin')
super_admin = User.new(name: 'Super Admin', email: 'mailvtapp@gmail.com', password: 'superadmin123')
super_admin.add_role(:super_admin)

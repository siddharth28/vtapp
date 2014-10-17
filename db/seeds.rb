super_admin = User.new(name: 'Super Admin', email: 'mailvtapp@gmail.com', password: 'superadmin123')
super_admin.save(validate: false)
super_admin.add_role(:super_admin)

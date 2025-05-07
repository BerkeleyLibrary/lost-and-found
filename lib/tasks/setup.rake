namespace :setup do
  desc 'Create an admin user'
  task :admin, %i[uid name] => :environment do |_, args|
    User.create(
      uid: args.uid,
      user_name: args.name,
      user_role: User::ROLE_ADMIN,
      user_active: true
    )
  end
end

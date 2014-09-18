module LdapOuToGroup
  module InstanceMethods
    def authenticate_with_sync_ou_to_group(login, password)
      result = authenticate_without_sync_ou_to_group(login, password)
      return nil unless result
      attrs = get_user_dn(login, password)      
      if (user = User.find_by_login(login))
        ous = parse_ou_from_dn(attrs[:dn])
        sync_ou_to_group(user, ous) 
      end
      attrs
      return result
    end

    def parse_ou_from_dn(str)
      # The str looks like the following line
      # CN=zhangyi,OU=研发平台,OU=流程管理,OU=FFFF,OU=研发中心,OU=MMMM,DC=MMMMM,DC=com
      str.split(/,\s*/).select{|i| i =~ /^OU=.+$/i}.map{|s| s[3, s.size]}
    end
        
    def sync_ou_to_group(user, ous)
      member_of_groups = user.groups.map{|g|g.name}
      ous.each do |ou|
        next if member_of_groups.include?(ou)
        group = try_to_create_group_from_ou(ou)
        user.groups << group 
      end
    end

    def try_to_create_group_from_ou(ou)
      unless (g = Group.find_by_lastname(ou))
        g = Group.new
        g.lastname = ou
        g.auth_source_id = self.id
        g.save!
      end
      g
    end
  end

  def self.included(receiver)
    receiver.send(:include, InstanceMethods)
    receiver.send(:alias_method_chain, :authenticate, :sync_ou_to_group)
  end
end

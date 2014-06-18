# t.template_str
# CPU="0.2"
# VCPU="2"
# MEMORY="2048"
# SCHED_REQUIREMENTS="NFS=\"true\""
# SCHED_DS_REQUIREMENTS="NAME=\"local\""
# DISK=[
#     DEV_PREFIX="vd",
#     DRIVER="qcow2",
#     IMAGE="base",
#     IMAGE_ID="355",
#     IMAGE_UNAME="oneadmin",
#     TARGET="vda" ]
# GRAPHICS=[
#     LISTEN="0.0.0.0",
#      TYPE="VNC" ]
# NIC=[
#     MODEL="virtio",
#     NETWORK="vlan2-2",
#     NETWORK_UNAME="oneadmin" ]
# OS=[
#     ARCH="x86_64",
#     BOOT="network,hd" ]


module Fog
  module Compute
    class OpenNebula
      class Real
        def template_pool(filter = { })

          templates = ::OpenNebula::TemplatePool.new(client)
          if filter[:id].nil?
            templates.info!(-2,-1,-1)
          elsif filter[:id]
            filter[:id] = filter[:id].to_i if filter[:id].is_a?(String)
            templates.info!(-2, filter[:id], filter[:id])
          end # if filter[:id].nil?

          templates = templates.map do |t| 
            # filtering by name
            # done here, because OpenNebula:TemplatePool does not support something like .delete_if
            if filter[:name] && filter[:name].is_a?(String) && !filter[:name].empty?
                next if t.to_hash["VMTEMPLATE"]["NAME"] != filter[:name]
            end

            h = Hash[
              :id => t.to_hash["VMTEMPLATE"]["ID"], 
              :name => t.to_hash["VMTEMPLATE"]["NAME"], 
              :content => t.template_str
            ]
            h.merge! t.to_hash["VMTEMPLATE"]["TEMPLATE"]

            # h["NIC"] has to be an array of nic objects
            nics = h["NIC"] unless h["NIC"].nil?
            #Fog::Logger.info("template_pool: Found NIC: #{nics.inspect}")
            h["NIC"] = [] # reset nics to a array
            if nics.is_a? Array
              nics.each do |n|
                if n["NETWORK_ID"]
                  vnet = networks.get(n["NETWORK_ID"].to_s)
                elsif n["NETWORK"]
                  vnet = networks.get_by_name(n["NETWORK"].to_s)
                else 
                  #Fog::Logger.info("template_pool: Could not identify the NETWORK within the flavor #{h[:name]}")
                  next
                end
                h["NIC"] << interfaces.new({ :vnet => vnet, :model => n["MODEL"] || "virtio" })
                #Fog::Logger.info("template_pool: Added nic #{h['NIC'].last} to the flavor #{h[:name]}")
              end
            elsif nics.is_a? Hash
              #Fog::Logger.info("template_pool: nic is a hash: #{nics.inspect}")
              if nics["NETWORK_ID"]
                vnet = networks.get(nics["NETWORK_ID"].to_s)
              elsif nics["NETWORK"]
                vnet = networks.get_by_name(nics["NETWORK"].to_s)
              else
                #Fog::Logger.info("template_pool: Could not identify the NETWORK within the flavor #{h[:name]}")
                next
              end
              h["NIC"] << interfaces.new({ :vnet => vnet, :model => nics["model"]})
              #Fog::Logger.info("template_pool: Added nic #{h['NIC'].last} to the flavor #{h[:name]}")
            else
              # should i break?
            end
          
            # every key should be lowercase
            ret_hash = {}
            h.each_pair do |k,v| 
              ret_hash.merge!({k.downcase => v}) 
            end
            #Fog::Logger.info("ret_h: #{ret_hash}")
            ret_hash
          end
          
          templates.delete nil
          raise Fog::Compute::OpenNebula::NotFound, "Flavor/Template not found" if templates.empty?
          #Fog::Logger.info("template_pool: #{templates.inspect}")
          templates
        end #def template_pool
      end #class Real

      class Mock
        def template_pool(filter = { })

          nic1 = Mock_nic.new
          nic1.vnet = networks.first
          [ 
            {
              :id       => "4", 
              :name     => "fogtest", 
              :content  => "CPU=\"0.1\"\nDISK=[\n  IMAGE=\"tt\",\n  IMAGE_UNAME=\"oneadmin\" ]\nDISK=[\n  IMAGE=\"testimage\",\n  IMAGE_UNAME=\"oneadmin\" ]\nGRAPHICS=[\n  LISTEN=\"0.0.0.0\",\n  TYPE=\"VNC\" ]\nMEMORY=\"126\"\nNIC=[\n  NETWORK=\"fogtest\",\n  NETWORK_UNAME=\"oneadmin\" ]\nOS=[\n  ARCH=\"x86_64\" ]\nSCHED_REQUIREMENTS=\"NFS=true\"\nVCPU=\"2\"", "cpu"=>"0.1",
              "disk" => [{"IMAGE"=>"tt", "IMAGE_UNAME"=>"oneadmin"}, {"IMAGE"=>"testimage", "IMAGE_UNAME"=>"oneadmin"}],
              "graphics"=>{"LISTEN"=>"0.0.0.0", "TYPE"=>"VNC"},
              "memory"=>"126",
              "sched_requirements"=>"NFS=true",
              "vcpu"=>"2",
              "nic" => [ nic1 ] ,
              "os" => "crux"
            }
          ]
        end

        class Mock_nic 
          attr_accessor :vnet

          def id
            2
          end
          def name
            "fogtest"
          end

        end
      end #class Mock
    end #class OpenNebula
  end #module Compute
end #module Fog

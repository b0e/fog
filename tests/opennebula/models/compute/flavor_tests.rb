Shindo.tests('Fog::Compute[:opennebula] | flavor model', ['opennebula']) do

  flavors = Fog::Compute[:opennebula].flavors.get_by_name "fogtest"
  flavor = flavors.first

  tests('The flavor model should') do
    test('be a kind of Fog::Compute::OpenNebula::Flavor') { flavor.kind_of? Fog::Compute::OpenNebula::Flavor }
    tests('have the action') do
      test('reload') { flavor.respond_to? 'reload' }
    end

    tests('have attributes') do
      model_attribute_hash = flavor.attributes
      attributes = 
        tests("The flavor model should respond to") do
          [ :to_label, 
            :to_s, 
            :get_cpu, 
            :get_vcpu, 
            :get_memory, 
            :get_raw, 
            :get_disk, 
            :get_os, 
            :get_graphics, 
            :get_nic, 
            :get_sched_ds_requirements, 
            :get_sched_ds_rank, 
            :get_sched_requirements, 
            :get_sched_rank
          ].each do |attribute|
            test("#{attribute}") { flavor.respond_to? attribute }
          end
        end
      tests("The attributes hash should have key") do
          [ :name, 
            :id, 
            :content, 
            :cpu, 
            :vcpu, 
            :memory, 
            :disk, 
            :nic, 
            :os, 
            :graphics, 
            #:raw, 
            :sched_requirements, 
            #:sched_rank, 
            #:sched_ds_requirements, 
            #:sched_ds_rank
          ].each do |attribute|
          test("#{attribute}") { model_attribute_hash.has_key? attribute }
        end
      end
    end

    test('have a nic in network fogtest') { flavor.nic[0].vnet.name == "fogtest" }

  end

end
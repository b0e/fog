Shindo.tests('Fog::Compute[:opennebula] | flavors collection', ['opennebula']) do

  flavors = Fog::Compute[:opennebula].flavors

  tests('The flavors collection') do
    test('should be a kind of Fog::Compute::OpenNebula::Flavors') { flavors.kind_of? Fog::Compute::OpenNebula::Flavors }
    tests('should be able to reload itself').succeeds { flavors.reload }
    tests('should be able to get a model') do
      tests('by instance id').succeeds { flavors.get flavors.first.id }
      tests('by name').succeeds { flavors.get_by_name "fogtest" }
    end
  end
end

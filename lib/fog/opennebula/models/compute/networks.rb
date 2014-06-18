require 'fog/core/collection'
require 'fog/opennebula/models/compute/network'

module Fog
  module Compute
    class OpenNebula
      class Networks < Fog::Collection
        model Fog::Compute::OpenNebula::Network

        def all
          data = service.list_networks
          load(data)
        end

        def get(id)
          data = service.list_networks({:id => id})
          load(data).first
        rescue Fog::Compute::OpenNebula::NotFound
          nil
        end

        def get_by_name(name)
          data = service.list_networks({:name => name})
          load(data).first
        rescue Fog::Compute::OpenNebula::NotFound
          nil
        end

      end
    end
  end
end

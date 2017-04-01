module Api
  module Helpers
    module Json
      def json(resource, opts = {})
        data = serialize(resource, opts)

        MultiJson.dump(data)
      end

      def serialize(resource, opts = {})
        if resource.is_a?(Sequel::Dataset) || (resource.is_a?(Array) && resource[0].is_a?(Sequel::Model))
          JSONAPI::Serializer.serialize(resource, opts.merge(is_collection: true))
        elsif resource.is_a?(Sequel::Model)
          JSONAPI::Serializer.serialize(resource, opts.merge(skip_collection_check: true))
        elsif resource.is_a?(Hash)
          resource.merge(opts)
        else
          resource
        end
      end

      def page_meta(object, extra_meta = {})
        {
          current_page: object.current_page,
          next_page: object.next_page,
          prev_page: object.prev_page,
          total_pages: object.page_count,
          total_count: object.pagination_record_count
        }.merge(extra_meta)
      end

      def params
        super.with_indifferent_access
      end
    end
  end
end

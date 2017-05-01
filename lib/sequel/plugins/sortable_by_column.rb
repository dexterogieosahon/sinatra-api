module Sequel
  module Plugins
    module SortableByColumn
      module ClassMethods
        Sequel::Plugins.def_dataset_methods(self, :sort_by_column)
      end

      module DatasetMethods
        def sort_by_column(column, sort_order=nil, allowed_cols:)
          return order(:created_at) if column.blank?

          if allowed_cols.include?(column.to_sym)
            if String(sort_order).downcase == "desc"
              order(Sequel.desc(column.to_sym))
            else
              order(column.to_sym)
            end
          else
            raise BadRequest, "Sort by column `#{column}` not permitted. Permitted columns #{allowed_cols.to_sentence}"
          end
        end
      end

      class BadRequest < StandardError; end
    end
  end
end
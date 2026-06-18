module ListField
  module Schemas
    # Matches `rails generate model --help` "Available field types" plus digest/token specials.
    RAILS_COLUMN_TYPES = %w[
      string text integer boolean references decimal float
      date datetime time binary primary_key digest token
    ].freeze

    LIMIT_TYPES = %w[integer string text binary decimal].freeze

    module_function

    def rails_attribute(output_id: "columns", add_label: "Add column")
      {
        output_id: output_id,
        add_label: add_label,
        format: "rails_attribute",
        row_layout: "grid grid-cols-12 gap-2 items-center",
        row: [
          { key: "name", control: "text", placeholder: "title", column_class: "col-span-3" },
          { key: "type", control: "select", column_class: "col-span-3", values: RAILS_COLUMN_TYPES },
          {
            key: "limit",
            control: "text",
            placeholder: "limit e.g. 30",
            column_class: "col-span-2",
            show_for_types: LIMIT_TYPES,
            placeholders: { decimal: "10,2" }
          },
          {
            key: "polymorphic",
            control: "checkbox",
            label: "Polymorphic",
            column_class: "col-span-2 flex",
            show_for_types: %w[references]
          },
          {
            key: "index",
            control: "select",
            column_class: "col-span-2",
            values: ["", "index", "uniq"],
            labels: { "" => "No index", "index" => "index", "uniq" => "uniq" }
          }
        ]
      }
    end

    def space_separated(output_id: "actions", add_label: "Add action", placeholder: "index")
      {
        output_id: output_id,
        add_label: add_label,
        format: "space_separated",
        row_layout: "flex gap-2 items-center",
        row: [
          { key: "name", control: "text", placeholder: placeholder, column_class: "flex-1" }
        ]
      }
    end
  end
end

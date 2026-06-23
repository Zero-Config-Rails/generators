# frozen_string_literal: true

module RailsGenerate
  class HelpParser
    GEM_INJECTED_OPTIONS = %w[avo-resource].freeze
    IGNORED_OPTIONS = %w[name].freeze
    OPTIONS_WITHOUT_MACHINE_DEFAULT = %w[ruby].freeze
    SECTION_HEADER = /\A(.+ )?options:\z/i
    STOP_SECTIONS = /\A(Description|Examples|Runtime options|Available field types):/i

    def initialize(help_output)
      @lines = help_output.lines.map(&:strip)
    end

    def option_keys
      parse_configurations.map { |c| c[:configuration_key] }
    end

    def parse_configurations
      option_lines = collect_option_lines
      parse_option_lines(option_lines)
    end

    private

    def collect_option_lines
      lines = []
      in_options = false

      @lines.each do |line|
        if STOP_SECTIONS.match?(line)
          in_options = false
          next
        end

        if line == "Options:" || SECTION_HEADER.match?(line)
          in_options = true
          next
        end

        lines << line if in_options && line.present?
      end

      lines
    end

    def parse_option_lines(lines)
      configurations = []
      current_option = nil
      current_description = []

      lines.each do |line|
        if option_line?(line)
          if current_option
            configurations << build_configuration(current_option, current_description.join(" "))
          end

          current_option = extract_option_names(line)
          current_description = [extract_description(line)].compact
        elsif current_option && !line.start_with?("Default:", "Possible values:")
          current_description << line
        end
      end

      if current_option
        configurations << build_configuration(current_option, current_description.join(" "))
      end

      configurations.compact.reject do |config|
        ignored_option?(config[:configuration_key])
      end
    end

    def option_line?(line)
      line.match?(/\[--/)
    end

    def extract_option_names(line)
      line.scan(/\[--([^\]]+)\]/).flatten.map { |name| name.split("=").first }
    end

    def extract_description(line)
      line.match(/#\s*(.+)/)&.captures&.first&.strip
    end

    def build_configuration(option_names, description)
      return nil if option_names.empty?

      canonical_key = canonical_option_key(option_names)
      return nil if gem_injected?(canonical_key)

      default_value = extract_default_value(description)
      default_value = nil if machine_local_default?(canonical_key, default_value)
      field_type = determine_field_type(canonical_key, description, option_names)
      flag_format, negative_prefix = determine_flag_format(canonical_key, option_names, default_value, field_type)

      {
        configuration_key: canonical_key,
        description: clean_description(description),
        is_required: false,
        fieldable_name: field_type,
        fieldable: build_fieldable(field_type, description, default_value),
        default_value: default_value,
        flag_format: flag_format,
        negative_prefix: negative_prefix
      }
    end

    def canonical_option_key(option_names)
      base_names = option_names.reject { |name| name.start_with?("no-", "skip-") }
      return base_names.first if base_names.any?

      option_names.find { |name| name.start_with?("skip-") } || option_names.first
    end

    def gem_injected?(key)
      GEM_INJECTED_OPTIONS.include?(key)
    end

    def ignored_option?(key)
      IGNORED_OPTIONS.include?(key)
    end

    def determine_field_type(option_name, description, option_names)
      return "dropdown_field" if description.include?("Possible values:")
      return "dropdown_field" if %w[database javascript css].include?(option_name)
      return "text_field" if value_option?(option_names)

      if boolean_option?(option_name, description, option_names)
        "boolean_field"
      elsif description.include?("Path to") || description.include?("Name of")
        "text_field"
      else
        "boolean_field"
      end
    end

    def value_option?(option_names)
      option_names.any? { |name| name.include?("=") || name.match?(/\A[a-z-]+\z/) && %w[orm template-engine test-framework database primary-key-type model-name scaffold-controller fixture-replacement integration-tool system-tests queue parent].include?(name) }
    end

    def boolean_option?(option_name, description, option_names)
      option_name.include?("skip-") || option_name.include?("no-") ||
        option_name == "api" || option_names.length > 1 ||
        description.match?(/Indicates when to/) ||
        %w[force-plural resource-route helper migration timestamps indexes fixture jbuilder assets avo-resource namespace].include?(option_name)
    end

    def determine_flag_format(option_name, option_names, default_value, field_type)
      return ["value", nil] if field_type != "boolean_field"

      if default_value == "true"
        prefix = option_names.any? { |n| n.start_with?("skip-") } ? "skip" : "no"
        ["negative_boolean", prefix]
      elsif option_name.start_with?("skip-")
        ["positive_boolean", nil]
      else
        ["positive_boolean", nil]
      end
    end

    def extract_default_value(description)
      match = description.match(/Default:\s*([^\s,#]+)/)
      match ? match[1] : nil
    end

    def machine_local_default?(key, value)
      return false if value.blank?

      OPTIONS_WITHOUT_MACHINE_DEFAULT.include?(key) ||
        (value.start_with?("/") && value.end_with?("/ruby"))
    end

    def extract_dropdown_options(description)
      match = description.match(/Possible values:\s*(.+)/)
      return unless match

      match[1].split(",").map(&:strip).map { |v| [v, v.titleize] }
    end

    def clean_description(description)
      description
        .gsub(/Default:\s*[^\s,#]+/, "")
        .gsub(/Possible values:\s*[^#]+/, "")
        .strip
        .gsub(/\s+/, " ")
    end

    def build_fieldable(field_type, description, default_value)
      case field_type
      when "boolean_field"
        default_bool =
          if default_value == "true"
            true
          elsif default_value == "false"
            false
          else
            false
          end
        { type: "boolean_field", default_value: default_bool }
      when "dropdown_field"
        { type: "dropdown_field", options: extract_dropdown_options(description), default_value: default_value }
      else
        { type: "text_field", default_value: default_value || "" }
      end
    end
  end
end

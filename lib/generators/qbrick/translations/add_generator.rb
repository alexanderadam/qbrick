require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'

module Qbrick
  module Translations
    class Add < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root(File.join(Qbrick::Engine.root, '/lib/templates/qbrick/translations'))
      argument :locale, type: :string

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def translated_columns
        Qbrick::Page.column_names.select { |attr| attr.end_with? "_#{I18n.default_locale}" }
      end

      def formatted_locale
        locale.underscore
      end

      def create_locale_migration_file
        migration_template('add_translation.erb',
                           Rails.root.join('db', 'migrate', "add_#{formatted_locale}_translation.rb"))
      end

      private

      def get_attribute(attribute_name = '')
        attribute_name.gsub("_#{I18n.default_locale}", "_#{formatted_locale}")
      end

      def get_type(key = '')
        Qbrick::Page.columns_hash[key].type
      end
    end
  end
end

# encoding: UTF-8

require 'thread'
require 'json'
require 'fileutils'

module Rosette
  module Tms
    module FilestoreTms

      class TranslationStore < Store
        attr_reader :path, :locale, :pairs

        def initialize(configurator, locale)
          @locale = locale

          @path = File.join(
            configurator.store_path,
            filesystem_sanitize(configurator.repo_config.name),
            filesystem_sanitize("translation-store-#{locale.code}.json")
          )

          @write_mutex = Mutex.new
          load_pairs
        end

        def set(key, value)
          pairs[key] = value
          flush
        end

        def get(key)
          pairs[key]
        end

        def serialize
          pairs.to_json
        end

        def delete
          File.unlink(path) if File.exist?(path)
        end

        def translation_count
          pairs.size
        end

        protected

        def flush
          @write_mutex.synchronize do
            FileUtils.mkdir_p(File.dirname(path))
            File.open(path, 'w+') do |f|
              f.write(serialize)
            end
          end
        end

        def load_pairs
          @pairs = if File.exist?(path)
            JSON.parse(File.read(path))
          else
            {}
          end
        end
      end

    end
  end
end

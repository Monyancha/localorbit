module ProductImport
  module FileImporters
    class StandardTemplate < Framework::FileImporter
      PROFILES = {
        "birite" => {
          market_id: 130,
          # product_code_required: true,
        },
        "greenleaf" => {
          market_id: 125,
          # product_code_required: true,
        },
      }

      def initialize(opts={})
        super

        profile_name = opts[:profile]
        if profile_name.present?
          if PROFILES.key?(profile_name)
            opts.reverse_merge! PROFILES[profile_name]
          else
            raise ArgumentError, "Didn't know of a market profile called #{profile_name}. Add it to PROFILES in this file."
          end
        end

      end

      # if any of these are missing, don't even try to process the file
      REQUIRED_HEADERS = [
        'Product Name',
        'Category Name',
        'Unit Name',
        'Unit Description (optional)',
        'Supplier Product Number',
        'Price'
      ]

      # See lib/product_import/formats for supported formats
      format :xlsx

      # This stage is responsible for transforming raw data from
      # the format reader into basic sequence of hashes.
      #
      # Any rejection in this stage causes the entire file to
      # be rejected
      stage :extract do |s|

        s.transform :from_flat_table,
          headers: true,
          required_headers: REQUIRED_HEADERS

      end

      # This stage transforms the output of the extract stage
      # into the canonical format. Any rejected row is not imported
      # and saved for processing/triage.
      stage :canonicalize do |s|

        s.transform :set_keys, map: { "unit" => "Each" }

        s.transform :alias_keys,
          key_map: {
            "Product Name" => "name",
            "Seller Name" => "organization",
            "Supplier Product Number" => "product_code",
            "Price" => "price",
            "Unit Description (optional)" => "unit_description",
            "Unit Name" => "unit",
            "Category Name" => "category",
          }


        # provide default values and validate that we've generated
        # canonical data.
        s.transform :ensure_canonical_data

      end
    end
  end
end

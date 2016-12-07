require 'active_model/validations'

# ActiveModel module.
module ActiveModel

  # ActiveModel::Validations module. Contains all the default validators.
  module Validations

    # Here start the implementation of CUIT/CUIL validator
    class CuitValidator < ActiveModel::EachValidator

      def validate_each(record, attr_name, value)
        return if detect_any_failure_in :length, :digits, :dni_compatibility, :gender_compatibility, :v_digit,
          data: [ record, attr_name, value ]
      end

      protected

      # Sugar, turutu-tu-tuut-tu, ohhh, honey, honey
      def detect_any_failure_in(*properties, data: [])
        properties.detect { |prop| send "check_#{prop}_failure", *data }
      end

      def check_length_failure(record, attr_name, value)
        type, dni, v_digit = separate_cuit_groups value
        unless type.length == 2 && dni.length == 8 && v_digit.length == 1
          record.errors.add(attr_name, :cuit_invalid_format)
        end
      end

      def check_digits_failure(record, attr_name, value)
        type, dni, v_digit = separate_cuit_groups value
        unless (type + dni + v_digit) =~ /\A\d+\Z/
          record.errors.add(attr_name, :cuit_invalid_format)
        end
      end

      def check_dni_compatibility_failure(record, attr_name, value)
        _, dni, _ = separate_cuit_groups value
        unless !options[:dni_compatible].present? || record.public_send(options[:dni_compatible]) == dni
          record.errors.add(attr_name, :cuit_dni_incompatible)
        end
      end

      def check_gender_compatibility_failure(record, attr_name, value)
        type, _, _ = separate_cuit_groups value

        if options[:gender_compatible].present?
          unless gender_validation_passing?(record, type)
            record.errors.add(attr_name, :cuit_gender_incompatible)
          end
        end
      end

      def check_v_digit_failure(record, attr_name, value)
        type, dni, v_digit = separate_cuit_groups value
        unless v_digit.to_i == compute_v_digit(type, dni)
          record.errors.add(attr_name, :cuit_invalid_v_digit)
        end
      end

      # AFIP dependent logic. Trust or die
      def compute_v_digit(type, dni)
        sequence = [2,3,4,5,6,7,2,3,4,5].reverse
        precomputed_v_digit = 11 - (type + dni)
          .chars
          .each_with_index
          .inject(0) do |acc, (n, i)|
            acc + n.to_i * sequence[i]
          end % 11

        case precomputed_v_digit
        when 11
          0
        when 10
          9
        else
          precomputed_v_digit
        end
      end

      def separate_cuit_groups(cuit)
        separator = options[:separator]
        cuit = cuit.to_s
        if separator
          cuit.split(separator).first 3
        else
          # Take standard CUIT/CUIL layout (2 digit, 8 digit, 1 digit)
          [ cuit[0..1], cuit[2..9], cuit[10] ]
        end.map(&:to_s)
      end

      def gender_validation_passing?(record, type)
        raise ArgumentError, 'Valicuit: gender field specification must be present!' unless options[:gender_compatible][:field].present?
        raise ArgumentError, 'Valicuit: declaration of male value missing!'          unless options[:gender_compatible][:male].present?
        raise ArgumentError, 'Valicuit: declaration of female value missing!'        unless options[:gender_compatible][:female].present?
        gender = case type
                 when '20'
                   options[:gender_compatible][:male]
                 when '27'
                   options[:gender_compatible][:female]
                 when '30', '33'
                   options[:gender_compatible][:company] || :pass
                 when '23', '24', '25', '26'
                   :pass
                 else
                   :dont_pass
                 end

        gender == :pass ? true : gender == record.public_send(options[:gender_compatible][:field])
      end
    end

    # CUIT/CUIL is the same for the purposes of validation
    CuilValidator = CuitValidator
  end
end

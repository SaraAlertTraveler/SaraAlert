# frozen_string_literal: true

require 'roo'

# ImportController: for importing subjects from other formats
class ImportController < ApplicationController
  include ImportExportHelper
  include PatientHelper

  before_action :authenticate_user!

  def index
    redirect_to(root_url) && return unless current_user.can_import?
  end

  def error
    @error_msg = params[:error_details]
  end

  def download_guidance
    send_file(
      "#{Rails.root}/public/sara_alert_comprehensive_monitoree.xlsx",
      filename: 'sara_alert_comprehensive_monitoree.xlsx',
      type: 'application/vnd.ms-excel'
    )
  end

  def import
    redirect_to(root_url) && return unless current_user.can_import?

    redirect_to(root_url) && return unless params.permit(:workflow)[:workflow] == 'exposure' || params.permit(:workflow)[:workflow] == 'isolation'

    redirect_to(root_url) && return unless params.permit(:format)[:format] == 'epix' || params.permit(:format)[:format] == 'comprehensive_monitorees'

    workflow = params.permit(:workflow)[:workflow].to_sym
    format = params.permit(:format)[:format].to_sym

    jurisdiction_paths = Hash[current_user.jurisdiction.subtree.pluck(:id, :path).map { |id, path| [id, path] }]

    @errors = []
    @patients = []

    # Load and parse patient import excel
    begin
      xlsx = Roo::Excelx.new(params[:file].tempfile.path, file_warning: :ignore)
      validate_headers(format, xlsx.sheet(0).row(1))
      raise ValidationError.new('File must contain at least one monitoree to import', 2) if xlsx.sheet(0).last_row < 2

      xlsx.sheet(0).each_with_index do |row, row_num|
        next if row_num.zero? # Skip headers

        fields = format == :epix ? EPI_X_FIELDS : COMPREHENSIVE_FIELDS
        patient = { isolation: workflow == :isolation }
        fields.each_with_index do |field, col_num|
          next if field.nil?

          begin
            if format == :comprehensive_monitorees
              if col_num == 95
                patient[:jurisdiction_id] = validate_jurisdiction(row[95], row_num, jurisdiction_paths)
              else
                patient[field] = validate_field(field, row[col_num], row_num) unless [85, 86].include?(col_num) && workflow != :isolation
              end
            end

            if format == :epix
              patient[field] = if col_num == 34 # copy over potential exposure country to location
                                 validate_field(field, row[35], row_num)
                               elsif [41, 42].include?(col_num) # contact of known case and was in healthcare facilities
                                 validate_field(field, !row[col_num].blank?, row_num)
                               else
                                 validate_field(field, row[col_num], row_num)
                               end
            end
          rescue ValidationError => e
            @errors << e&.message || "Unknown error on row #{row_num}"
          rescue StandardError => e
            @errors << e&.message || 'Unexpected error'
          end
        end

        # Run validations on fields that have restrictions conditional on other fields
        begin
          validate_address(patient, row_num)
          validate_required_primary_contact(patient, row_num)
        rescue ValidationError => e
          @errors << e&.message || "Unknown error on row #{row_num}"
        rescue StandardError => e
          @errors << e&.message || 'Unexpected error'
        end
        patient[:appears_to_be_duplicate] = current_user.viewable_patients.matches(patient[:first_name],
                                                                                   patient[:last_name],
                                                                                   patient[:sex],
                                                                                   patient[:date_of_birth],
                                                                                   patient[:user_defined_id_statelocal]).exists?

        if format == :comprehensive_monitorees
          lab_results = []
          lab_results.push(lab_result(row[87..90], row_num)) if !row[87].blank? || !row[88].blank? || !row[89].blank? || !row[90].blank?
          lab_results.push(lab_result(row[91..94], row_num)) if !row[91].blank? || !row[92].blank? || !row[93].blank? || !row[94].blank?
          patient[:laboratories] = lab_results unless lab_results.empty?
        end

        @patients << patient
      end
    rescue ValidationError => e
      @errors << e&.message || "Unknown error on row #{row_num}"
    rescue Zip::Error
      # Roo throws this if the file is not an excel file
      @errors << 'File Error: Please make sure that your import file is a .xlsx file.'
    rescue ArgumentError, NoMethodError
      # Roo throws this error when the columns are not what we expect
      @errors << 'Format Error: Please make sure that .xlsx import file is formatted in accordance with the formatting guidance.'
    rescue StandardError => e
      # This is a catch all for any other unexpected error
      @errors << "Unexpected Error: '#{e&.message}' Please make sure that .xlsx import file is formatted in accordance with the formatting guidance."
    end
  end

  def lab_result(data, row_num)
    {
      lab_type: data[0],
      specimen_collection: validate_field(:specimen_collection, data[1], row_num),
      report: validate_field(:report, data[2], row_num),
      result: data[3]
    }
  end

  private

  def validate_headers(format, row)
    if format == :comprehensive_monitorees
      COMPREHENSIVE_HEADERS.each_with_index do |field, col_num|
        err_msg = "Invalid headers, please make sure to use the latest format specified by the guidance doc. Header field name mismatch: #{field}"
        raise ValidationError.new(err_msg, 1) if field != row[col_num]
      end
    elsif format == :epix
      EPI_X_HEADERS.each_with_index do |field, col_num|
        err_msg = "Invalid headers, please make sure to use the latest epi-x format. Header field name mismatch: #{field}"
        raise ValidationError.new(err_msg, 1) if field != row[col_num]
      end
    end
  end

  def validate_field(field, value, row_num)
    return value unless VALIDATION[field]

    # TODO: Un-comment when required fields are to be checked upon import
    # value = validate_required_field(field, value, row_num) if VALIDATION[field][:checks].include?(:required)
    value = validate_enum_field(field, value, row_num) if VALIDATION[field][:checks].include?(:enum)
    value = validate_bool_field(field, value, row_num) if VALIDATION[field][:checks].include?(:bool)
    value = validate_date_field(field, value, row_num) if VALIDATION[field][:checks].include?(:date)
    value = validate_phone_field(field, value, row_num) if VALIDATION[field][:checks].include?(:phone)
    value = validate_state_field(field, value, row_num) if VALIDATION[field][:checks].include?(:state)
    value = validate_sex_field(field, value, row_num) if VALIDATION[field][:checks].include?(:sex)
    value = validate_email_field(field, value, row_num) if VALIDATION[field][:checks].include?(:email)
    value = validate_group_field(value, row_num) if VALIDATION[field][:checks].include?(:group)
    value
  end

  def validate_required_field(field, value, row_num)
    raise ValidationError.new("Required field '#{VALIDATION[field][:label]}' is missing", row_num) if value.blank?

    value
  end

  def validate_enum_field(field, value, row_num)
    return nil if value.blank?
    return value if VALID_ENUMS[field].include?(value)

    err_msg = "#{value} is not one of the accepted values for field '#{VALIDATION[field][:label]}', acceptable values are: #{VALID_ENUMS[field].to_sentence}"
    raise ValidationError.new(err_msg, row_num)
  end

  def validate_bool_field(field, value, row_num)
    return value if value.blank?
    return (value.to_s.downcase == 'true') if %w[true false].include?(value.to_s.downcase)

    err_msg = "#{value} is not one of the accepted values for field '#{VALIDATION[field][:label]}', acceptable values are: 'True' and 'False'"
    raise ValidationError.new(err_msg, row_num)
  end

  def validate_date_field(field, value, row_num)
    return nil if value.blank?
    return value if value.instance_of?(Date)

    begin
      Date.parse(value)
    rescue ArgumentError
      raise ValidationError.new("#{value} is not a valid date for field '#{VALIDATION[field][:label]}", row_num)
    end
  end

  def validate_phone_field(field, value, row_num)
    return nil if value.blank?

    normalized_phone = Phonelib.parse(value, 'US').full_e164
    return normalized_phone if normalized_phone

    raise ValidationError.new("#{value} is not a valid phone number for field '#{VALIDATION[field][:label]}'", row_num)
  end

  def validate_state_field(field, value, row_num)
    return nil if value.blank?
    return normalize_and_get_state_name(value) if VALID_STATES.include?(normalize_and_get_state_name(value))

    normalized_state = STATE_ABBREVIATIONS[value.upcase.to_sym]
    return normalized_state if normalized_state

    err_msg = "#{value} is not a valid state for field '#{VALIDATION[field][:label]}', please use the full state name or two letter abbreviation"
    raise ValidationError.new(err_msg, row_num)
  end

  def validate_sex_field(field, value, row_num)
    return nil if value.blank?
    return value if %w[Male Female Unknown].include?(value.capitalize)

    normalized_sex = SEX_ABBREVIATIONS[value.upcase.to_sym]
    return normalized_sex if normalized_sex

    raise ValidationError.new("#{value} is not a valid sex for field '#{VALIDATION[field][:label]}'", row_num)
  end

  def validate_email_field(field, value, row_num)
    return nil if value.blank?
    unless ValidEmail2::Address.new(value).valid?
      raise ValidationError.new("#{value} is not a valid Email Address for field '#{VALIDATION[field][:label]}'", row_num)
    end

    value
  end

  def validate_group_field(value, row_num)
    return nil if value.blank?

    return value.to_i if value.to_i.positive?

    raise ValidationError.new("#{value} is not a valid group number", row_num)
  end

  def validate_jurisdiction(value, row_num, jurisdiction_paths)
    return nil if value.blank?

    return jurisdiction_paths.key(value) if jurisdiction_paths.values.include?(value)

    raise ValidationError.new("#{value} is not a valid jurisdiction", row_num)
  end

  def validate_address(patient, row_num)
    return if (patient[:address_line_1] && patient[:address_city] && patient[:address_state] && patient[:address_zip]) ||
              (patient[:foreign_address_city] && patient[:foreign_address_country])

    raise ValidationError.new('Either an address (line 1, city, state, zip) or foreign address (city, country) must be provided', row_num)
  end

  def validate_required_primary_contact(patient, row_num)
    if patient[:email].blank? && patient[:preferred_contact_method] == 'E-mailed Web Link'
      raise ValidationError.new("Field 'Email' is required when Primary Contact Method is 'E-mailed Web Link'", row_num)
    end
    unless patient[:primary_telephone].blank? && (['SMS Texted Weblink', 'Telephone call', 'SMS Text-message'].include? patient[:preferred_contact_method])
      return
    end

    raise ValidationError.new("Field 'Primary Telephone' is required when Primary Contact Method is '#{patient[:preferred_contact_method]}'", row_num)
  end
end

# Exception used for reporting validation errors
class ValidationError < StandardError
  def initialize(message, row_num)
    super("Validation Error: #{message} in row #{row_num}")
  end
end

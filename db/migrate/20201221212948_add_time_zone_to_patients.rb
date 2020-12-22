class AddTimeZoneToPatients < ActiveRecord::Migration[6.0]
  def up
    # include PatientHelper
    # Default to -4 because if an address state is not set, -4 will be used anyway.
    # See Patient#address_timezone_offset and PatientHelper#timezone_for_state
    # add_column :patients, :time_zone, :string, default: 'America/New_York'

    # PatientHelper.time_zones.each_key do |state|
    #   # Following the logic of Patient#address_timezone_offset: 1) Monitored Address 2) Address State
    #   time_zone_for_state = time_zone_for_state(state)

    #   patients_in_state = Patient.where(purged: false, monitored_address_state: zone.first)
    #   patients_in_state.update_all(timezone_offset: offset_for_state)

    #   patients_in_state = Patient.where(purged: false, monitored_address_state: nil, address_state: zone.first)
    #   patients_in_state.update_all(timezone_offset: offset_for_state)
    # end
  end

  def down
    remove_column :patients, :time_zone_offset
  end
end

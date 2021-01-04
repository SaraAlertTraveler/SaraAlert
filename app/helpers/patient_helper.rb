# frozen_string_literal: true

# Helper methods for the patient model
module PatientHelper # rubocop:todo Metrics/ModuleLength
  # This list contains all of the same states listed in app/javascript/components/data.js

  def state_names
    {
      'alabama' => 'Alabama',
      'alaska' => 'Alaska',
      'americansamoa' => 'American Samoa',
      'arizona' => 'Arizona',
      'arkansas' => 'Arkansas',
      'california' => 'California',
      'colorado' => 'Colorado',
      'connecticut' => 'Connecticut',
      'delaware' => 'Delaware',
      'districtofcolumbia' => 'District of Columbia',
      'federatedstatesofmicronesia' => 'Federated States of Micronesia',
      'florida' => 'Florida',
      'georgia' => 'Georgia',
      'guam' => 'Guam',
      'hawaii' => 'Hawaii',
      'idaho' => 'Idaho',
      'illinois' => 'Illinois',
      'indiana' => 'Indiana',
      'iowa' => 'Iowa',
      'kansas' => 'Kansas',
      'kentucky' => 'Kentucky',
      'louisiana' => 'Louisiana',
      'maine' => 'Maine',
      'marshallislands' => 'Marshall Islands',
      'maryland' => 'Maryland',
      'massachusetts' => 'Massachusetts',
      'michigan' => 'Michigan',
      'minnesota' => 'Minnesota',
      'mississippi' => 'Mississippi',
      'missouri' => 'Missouri',
      'montana' => 'Montana',
      'nebraska' => 'Nebraska',
      'nevada' => 'Nevada',
      'newhampshire' => 'New Hampshire',
      'newjersey' => 'New Jersey',
      'newmexico' => 'New Mexico',
      'newyork' => 'New York',
      'northcarolina' => 'North Carolina',
      'northdakota' => 'North Dakota',
      'northernmarianaislands' => 'Northern Mariana Islands',
      'ohio' => 'Ohio',
      'oklahoma' => 'Oklahoma',
      'oregon' => 'Oregon',
      'palau' => 'Palau',
      'pennsylvania' => 'Pennsylvania',
      'puertorico' => 'Puerto Rico',
      'rhodeisland' => 'Rhode Island',
      'southcarolina' => 'South Carolina',
      'southdakota' => 'South Dakota',
      'tennessee' => 'Tennessee',
      'texas' => 'Texas',
      'utah' => 'Utah',
      'vermont' => 'Vermont',
      'virginislands' => 'Virgin Islands',
      'virginia' => 'Virginia',
      'washington' => 'Washington',
      'westvirginia' => 'West Virginia',
      'wisconsin' => 'Wisconsin',
      'wyoming' => 'Wyoming'
    }
  end

  # Offsets are DST
  # rubocop:disable Metrics/MethodLength
  def states_with_time_zone_data
    {
      'alabama' => {
        offset: -5,
        observes_dst: true,
        zone_name: 'America/Chicago'
      },
      'alaska' => {
        offset: -8,
        observes_dst: true,
        zone_name: 'America/Juneau'
      },
      'americansamoa' => {
        offset: -11,
        observes_dst: false,
        zone_name: 'Pacific/Pago_Pago'
      },
      'arizona' => {
        offset: -7,
        observes_dst: false,
        zone_name: 'America/Phoenix'
      },
      'arkansas' => {
        offset: -5,
        observes_dst: true,
        zone_name: 'America/Chicago'
      },
      'california' => {
        offset: -7,
        observes_dst: true,
        zone_name: 'America/Los_Angeles'
      },
      'colorado' => {
        offset: -6,
        observes_dst: true,
        zone_name: 'America/Denver'
      },
      'connecticut' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'delaware' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'districtofcolumbia' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'federatedstatesofmicronesia' => {
        offset: 11,
        observes_dst: false,
        zone_name: 'Pacific/Noumea'
      },
      'florida' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'georgia' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'guam' => {
        offset: 10,
        observes_dst: false,
        zone_name: 'Pacific/Guam'
      },
      'hawaii' => {
        offset: -10,
        observes_dst: false,
        zone_name: 'Pacific/Honolulu'
      },
      'idaho' => {
        offset: -6,
        observes_dst: true,
        zone_name: 'America/Denver'
      },
      'illinois' => {
        offset: -5,
        observes_dst: true,
        zone_name: 'America/Chicago'
      },
      'indiana' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'iowa' => {
        offset: -5,
        observes_dst: true,
        zone_name: 'America/Chicago'
      },
      'kansas' => {
        offset: -5,
        observes_dst: true,
        zone_name: 'America/Chicago'
      },
      'kentucky' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'louisiana' => {
        offset: -5,
        observes_dst: true,
        zone_name: 'America/Chicago'
      },
      'maine' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'marshallislands' => {
        offset: 12,
        observes_dst: false,
        zone_name: 'Pacific/Majuro'
      },
      'maryland' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'massachusetts' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'michigan' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'minnesota' => {
        offset: -5,
        observes_dst: true,
        zone_name: 'America/Chicago'
      },
      'mississippi' => {
        offset: -5,
        observes_dst: true,
        zone_name: 'America/Chicago'
      },
      'missouri' => {
        offset: -5,
        observes_dst: true,
        zone_name: 'America/Chicago'
      },
      'montana' => {
        offset: -6,
        observes_dst: true,
        zone_name: 'America/Denver'
      },
      'nebraska' => {
        offset: -5,
        observes_dst: true,
        zone_name: 'America/Chicago'
      },
      'nevada' => {
        offset: -7,
        observes_dst: true,
        zone_name: 'America/Los_Angeles'
      },
      'newhampshire' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'newjersey' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'newmexico' => {
        offset: -6,
        observes_dst: true,
        zone_name: 'America/Denver'
      },
      'newyork' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'northcarolina' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'northdakota' => {
        offset: -5,
        observes_dst: true,
        zone_name: 'America/Chicago'
      },
      'northernmarianaislands' => {
        offset: 10,
        observes_dst: false,
        zone_name: 'Pacific/Guam'
      },
      'ohio' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'oklahoma' => {
        offset: -5,
        observes_dst: true,
        zone_name: 'America/Chicago'
      },
      'oregon' => {
        offset: -7,
        observes_dst: true,
        zone_name: 'America/Los_Angeles'
      },
      'palau' => {
        offset: 9,
        observes_dst: false,
        zone_name: 'Asia/Tokyo'
      },
      'pennsylvania' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'puertorico' => {
        offset: -4,
        observes_dst: false,
        time_zone: 'America/Puerto_Rico'
      },
      'rhodeisland' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'southcarolina' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'southdakota' => {
        offset: -5,
        observes_dst: true,
        zone_name: 'America/Chicago'
      },
      'tennessee' => {
        offset: -5,
        observes_dst: true,
        zone_name: 'America/Chicago'
      },
      'texas' => {
        offset: -5,
        observes_dst: true,
        zone_name: 'America/Chicago'
      },
      'utah' => {
        offset: -6,
        observes_dst: true,
        zone_name: 'America/Denver'
      },
      'vermont' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'virginislands' => {
        offset: -4,
        observes_dst: false,
        zone_name: 'America/Puerto_Rico'
      },
      'virginia' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'washington' => {
        offset: -7,
        observes_dst: true,
        zone_name: 'America/Los_Angeles'
      },
      'westvirginia' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      'wisconsin' => {
        offset: -5,
        observes_dst: true,
        zone_name: 'America/Chicago'
      },
      'wyoming' => {
        offset: -6,
        observes_dst: true,
        zone_name: 'America/Denver'
      },
      nil => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      },
      '' => {
        offset: -4,
        observes_dst: true,
        zone_name: 'America/New_York'
      }
    }
  end
  # rubocop:enable Metrics/MethodLength

  def normalize_state_names(pat)
    pat.monitored_address_state = normalize_and_get_state_name(pat.monitored_address_state) || pat.monitored_address_state
    pat.address_state = normalize_and_get_state_name(pat.address_state) || pat.address_state
    adpt = pat.additional_planned_travel_destination_state
    pat.additional_planned_travel_destination_state = normalize_and_get_state_name(adpt) || adpt
  end

  def normalize_name(name)
    return nil if name.nil?

    name.delete(" \t\r\n").downcase
  end

  def normalize_and_get_state_name(name)
    state_names[normalize_name(name)] || nil
  end

  def time_zone_offset_for_state(name)
    # Grab state time zone information by name
    state = states_with_time_zone_data[normalize_name(name)]

    # Grab time zone offset
    offset = state.nil? ? -4 : state[:offset]

    # Adjust for DST (if observed)
    offset -= 1 if state && state[:observes_dst] && !Time.use_zone('Eastern Time (US & Canada)') { Time.now.dst? }

    # Format and return the offset
    (offset.negative? ? '' : '+') + format('%<offset>.2d', offset: offset) + ':00'
  end

  def time_zone_for_state(name)
    states_with_time_zone_data[normalize_name(name)][:zone_name]
  end

  def self.languages(language)
    languages = {
      'arabic': { code: 'ar', display: 'Arabic', system: 'urn:ietf:bcp:47' },
      'bengali': { code: 'bn', display: 'Bengali', system: 'urn:ietf:bcp:47' },
      'czech': { code: 'cs', display: 'Czech', system: 'urn:ietf:bcp:47' },
      'danish': { code: 'da', display: 'Danish', system: 'urn:ietf:bcp:47' },
      'german': { code: 'de', display: 'German', system: 'urn:ietf:bcp:47' },
      'greek': { code: 'el', display: 'Greek', system: 'urn:ietf:bcp:47' },
      'english': { code: 'en', display: 'English', system: 'urn:ietf:bcp:47' },
      'spanish': { code: 'es', display: 'Spanish', system: 'urn:ietf:bcp:47' },
      'finnish': { code: 'fi', display: 'Finnish', system: 'urn:ietf:bcp:47' },
      'french': { code: 'fr', display: 'French', system: 'urn:ietf:bcp:47' },
      'frysian': { code: 'fy', display: 'Frysian', system: 'urn:ietf:bcp:47' },
      'hindi': { code: 'hi', display: 'Hindi', system: 'urn:ietf:bcp:47' },
      'croatian': { code: 'hr', display: 'Croatian', system: 'urn:ietf:bcp:47' },
      'italian': { code: 'it', display: 'Italian', system: 'urn:ietf:bcp:47' },
      'japanese': { code: 'ja', display: 'Japanese', system: 'urn:ietf:bcp:47' },
      'korean': { code: 'ko', display: 'Korean', system: 'urn:ietf:bcp:47' },
      'dutch': { code: 'nl', display: 'Dutch', system: 'urn:ietf:bcp:47' },
      'norwegian': { code: 'no', display: 'Norwegian', system: 'urn:ietf:bcp:47' },
      'punjabi': { code: 'pa', display: 'Punjabi', system: 'urn:ietf:bcp:47' },
      'polish': { code: 'pl', display: 'Polish', system: 'urn:ietf:bcp:47' },
      'portuguese': { code: 'pt', display: 'Portuguese', system: 'urn:ietf:bcp:47' },
      'russian': { code: 'ru', display: 'Russian', system: 'urn:ietf:bcp:47' },
      'serbian': { code: 'sr', display: 'Serbian', system: 'urn:ietf:bcp:47' },
      'swedish': { code: 'sv', display: 'Swedish', system: 'urn:ietf:bcp:47' },
      'telegu': { code: 'te', display: 'Telegu', system: 'urn:ietf:bcp:47' },
      'chinese': { code: 'zh', display: 'Chinese', system: 'urn:ietf:bcp:47' },
      'vietnamese': { code: 'vi', display: 'Vietnamese', system: 'urn:ietf:bcp:47' },
      'tagalog': { code: 'tl', display: 'Tagalog', system: 'urn:ietf:bcp:47' },
      'somali': { code: 'so', display: 'Somali', system: 'urn:ietf:bcp:47' },
      'nepali': { code: 'ne', display: 'Nepali', system: 'urn:ietf:bcp:47' },
      'swahili': { code: 'sw', display: 'Swahili', system: 'urn:ietf:bcp:47' },
      'burmese': { code: 'my', display: 'Burmese', system: 'urn:ietf:bcp:47' },
      'spanish (puerto rican)': { code: 'es-PR', display: 'Spanish (Puerto Rican)', system: 'urn:ietf:bcp:47' }
    }
    languages[language&.downcase&.to_sym].present? ? languages[language&.downcase&.to_sym] : nil
  end
end

class BeaconConfig < ActiveRecord::Base
  belongs_to :beacon
  serialize :data, ActiveSupport::HashWithIndifferentAccess

  DEFAULT_DATA_KEYS = {
    battery_level: nil,
    device_id: nil,
    last_action: nil,
    average_connection_interval: nil,
    latest_firmware: true,
    signal_interval: 350,
    transmission_power: 1,
    master: nil,
    slaves: []
  }

  after_initialize :ensure_data

  delegate :minor, :major, to: :beacon

  def proximity
    beacon.try(:uuid)
  end

  # Update beacon configuration.
  # Some extension can override this functionality or add some custom stuff.
  # @param [Admin] admin
  # @param [Hash] data
  def update_data(admin, data)
    loaded_data.merge!(data.with_indifferent_access)
    update_attribute(:data, loaded_data)
  end

  def current_transmission_power
    transmission_power
  end

  def current_signal_interval
    signal_interval
  end

  # Loading beacon configuration.
  # Some extension can override this functionality or add some custom stuff.
  # @param [Admin] admin
  # @return [ActiveSupport::HashWithIndifferentAccess]
  def load_data(admin)
    @loaded_data ||= self.data.with_indifferent_access
  end

  # Preloaded data. This method require to call BeaconConfig#load_data before use.
  def loaded_data
    @loaded_data ||= data
  end

  # Initialize data.
  private def ensure_data
    self.data ||= {}
    DEFAULT_DATA_KEYS.each_pair do |key, val|
      self.data.key?(key) || self.data.merge!(key => val)
    end
  end
end

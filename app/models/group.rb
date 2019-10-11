class Group < ApplicationRecord
  belongs_to :group_run
  belongs_to :tank, class_name: 'Character', optional: true
  belongs_to :healer, class_name: 'Character', optional: true
  has_many :group_dps, class_name: 'GroupDps'
  has_many :dps, through: :group_dps, class_name: 'Character', foreign_key: :dps_id

  def list
    {
      tank: tank,
      healer: healer,
      dps: dps
    }
  end

  def pretty_list
    {
      tank: tank&.name || 'EMPTY',
      healer: healer&.name || 'EMPTY',
      dps: dps.map(&:name)
    }
  end

  if Rails.env.development?
    def log_pretty_list
      l = pretty_list
      puts '--------------------------------'
      puts ''
      puts "Tank: #{l[:tank]}"
      puts "Healer: #{l[:healer]}"
      l[:dps].each do |d|
        puts "DPS: #{d}"
      end
      puts ''
      puts '--------------------------------'
    end
  end

  def fill_specific_slot(pool, slot)
    return [nil, pool] if pool.empty?
    char = pool.pop

    case slot
    when :dps
      return [nil, pool.unshift(char)] unless dps.count < 3
      dps << char
    when :tank
      return [nil, pool.unshift(char)] unless tank_id.nil?
      update(tank_id: char.id)
    when :healer
      return [nil, pool.unshift(char)]  unless healer_id.nil?
      update(healer_id: char.id)
    end

    return [char, pool]
  end

  def fill_random_slot(pool)
    return [nil, pool] if pool.empty?
    dps_full = dps.count >= 3

    pool.count.times do
      char = pool.pop
      char.roles.shuffle.each do |role|
        case role
        when :dps
          next if dps_full
          dps << char
        when :healer
          next unless healer_id.nil?
          update(healer: char)
        when :tank
          next unless tank_id.nil?
          update(tank: char)
        end

        return [char, pool]
      end
      pool.unshift char
      return [nil, pool]
    end
  end
end

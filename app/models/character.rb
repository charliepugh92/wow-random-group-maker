class Character < ApplicationRecord
  class << self
    def generate_groups
      number_of_groups = Character.count / 5

      tanks = get_tanks(number_of_groups)

      healers = get_healers(number_of_groups, tanks.map(&:id))

      dps = get_dps(number_of_groups, tanks.map(&:id) + healers.map(&:id))

      create_groups(tanks, healers, dps)
    end

    def create_groups(tanks, healers, dps)
      groups = []
      
      tanks.count.times do |i|
        groups.push({
          tank: tanks[i],
          healer: healers[i],
          dps: dps[i]
        })
      end

      groups
    end

    def get_tanks(count, already_assigned_ids = [])
      tanks = []

      tank_only = Character.where(tank: true, healer: false, dps: false).where.not(id: already_assigned_ids).order('RANDOM()')
      tank_only.each do |tank|
        break if tanks.count == count
        tanks.push tank
      end
      
      if tanks.count < count
        other_tanks = Character.where(tank: true).where.not(id: tank_only.map(&:id)).where.not(id: already_assigned_ids).order('RANDOM()')
        other_tanks.each do |tank|
          break if tanks.count == count
          tanks.push tank
        end
      end

      tanks.shuffle
    end

    def get_healers(count, already_assigned_ids = [])
      heals = []

      heal_only = Character.where(tank: false, healer: true, dps: false).where.not(id: already_assigned_ids).order('RANDOM()')
      heal_only.each do |healer|
        break if heals.count == count
        heals.push healer
      end
      
      if heals.count < count
        other_heals = Character.where(healer: true).where.not(id: heal_only.map(&:id)).where.not(id: already_assigned_ids).order('RANDOM()')
        other_heals.each do |healer|
          break if heals.count == count
          heals.push healer
        end
      end

      heals.shuffle
    end

    def get_dps(count, already_assigned_ids = [])
      dps = []

      dps_only = Character.where(tank: false, healer: false, dps: true).where.not(id: already_assigned_ids).order('RANDOM()')
      dps_only.each do |tank|
        break if dps.count == count * 3
        dps.push tank
      end

      if dps.count < count * 3
        other_dps = Character.where(dps: true).where.not(id: dps_only.map(&:id)).where.not(id: already_assigned_ids).order('RANDOM()')
        other_dps.each do |dpser|
          break if dps.count == count * 3
          dps.push dpser
        end
      end

      dps.shuffle.each_slice(count).to_a
    end
  end
end

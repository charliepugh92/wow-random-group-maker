class Character < ApplicationRecord
  enum skill_level: %i[low medium high]

  def roles
    roles = []

    roles.push :tank if tank
    roles.push :healer if healer
    roles.push :dps if rdps || mdps

    roles
  end

  class << self
    def generate_groups
      number_of_groups = Character.count / 5

      groups = []
      number_of_groups.times do
        groups.push(
          tank: nil,
          healer: nil,
          dps: []
        )
      end

      groups = distribute_low_skill(groups)
      groups = distribute_high_skill(groups)

      groups = get_tanks(groups)
      groups = get_healers(groups)
      groups = get_dps(groups)

      fill_group = get_fill_group(groups)
      groups.push fill_group if fill_group

      groups
    end

    private

    def ids_in_groups(groups)
      ids = []

      groups.each do |group|
        ids.push group[:tank].id unless group[:tank].nil?
        ids.push group[:healer].id unless group[:healer].nil?
        group[:dps].each { |dps| ids.push dps.id unless dps.nil? }
      end

      ids
    end

    def distribute_high_skill(groups)
      available_high_skill = Character.high.where.not(id: ids_in_groups(groups)).order('RANDOM()').to_a

      groups.shuffle.each_with_index do |group, i|
        break if available_high_skill.empty?

        while true
          potential_addition = available_high_skill.pop
          roles = potential_addition.roles
          selected_role = nil
          
          while selected_role.nil?
            potential_role = roles.shuffle.pop
            
            if [:tank, :healer].include?potential_role
              selected_role = potential_role if group[potential_role].nil?
            else
              selected_role = potential_role if group[:dps].count < 3
            end

            break if roles.empty?
          end

          if selected_role.nil?
            available_high_skill.push potential_addition
          else
            if [:tank, :healer].include?selected_role
              groups[i][selected_role] = potential_addition
            else
              groups[i][:dps].push potential_addition
            end

            break
          end
        end
      end

      groups
    end

    def distribute_low_skill(groups)
      available_low_skill = Character.low.where.not(id: ids_in_groups(groups)).order('RANDOM()').to_a

      groups.shuffle.each_with_index do |group, i|
        break if available_low_skill.empty?

        while true
          potential_addition = available_low_skill.pop
          roles = potential_addition.roles
          selected_role = nil
          
          while selected_role.nil?
            potential_role = roles.shuffle.pop
            
            if [:tank, :healer].include?potential_role
              selected_role = potential_role if group[potential_role].nil?
            else
              selected_role = potential_role if group[:dps].count < 3
            end

            break if roles.empty?
          end

          if selected_role.nil?
            available_low_skill.push potential_addition
          else
            if [:tank, :healer].include?selected_role
              groups[i][selected_role] = potential_addition
            else
              groups[i][:dps].push potential_addition
            end

            break
          end
        end
      end

      groups
    end

    def get_fill_group(groups)
      unassigned_chars = Character.where.not(id: ids_in_groups(groups))

      return false if unassigned_chars.length == 0

      fill_group = {
        tank: nil,
        healer: nil,
        dps: []
      }

      unassigned_chars.each do |char|
        selected_role = nil

        char.roles.shuffle.each do |role|
          next if role == :dps && fill_group[:dps].count > 2
          next if role != :dps && fill_group[role].present?

          selected_role = role
        end

        if selected_role.nil?
          # todo
        else
          if selected_role == :dps
            fill_group[:dps].push char
          else
            fill_group[selected_role] = char
          end
        end
      end

      fill_group = fill_empty_slots(fill_group)

      while fill_group[:dps].count < 3
        fill_group[:dps].push nil
      end

      fill_group
    end

    def fill_empty_slots(group)
      if group[:tank].nil?
        group[:tank] = Character.where.not(id: ids_in_groups([group])).where(tank: true, allow_multiple_groups: true).order('RANDOM()').first
      end

      if group[:healer].nil?
        group[:healer] = Character.where.not(id: ids_in_groups([group])).where(healer: true, allow_multiple_groups: true).order('RANDOM()').first
      end

      available_dps = Character.where.not(id: ids_in_groups([group])).where('allow_multiple_groups = true AND (rdps = true OR mdps = true)').order('RANDOM()').to_a
      while group[:dps].count < 3
        group[:dps].push available_dps.pop
      end

      group
    end

    def get_tanks(groups)
      tank_only = Character.where(tank: true, healer: false, rdps: false, mdps: false).where.not(id: ids_in_groups(groups)).order('RANDOM()').to_a
      groups.each_with_index do |group, i|
        break if tank_only.empty?
        next unless group[:tank].nil?

        groups[i][:tank] = tank_only.pop
      end

      other_tanks = Character.where(tank: true).where.not(id: ids_in_groups(groups)).order('RANDOM()').to_a
      groups.each_with_index do |group, i|
        break if other_tanks.empty?
        next if group[:tank].present?

        groups[i][:tank] = other_tanks.pop
      end

      groups
    end

    def get_healers(groups)
      heals = []

      heal_only = Character.where(healer: true, rdps: false, mdps: false).where.not(id: ids_in_groups(groups)).order('RANDOM()').to_a
      groups.each_with_index do |group, i|
        break if heal_only.empty?
        next if group[:healer].present?

        groups[i][:healer] = heal_only.pop
      end
      
      other_heals = Character.where(healer: true).where.not(id: ids_in_groups(groups)).order('RANDOM()').to_a
      groups.each_with_index do |group, i|
        break if other_heals.empty?
        next if group[:healer].present?

        groups[i][:healer] = other_heals.pop
      end

      groups
    end

    def get_dps(groups)
      next_index = 0

      rdps_only = Character.where.not(id: ids_in_groups(groups)).where(rdps: true, mdps: false).order('RANDOM()').to_a
      groups.each_with_index do |group, i|
        break if rdps_only.empty?
        next if group[:dps].count >= 3

        groups[i][:dps].push rdps_only.pop
      end

      mdps_only = Character.where.not(id: ids_in_groups(groups)).where(rdps: false, mdps: true).order('RANDOM()').to_a
      groups.each_with_index do |group, i|
        break if mdps_only.empty?
        next if group[:dps].count >= 3

        groups[i][:dps].push mdps_only.pop
      end
      
      remaining_dps = Character.where.not(id: ids_in_groups(groups)).where('rdps = true OR mdps = true').order('RANDOM()').to_a
      remaining_dps.each do |dps|
        groups.each_with_index do |group, i|
          next if group[:dps].count >= 3

          groups[i][:dps].push dps
          break
        end
      end

      groups.each_with_index do |group, i|
        while group[:dps].count < 3
          group[i][:dps].push nil
        end
      end

      groups
    end
  end
end

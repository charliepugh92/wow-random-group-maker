class Character < ApplicationRecord
  def self.generate_groups
    number_of_groups = Character.count / 5
    groups = []
    number_of_groups.times do
      groups.push({})
    end

    tanks = Character.where(tank: true).order('RANDOM()').limit(number_of_groups)
    tanks.each_with_index do |tank, i|
      groups[i][:tank] = tank
    end

    healers = Character.where(healer: true).where.not(id: tanks.map(&:id)).order('RANDOM()').limit(number_of_groups)
    healers.each_with_index do |healer, i|
      groups[i][:healer] = healer
    end

    dps = Character.where(dps: true).where.not(id: tanks.map(&:id)).where.not(id: healers.map(&:id)).order('RANDOM()').limit(number_of_groups * 3)
    dps.each_with_index do |dpser, i|
      assigned_group = i % number_of_groups
      groups[assigned_group][:dps] = [] unless groups[assigned_group][:dps]
      groups[assigned_group][:dps].push dpser
    end
    
    groups
  end
end

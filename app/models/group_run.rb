class GroupRun < ApplicationRecord
  has_many :groups, dependent: :destroy

  attr_accessor :used_ids

  class << self
    def generate
      count = Character.with_role.count / 5

      run = GroupRun.create
      groups = count.times { Group.create(group_run: run) }
      
      run.fill_by_skill_level(:high)
      run.fill_by_skill_level(:low)
      run.fill_specific_role(:tank)
      run.fill_specific_role(:healer, [:tank])
      run.fill_specific_role(:mdps, [:tank, :healer])
      run.fill_specific_role(:rdps, [:tank, :healer])
      run.fill_empty_dps
      run.fill_empty_with_dups

      run.generate_fill_group

      run
    end
  end

  def available_characters
    Character.with_role
             .where.not(id: used_ids)
             .order('RANDOM()')
  end

  def list
    groups.map(&:list)
  end

  def pretty_list
    groups.map(&:pretty_list)
  end
  
  if Rails.env.development?
    def log_pretty_list
      groups.includes(:dps, :tank, :healer).each(&:log_pretty_list)
    end
  end

  def generate_fill_group
    missing_chars = Character.with_role
                             .where.not(id: used_ids)
                             .order('RANDOM()')
                             .to_a
    return if missing_chars.empty?

    group_ids = []
    fill_group = groups.create
    missing_chars.count.times do
      char, missing_chars = fill_group.fill_random_slot(missing_chars)
      group_ids.push char.id unless char.nil?
    end

    fill_chars = Character.with_role
                          .where(allow_multiple_groups: true)
                          .where.not(id: group_ids + multiple_group_ids)
                          .order('RANDOM()').to_a

    fill_chars.count.times do
      char, fill_chars = fill_group.fill_random_slot(fill_chars)
      group_ids.push char.id unless char.nil?
    end
  end

  def fill_empty_dps
    pool = available_characters.where('mdps = true or rdps = true')
                               .order('RANDOM()')
                               .to_a
    groups.each do |g|
      while g.dps.count < 3
        break if pool.empty?
        char, pool = g.fill_specific_slot(pool, :dps)
        used_ids.push char.id unless char.nil?
      end
    end
  end

  def fill_empty_with_dups
    pool = Character.with_role
                    .where.not(id: multiple_group_ids)
                    .order('RANDOM()')
                    .to_a

    groups.each do |g|
      pool.count.times do
        break if g.tank && g.healer && g.dps.count >= 3
        
        char, pool = g.fill_random_slot(pool)
        used_ids.push char.id unless char.nil?
      end
    end
  end

  def fill_specific_role(role, roles_filled = [])
    negative_roles = { 
      tank: false,
      healer: false,
      mdps: false,
      rdps: false
    }.reject { |k, _| k == role || k.in?(roles_filled) }

    only_role_pool = available_characters.where(negative_roles)
                                         .where(role => true)
                                         .to_a

    groups.each do |g|
      char, only_role_pool = g.fill_specific_slot(only_role_pool, role.in?([:mdps, :rdps]) ? :dps : role)
      used_ids.push char.id unless char.nil?
    end

    any_role_pool = available_characters.where(role => true)
                                        .to_a

    groups.each do |g|
      char, any_role_pool = g.fill_specific_slot(any_role_pool, role.in?([:mdps, :rdps]) ? :dps : role)
      used_ids.push char.id unless char.nil?
    end
  end

  def fill_by_skill_level(skill)
    pool = available_characters.where(skill_level: skill)
                               .to_a
    
    groups.each do |group|
      char, pool = group.fill_random_slot(pool)
      used_ids.push char.id unless char.nil?
    end
  end

  def multiple_group_ids
    found = {}
    ids = []

    used_ids.each do |id|
      ids.push id if found[id]
      found[id] = true
    end

    ids.uniq
  end

  def used_ids
    @used_ids ||= current_ids
  end

  def current_ids
    ids = []
    groups.each { |g| ids.push g.tank_id }
    groups.each { |g| ids.push g.healer_id }
    groups.each { |g| ids.push g.dps.map(&:id) }

    ids.flatten
  end
end

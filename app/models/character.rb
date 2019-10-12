class Character < ApplicationRecord
  enum skill_level: %i[low medium high]
  scope :available_for_runs, -> { where('(tank = true or healer = true or mdps = true or rdps = true) and do_not_include = false') }

  def roles
    roles = []

    roles.push :tank if tank
    roles.push :healer if healer
    roles.push :dps if rdps || mdps

    roles
  end
end

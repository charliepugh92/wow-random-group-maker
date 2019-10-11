class Character < ApplicationRecord
  enum skill_level: %i[low medium high]
  scope :with_role, -> { where('tank = true or healer = true or mdps = true or rdps = true') }

  def roles
    roles = []

    roles.push :tank if tank
    roles.push :healer if healer
    roles.push :dps if rdps || mdps

    roles
  end
end

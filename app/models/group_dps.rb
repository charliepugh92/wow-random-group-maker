class GroupDps < ApplicationRecord
  belongs_to :group
  belongs_to :dps, class_name: 'Character'
end

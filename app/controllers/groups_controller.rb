class GroupsController < ApplicationController
  def show
    @groups = Character.generate_groups
  end
end
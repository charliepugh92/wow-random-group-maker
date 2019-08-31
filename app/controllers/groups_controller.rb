class GroupsController < AuthenticatedController
  def show
    @groups = Character.generate_groups
  end
end

class GroupsController < AuthenticatedController
  def show
    @groups = GroupRun.generate.list
  end
end

module Characters
  class ToggleController < AuthenticatedController
    before_action :find_character

    def update
      attribute = params[:attribute].to_sym

      @character.update(attribute => !@character.send(attribute))

      redirect_to characters_path
    end

    private

    def find_character
      @character = Character.find_by(id: params[:character_id])
    end
  end
end
